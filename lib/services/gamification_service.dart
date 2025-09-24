import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class GamificationService {
  static const String _achievementsKey = 'achievements';
  static const String _userStatsKey = 'user_stats';

  final DatabaseService _databaseService = DatabaseService();
  List<Achievement> _achievements = [];
  UserStats? _userStats;

  /// Inicializar el sistema de gamificación
  Future<void> initialize() async {
    await _loadAchievements();
    await _loadUserStats();
    await _updateUserStats();
  }

  /// Obtener todos los logros
  List<Achievement> get achievements => _achievements;

  /// Obtener estadísticas del usuario
  UserStats? get userStats => _userStats;

  /// Obtener logros desbloqueados
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  /// Obtener logros bloqueados
  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();

  /// Procesar evento de mood entry
  Future<List<Achievement>> processMoodEntry(MoodEntry entry) async {
    final newAchievements = <Achievement>[];

    // Actualizar progreso de logros relacionados con mood
    for (int i = 0; i < _achievements.length; i++) {
      if (_achievements[i].type == AchievementType.mood &&
          !_achievements[i].isUnlocked) {
        final updated = await _updateMoodAchievement(_achievements[i]);
        if (updated != null &&
            updated.isUnlocked &&
            !_achievements[i].isUnlocked) {
          newAchievements.add(updated);
          _achievements[i] = updated;
        } else if (updated != null) {
          _achievements[i] = updated;
        }
      }
    }

    // Verificar rachas
    final streakAchievements = await _checkStreakAchievements();
    newAchievements.addAll(streakAchievements);

    await _saveAchievements();
    await _updateUserStats();

    // Notificar logros desbloqueados
    for (final achievement in newAchievements) {
      await _notifyAchievementUnlocked(achievement);
    }

    return newAchievements;
  }

  /// Procesar evento de meditation session
  Future<List<Achievement>> processMeditationSession(
    MeditationSession session,
  ) async {
    final newAchievements = <Achievement>[];

    // Actualizar progreso de logros relacionados con meditación
    for (int i = 0; i < _achievements.length; i++) {
      if (_achievements[i].type == AchievementType.meditation &&
          !_achievements[i].isUnlocked) {
        final updated = await _updateMeditationAchievement(_achievements[i]);
        if (updated != null &&
            updated.isUnlocked &&
            !_achievements[i].isUnlocked) {
          newAchievements.add(updated);
          _achievements[i] = updated;
        } else if (updated != null) {
          _achievements[i] = updated;
        }
      }
    }

    // Verificar rachas
    final streakAchievements = await _checkStreakAchievements();
    newAchievements.addAll(streakAchievements);

    await _saveAchievements();
    await _updateUserStats();

    // Notificar logros desbloqueados
    for (final achievement in newAchievements) {
      await _notifyAchievementUnlocked(achievement);
    }

    return newAchievements;
  }

  /// Procesar evento de journal entry
  Future<List<Achievement>> processJournalEntry(JournalEntry entry) async {
    final newAchievements = <Achievement>[];

    // Actualizar progreso de logros relacionados con diario
    for (int i = 0; i < _achievements.length; i++) {
      if (_achievements[i].type == AchievementType.journal &&
          !_achievements[i].isUnlocked) {
        final updated = await _updateJournalAchievement(_achievements[i]);
        if (updated != null &&
            updated.isUnlocked &&
            !_achievements[i].isUnlocked) {
          newAchievements.add(updated);
          _achievements[i] = updated;
        } else if (updated != null) {
          _achievements[i] = updated;
        }
      }
    }

    // Verificar rachas
    final streakAchievements = await _checkStreakAchievements();
    newAchievements.addAll(streakAchievements);

    await _saveAchievements();
    await _updateUserStats();

    // Notificar logros desbloqueados
    for (final achievement in newAchievements) {
      await _notifyAchievementUnlocked(achievement);
    }

    return newAchievements;
  }

  /// Actualizar logro de mood
  Future<Achievement?> _updateMoodAchievement(Achievement achievement) async {
    final moodEntries = await _databaseService.getAllMoodEntries();
    int progress = 0;

    switch (achievement.id) {
      case 'mood_first_entry':
        progress = moodEntries.isNotEmpty ? 1 : 0;
        break;
      case 'mood_10_entries':
        progress = moodEntries.length;
        break;
      case 'mood_50_entries':
        progress = moodEntries.length;
        break;
      case 'mood_100_entries':
        progress = moodEntries.length;
        break;
      case 'mood_excellent_week':
        final lastWeek = DateTime.now().subtract(const Duration(days: 7));
        final recentEntries = moodEntries
            .where(
              (entry) =>
                  entry.date.isAfter(lastWeek) &&
                  entry.overallMood == MoodLevel.excellent,
            )
            .length;
        progress = recentEntries >= 7 ? 1 : 0;
        break;
    }

    if (progress != achievement.currentProgress) {
      final updated = achievement.copyWith(
        currentProgress: progress,
        isUnlocked: progress >= achievement.targetValue,
        unlockedAt: progress >= achievement.targetValue ? DateTime.now() : null,
      );
      return updated;
    }

    return null;
  }

  /// Actualizar logro de meditación
  Future<Achievement?> _updateMeditationAchievement(
    Achievement achievement,
  ) async {
    final sessions = await _databaseService.getAllMeditationSessions();
    final completedSessions = sessions.where((s) => s.completed).toList();
    int progress = 0;

    switch (achievement.id) {
      case 'meditation_first_session':
        progress = completedSessions.isNotEmpty ? 1 : 0;
        break;
      case 'meditation_10_sessions':
        progress = completedSessions.length;
        break;
      case 'meditation_50_sessions':
        progress = completedSessions.length;
        break;
      case 'meditation_100_minutes':
        final totalMinutes = completedSessions.fold<int>(
          0,
          (sum, session) =>
              sum +
              (session.actualDuration?.inMinutes ?? session.duration.inMinutes),
        );
        progress = totalMinutes;
        break;
      case 'meditation_500_minutes':
        final totalMinutes = completedSessions.fold<int>(
          0,
          (sum, session) =>
              sum +
              (session.actualDuration?.inMinutes ?? session.duration.inMinutes),
        );
        progress = totalMinutes;
        break;
    }

    if (progress != achievement.currentProgress) {
      final updated = achievement.copyWith(
        currentProgress: progress,
        isUnlocked: progress >= achievement.targetValue,
        unlockedAt: progress >= achievement.targetValue ? DateTime.now() : null,
      );
      return updated;
    }

    return null;
  }

  /// Actualizar logro de diario
  Future<Achievement?> _updateJournalAchievement(
    Achievement achievement,
  ) async {
    final entries = await _databaseService.getAllJournalEntries();
    int progress = 0;

    switch (achievement.id) {
      case 'journal_first_entry':
        progress = entries.isNotEmpty ? 1 : 0;
        break;
      case 'journal_10_entries':
        progress = entries.length;
        break;
      case 'journal_50_entries':
        progress = entries.length;
        break;
      case 'journal_1000_words':
        final totalWords = entries.fold<int>(
          0,
          (sum, entry) => sum + entry.wordCount,
        );
        progress = totalWords;
        break;
      case 'journal_10000_words':
        final totalWords = entries.fold<int>(
          0,
          (sum, entry) => sum + entry.wordCount,
        );
        progress = totalWords;
        break;
    }

    if (progress != achievement.currentProgress) {
      final updated = achievement.copyWith(
        currentProgress: progress,
        isUnlocked: progress >= achievement.targetValue,
        unlockedAt: progress >= achievement.targetValue ? DateTime.now() : null,
      );
      return updated;
    }

    return null;
  }

  /// Verificar logros de racha
  Future<List<Achievement>> _checkStreakAchievements() async {
    final newAchievements = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      if (_achievements[i].type == AchievementType.streak &&
          !_achievements[i].isUnlocked) {
        final updated = await _updateStreakAchievement(_achievements[i]);
        if (updated != null && updated.isUnlocked) {
          newAchievements.add(updated);
          _achievements[i] = updated;
        } else if (updated != null) {
          _achievements[i] = updated;
        }
      }
    }

    return newAchievements;
  }

  /// Actualizar logro de racha
  Future<Achievement?> _updateStreakAchievement(Achievement achievement) async {
    int progress = 0;

    switch (achievement.id) {
      case 'streak_mood_7':
        progress = await _getMoodStreak();
        break;
      case 'streak_mood_30':
        progress = await _getMoodStreak();
        break;
      case 'streak_meditation_7':
        progress = await _getMeditationStreak();
        break;
      case 'streak_meditation_30':
        progress = await _getMeditationStreak();
        break;
      case 'streak_journal_7':
        progress = await _getJournalStreak();
        break;
      case 'streak_journal_30':
        progress = await _getJournalStreak();
        break;
    }

    if (progress != achievement.currentProgress) {
      final updated = achievement.copyWith(
        currentProgress: progress,
        isUnlocked: progress >= achievement.targetValue,
        unlockedAt: progress >= achievement.targetValue ? DateTime.now() : null,
      );
      return updated;
    }

    return null;
  }

  /// Obtener racha de mood
  Future<int> _getMoodStreak() async {
    final entries = await _databaseService.getAllMoodEntries();
    if (entries.isEmpty) {
    return 0;;
  }

    final sortedEntries = entries..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final entry in sortedEntries) {
      if (entry.date.day == currentDate.day &&
          entry.date.month == currentDate.month &&
          entry.date.year == currentDate.year) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Obtener racha de meditación
  Future<int> _getMeditationStreak() async {
    final sessions = await _databaseService.getAllMeditationSessions();
    final completedSessions = sessions.where((s) => s.completed).toList();
    if (completedSessions.isEmpty) {
    return 0;;
  }

    completedSessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final session in completedSessions) {
      if (session.completedAt.day == currentDate.day &&
          session.completedAt.month == currentDate.month &&
          session.completedAt.year == currentDate.year) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Obtener racha de diario
  Future<int> _getJournalStreak() async {
    final entries = await _databaseService.getAllJournalEntries();
    if (entries.isEmpty) {
    return 0;;
  }

    final sortedEntries = entries
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final entry in sortedEntries) {
      if (entry.createdAt.day == currentDate.day &&
          entry.createdAt.month == currentDate.month &&
          entry.createdAt.year == currentDate.year) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Cargar logros desde SharedPreferences
  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);

    if (achievementsJson != null) {
      final List<dynamic> achievementsList = json.decode(achievementsJson);
      _achievements = achievementsList
          .map((json) => Achievement.fromJson(json))
          .toList();
    } else {
      _achievements = _getDefaultAchievements();
      await _saveAchievements();
    }
  }

  /// Guardar logros en SharedPreferences
  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = json.encode(
      _achievements.map((a) => a.toJson()).toList(),
    );
    await prefs.setString(_achievementsKey, achievementsJson);
  }

  /// Cargar estadísticas del usuario
  Future<void> _loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final userStatsJson = prefs.getString(_userStatsKey);

    if (userStatsJson != null) {
      _userStats = UserStats.fromJson(json.decode(userStatsJson));
    }
  }

  /// Actualizar estadísticas del usuario
  Future<void> _updateUserStats() async {
    final moodStats = await _databaseService.getMoodStatistics();
    final meditationStats = await _databaseService.getMeditationStatistics();
    final journalStats = await _databaseService.getJournalStatistics();

    final totalPoints = unlockedAchievements.fold<int>(
      0,
      (sum, a) => sum + a.points,
    );
    final level = (totalPoints / 100).floor() + 1;
    final currentLevelPoints = totalPoints % 100;
    final nextLevelPoints = 100;

    _userStats = UserStats(
      totalPoints: totalPoints,
      level: level,
      currentLevelPoints: currentLevelPoints,
      nextLevelPoints: nextLevelPoints,
      totalAchievements: _achievements.length,
      unlockedAchievements: unlockedAchievements.length,
      moodStreak: await _getMoodStreak(),
      meditationStreak: await _getMeditationStreak(),
      journalStreak: await _getJournalStreak(),
      longestMoodStreak: await _getMoodStreak(), // Simplificado
      longestMeditationStreak: await _getMeditationStreak(), // Simplificado
      longestJournalStreak: await _getJournalStreak(), // Simplificado
      totalMoodEntries: moodStats['totalEntries'] ?? 0,
      totalMeditationMinutes: meditationStats['totalMinutes'] ?? 0,
      totalJournalEntries: journalStats['totalEntries'] ?? 0,
      totalWordsWritten: journalStats['totalWords'] ?? 0,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatsKey, json.encode(_userStats!.toJson()));
  }

  /// Notificar logro desbloqueado
  Future<void> _notifyAchievementUnlocked(Achievement achievement) async {
    await NotificationService.showAchievementNotification(
      title: '¡Logro desbloqueado! ${achievement.rarity.icon}',
      body: '${achievement.title} - ${achievement.description}',
    );
  }

  /// Obtener logros predeterminados
  List<Achievement> _getDefaultAchievements() {
    return [
      // Logros de Mood
      Achievement(
        id: 'mood_first_entry',
        title: 'Primer Registro',
        description: 'Registra tu primer estado de ánimo',
        icon: '😊',
        type: AchievementType.mood,
        rarity: AchievementRarity.common,
        targetValue: 1,
        points: 10,
      ),
      Achievement(
        id: 'mood_10_entries',
        title: 'Seguimiento Constante',
        description: 'Registra 10 estados de ánimo',
        icon: '📈',
        type: AchievementType.mood,
        rarity: AchievementRarity.common,
        targetValue: 10,
        points: 25,
      ),
      Achievement(
        id: 'mood_50_entries',
        title: 'Experto en Emociones',
        description: 'Registra 50 estados de ánimo',
        icon: '🎯',
        type: AchievementType.mood,
        rarity: AchievementRarity.rare,
        targetValue: 50,
        points: 50,
      ),
      Achievement(
        id: 'mood_100_entries',
        title: 'Maestro del Bienestar',
        description: 'Registra 100 estados de ánimo',
        icon: '🏆',
        type: AchievementType.mood,
        rarity: AchievementRarity.epic,
        targetValue: 100,
        points: 100,
      ),

      // Logros de Meditación
      Achievement(
        id: 'meditation_first_session',
        title: 'Primera Meditación',
        description: 'Completa tu primera sesión de meditación',
        icon: '🧘',
        type: AchievementType.meditation,
        rarity: AchievementRarity.common,
        targetValue: 1,
        points: 15,
      ),
      Achievement(
        id: 'meditation_10_sessions',
        title: 'Meditador Novato',
        description: 'Completa 10 sesiones de meditación',
        icon: '🌱',
        type: AchievementType.meditation,
        rarity: AchievementRarity.common,
        targetValue: 10,
        points: 30,
      ),
      Achievement(
        id: 'meditation_50_sessions',
        title: 'Meditador Experimentado',
        description: 'Completa 50 sesiones de meditación',
        icon: '🌳',
        type: AchievementType.meditation,
        rarity: AchievementRarity.rare,
        targetValue: 50,
        points: 75,
      ),
      Achievement(
        id: 'meditation_100_minutes',
        title: 'Tiempo de Paz',
        description: 'Medita durante 100 minutos en total',
        icon: '⏰',
        type: AchievementType.meditation,
        rarity: AchievementRarity.rare,
        targetValue: 100,
        points: 60,
      ),
      Achievement(
        id: 'meditation_500_minutes',
        title: 'Gurú de la Meditación',
        description: 'Medita durante 500 minutos en total',
        icon: '🕉️',
        type: AchievementType.meditation,
        rarity: AchievementRarity.legendary,
        targetValue: 500,
        points: 200,
      ),

      // Logros de Diario
      Achievement(
        id: 'journal_first_entry',
        title: 'Primer Pensamiento',
        description: 'Escribe tu primera entrada en el diario',
        icon: '✍️',
        type: AchievementType.journal,
        rarity: AchievementRarity.common,
        targetValue: 1,
        points: 10,
      ),
      Achievement(
        id: 'journal_10_entries',
        title: 'Escritor Novato',
        description: 'Escribe 10 entradas en el diario',
        icon: '📝',
        type: AchievementType.journal,
        rarity: AchievementRarity.common,
        targetValue: 10,
        points: 25,
      ),
      Achievement(
        id: 'journal_50_entries',
        title: 'Cronista Personal',
        description: 'Escribe 50 entradas en el diario',
        icon: '📚',
        type: AchievementType.journal,
        rarity: AchievementRarity.rare,
        targetValue: 50,
        points: 60,
      ),
      Achievement(
        id: 'journal_1000_words',
        title: 'Mil Palabras',
        description: 'Escribe 1000 palabras en total',
        icon: '📖',
        type: AchievementType.journal,
        rarity: AchievementRarity.rare,
        targetValue: 1000,
        points: 50,
      ),
      Achievement(
        id: 'journal_10000_words',
        title: 'Autor Prolífico',
        description: 'Escribe 10,000 palabras en total',
        icon: '📜',
        type: AchievementType.journal,
        rarity: AchievementRarity.legendary,
        targetValue: 10000,
        points: 150,
      ),

      // Logros de Racha
      Achievement(
        id: 'streak_mood_7',
        title: 'Semana Constante',
        description: 'Registra tu estado de ánimo 7 días seguidos',
        icon: '🔥',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        targetValue: 7,
        points: 40,
      ),
      Achievement(
        id: 'streak_mood_30',
        title: 'Mes de Dedicación',
        description: 'Registra tu estado de ánimo 30 días seguidos',
        icon: '🌟',
        type: AchievementType.streak,
        rarity: AchievementRarity.legendary,
        targetValue: 30,
        points: 120,
      ),
      Achievement(
        id: 'streak_meditation_7',
        title: 'Semana Zen',
        description: 'Medita 7 días seguidos',
        icon: '🔥',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        targetValue: 7,
        points: 50,
      ),
      Achievement(
        id: 'streak_meditation_30',
        title: 'Mes de Paz Interior',
        description: 'Medita 30 días seguidos',
        icon: '💫',
        type: AchievementType.streak,
        rarity: AchievementRarity.legendary,
        targetValue: 30,
        points: 150,
      ),
      Achievement(
        id: 'streak_journal_7',
        title: 'Semana de Reflexión',
        description: 'Escribe en tu diario 7 días seguidos',
        icon: '🔥',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        targetValue: 7,
        points: 45,
      ),
      Achievement(
        id: 'streak_journal_30',
        title: 'Mes de Introspección',
        description: 'Escribe en tu diario 30 días seguidos',
        icon: '✨',
        type: AchievementType.streak,
        rarity: AchievementRarity.legendary,
        targetValue: 30,
        points: 130,
      ),
    ];
  }
}
