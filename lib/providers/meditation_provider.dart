import 'package:flutter/foundation.dart';
import '../models/meditation_session.dart';
import '../services/database_service.dart';

class MeditationProvider with ChangeNotifier {
  List<MeditationSession> _sessions = [];
  MeditationSession? _currentSession;
  final DatabaseService _databaseService = DatabaseService();

  List<MeditationSession> get sessions => _sessions;
  MeditationSession? get currentSession => _currentSession;

  // Inicializar datos desde la base de datos
  Future<void> initialize() async {
    await loadMeditationSessions();
  }

  Future<void> loadMeditationSessions() async {
    _sessions = await _databaseService.getAllMeditationSessions();
    notifyListeners();
  }

  // Get sessions for a specific date range
  List<MeditationSession> getSessionsForDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _sessions.where((session) {
      return session.completedAt.isAfter(
            start.subtract(const Duration(days: 1)),
          ) &&
          session.completedAt.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get sessions for the last N days
  List<MeditationSession> getSessionsForLastDays(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return getSessionsForDateRange(startDate, endDate);
  }

  // Add a new meditation session
  Future<void> addMeditationSession(MeditationSession session) async {
    await _databaseService.insertMeditationSession(session);
    _sessions.add(session);
    _sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    notifyListeners();
  }

  // Update an existing meditation session
  Future<void> updateMeditationSession(MeditationSession updatedSession) async {
    await _databaseService.updateMeditationSession(updatedSession);
    final index = _sessions.indexWhere(
      (session) => session.id == updatedSession.id,
    );
    if (index != -1) {
      _sessions[index] = updatedSession;
      _sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      notifyListeners();
    }
  }

  // Delete a meditation session
  Future<void> deleteMeditationSession(String id) async {
    await _databaseService.deleteMeditationSession(id);
    _sessions.removeWhere((session) => session.id == id);
    notifyListeners();
  }

  // Start a new meditation session
  void startMeditationSession(
    MeditationType type,
    Duration duration,
    DifficultyLevel difficulty,
  ) {
    _currentSession = MeditationSession(
      type: type,
      duration: duration,
      difficulty: difficulty,
      completedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // Complete the current meditation session
  void completeMeditationSession({
    int? rating,
    String? notes,
    Duration? actualDuration,
  }) {
    if (_currentSession != null) {
      final completedSession = _currentSession!.copyWith(
        completed: true,
        rating: rating,
        notes: notes,
        actualDuration: actualDuration,
      );
      addMeditationSession(completedSession);
      _currentSession = null;
    }
  }

  // Cancel the current meditation session
  void cancelMeditationSession() {
    _currentSession = null;
    notifyListeners();
  }

  // Get meditation statistics
  Map<String, dynamic> getMeditationStatistics() {
    if (_sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalMinutes': 0,
        'averageSessionLength': 0.0,
        'favoriteType': null,
        'streak': 0,
        'completionRate': 0.0,
      };
    }

    final completedSessions = _sessions.where((s) => s.completed).toList();
    final totalMinutes = completedSessions.fold<int>(
      0,
      (sum, session) =>
          sum +
          (session.actualDuration?.inMinutes ?? session.duration.inMinutes),
    );
    final averageSessionLength = completedSessions.isNotEmpty
        ? totalMinutes / completedSessions.length
        : 0.0;

    // Find favorite meditation type
    final typeCount = <MeditationType, int>{};
    for (final session in completedSessions) {
      typeCount[session.type] = (typeCount[session.type] ?? 0) + 1;
    }
    final favoriteType = typeCount.isNotEmpty
        ? typeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    // Calculate streak (consecutive days with meditation)
    int streak = 0;
    final sortedSessions = List<MeditationSession>.from(completedSessions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    DateTime currentDate = DateTime.now();
    for (final session in sortedSessions) {
      if (session.completedAt.day == currentDate.day &&
          session.completedAt.month == currentDate.month &&
          session.completedAt.year == currentDate.year) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Calculate completion rate
    final completionRate = completedSessions.length / _sessions.length;

    return {
      'totalSessions': completedSessions.length,
      'totalMinutes': totalMinutes,
      'averageSessionLength': averageSessionLength,
      'favoriteType': favoriteType,
      'streak': streak,
      'completionRate': completionRate,
    };
  }

  // Get recommended meditation based on user history
  MeditationType? getRecommendedMeditation() {
    if (_sessions.isEmpty) {
    return MeditationType.mindfulness;;
  }

    final recentSessions = getSessionsForLastDays(7);
    if (recentSessions.isEmpty) {
    return MeditationType.mindfulness;;
  }

    // Find the least used type in recent sessions
    final typeCount = <MeditationType, int>{};
    for (final session in recentSessions) {
      typeCount[session.type] = (typeCount[session.type] ?? 0) + 1;
    }

    final leastUsedType = typeCount.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;

    return leastUsedType;
  }

  // Check if user has meditated today
  bool hasMeditatedToday() {
    final today = DateTime.now();
    return _sessions.any(
      (session) =>
          session.completedAt.day == today.day &&
          session.completedAt.month == today.month &&
          session.completedAt.year == today.year &&
          session.completed,
    );
  }

  // Clear all meditation data
  Future<void> clearAllData() async {
    for (final session in _sessions) {
      await _databaseService.deleteMeditationSession(session.id);
    }
    _sessions.clear();
    _currentSession = null;
    notifyListeners();
  }
}
