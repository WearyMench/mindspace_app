import 'package:uuid/uuid.dart';

enum AchievementType {
  mood('Estado de Ánimo'),
  meditation('Meditación'),
  journal('Diario'),
  streak('Racha'),
  milestone('Hito');

  const AchievementType(this.label);
  final String label;
}

enum AchievementRarity {
  common('Común', '🥉'),
  rare('Raro', '🥈'),
  epic('Épico', '🥇'),
  legendary('Legendario', '🏆');

  const AchievementRarity(this.label, this.icon);
  final String label;
  final String icon;
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int points;

  Achievement({
    String? id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.targetValue,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.points,
  }) : id = id ?? const Uuid().v4();

  double get progressPercentage {
    if (targetValue == 0) {
      return 0.0;
    }
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  bool get isCompleted => currentProgress >= targetValue;

  Achievement copyWith({
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    AchievementRarity? rarity,
    int? targetValue,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? points,
  }) {
    return Achievement(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.name,
      'rarity': rarity.name,
      'targetValue': targetValue,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'points': points,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      type: AchievementType.values.firstWhere((e) => e.name == json['type']),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
      ),
      targetValue: json['targetValue'],
      currentProgress: json['currentProgress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      points: json['points'],
    );
  }
}

class UserStats {
  final int totalPoints;
  final int level;
  final int currentLevelPoints;
  final int nextLevelPoints;
  final int totalAchievements;
  final int unlockedAchievements;
  final int moodStreak;
  final int meditationStreak;
  final int journalStreak;
  final int longestMoodStreak;
  final int longestMeditationStreak;
  final int longestJournalStreak;
  final int totalMoodEntries;
  final int totalMeditationMinutes;
  final int totalJournalEntries;
  final int totalWordsWritten;

  UserStats({
    required this.totalPoints,
    required this.level,
    required this.currentLevelPoints,
    required this.nextLevelPoints,
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.moodStreak,
    required this.meditationStreak,
    required this.journalStreak,
    required this.longestMoodStreak,
    required this.longestMeditationStreak,
    required this.longestJournalStreak,
    required this.totalMoodEntries,
    required this.totalMeditationMinutes,
    required this.totalJournalEntries,
    required this.totalWordsWritten,
  });

  double get levelProgress {
    if (nextLevelPoints == 0) {
      return 1.0;
    }
    return currentLevelPoints / nextLevelPoints;
  }

  double get achievementProgress {
    if (totalAchievements == 0) {
      return 0.0;
    }
    return unlockedAchievements / totalAchievements;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'level': level,
      'currentLevelPoints': currentLevelPoints,
      'nextLevelPoints': nextLevelPoints,
      'totalAchievements': totalAchievements,
      'unlockedAchievements': unlockedAchievements,
      'moodStreak': moodStreak,
      'meditationStreak': meditationStreak,
      'journalStreak': journalStreak,
      'longestMoodStreak': longestMoodStreak,
      'longestMeditationStreak': longestMeditationStreak,
      'longestJournalStreak': longestJournalStreak,
      'totalMoodEntries': totalMoodEntries,
      'totalMeditationMinutes': totalMeditationMinutes,
      'totalJournalEntries': totalJournalEntries,
      'totalWordsWritten': totalWordsWritten,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalPoints: json['totalPoints'] ?? 0,
      level: json['level'] ?? 1,
      currentLevelPoints: json['currentLevelPoints'] ?? 0,
      nextLevelPoints: json['nextLevelPoints'] ?? 100,
      totalAchievements: json['totalAchievements'] ?? 0,
      unlockedAchievements: json['unlockedAchievements'] ?? 0,
      moodStreak: json['moodStreak'] ?? 0,
      meditationStreak: json['meditationStreak'] ?? 0,
      journalStreak: json['journalStreak'] ?? 0,
      longestMoodStreak: json['longestMoodStreak'] ?? 0,
      longestMeditationStreak: json['longestMeditationStreak'] ?? 0,
      longestJournalStreak: json['longestJournalStreak'] ?? 0,
      totalMoodEntries: json['totalMoodEntries'] ?? 0,
      totalMeditationMinutes: json['totalMeditationMinutes'] ?? 0,
      totalJournalEntries: json['totalJournalEntries'] ?? 0,
      totalWordsWritten: json['totalWordsWritten'] ?? 0,
    );
  }
}
