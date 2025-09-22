import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../services/database_service.dart';

class MoodProvider with ChangeNotifier {
  List<MoodEntry> _moodEntries = [];
  MoodEntry? _todayMood;
  final DatabaseService _databaseService = DatabaseService();

  List<MoodEntry> get moodEntries => _moodEntries;
  MoodEntry? get todayMood => _todayMood;

  // Inicializar datos desde la base de datos
  Future<void> initialize() async {
    await loadMoodEntries();
  }

  Future<void> loadMoodEntries() async {
    _moodEntries = await _databaseService.getAllMoodEntries();
    _updateTodayMood();
    notifyListeners();
  }

  // Get mood entries for a specific date range
  List<MoodEntry> getMoodEntriesForDateRange(DateTime start, DateTime end) {
    return _moodEntries.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get mood entries for the last N days
  List<MoodEntry> getMoodEntriesForLastDays(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return getMoodEntriesForDateRange(startDate, endDate);
  }

  // Get today's mood entry
  MoodEntry? getTodayMood() {
    final today = DateTime.now();
    return _moodEntries.firstWhere(
      (entry) =>
          entry.date.day == today.day &&
          entry.date.month == today.month &&
          entry.date.year == today.year,
      orElse: () => throw StateError('No mood entry found for today'),
    );
  }

  // Add a new mood entry
  Future<void> addMoodEntry(MoodEntry entry) async {
    await _databaseService.insertMoodEntry(entry);
    _moodEntries.add(entry);
    _moodEntries.sort((a, b) => b.date.compareTo(a.date));

    // Check if this is today's entry
    final today = DateTime.now();
    if (entry.date.day == today.day &&
        entry.date.month == today.month &&
        entry.date.year == today.year) {
      _todayMood = entry;
    }

    notifyListeners();
  }

  // Update an existing mood entry
  Future<void> updateMoodEntry(MoodEntry updatedEntry) async {
    await _databaseService.updateMoodEntry(updatedEntry);
    final index = _moodEntries.indexWhere(
      (entry) => entry.id == updatedEntry.id,
    );
    if (index != -1) {
      _moodEntries[index] = updatedEntry;
      _moodEntries.sort((a, b) => b.date.compareTo(a.date));

      // Update today's mood if this is today's entry
      final today = DateTime.now();
      if (updatedEntry.date.day == today.day &&
          updatedEntry.date.month == today.month &&
          updatedEntry.date.year == today.year) {
        _todayMood = updatedEntry;
      }

      notifyListeners();
    }
  }

  // Delete a mood entry
  Future<void> deleteMoodEntry(String id) async {
    await _databaseService.deleteMoodEntry(id);
    _moodEntries.removeWhere((entry) => entry.id == id);

    // Check if we deleted today's entry
    if (_todayMood?.id == id) {
      _todayMood = null;
    }

    notifyListeners();
  }

  void _updateTodayMood() {
    final today = DateTime.now();
    try {
      _todayMood = _moodEntries.firstWhere(
        (entry) =>
            entry.date.day == today.day &&
            entry.date.month == today.month &&
            entry.date.year == today.year,
      );
    } catch (e) {
      _todayMood = null;
    }
  }

  // Get mood statistics
  Map<String, dynamic> getMoodStatistics() {
    if (_moodEntries.isEmpty) {
      return {
        'averageMood': 0.0,
        'totalEntries': 0,
        'moodDistribution': <MoodLevel, int>{},
        'streak': 0,
      };
    }

    final totalMood = _moodEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.overallMood.value,
    );
    final averageMood = totalMood / _moodEntries.length;

    final moodDistribution = <MoodLevel, int>{};
    for (final mood in MoodLevel.values) {
      moodDistribution[mood] = _moodEntries
          .where((entry) => entry.overallMood == mood)
          .length;
    }

    // Calculate streak (consecutive days with mood entries)
    int streak = 0;
    final sortedEntries = List<MoodEntry>.from(_moodEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

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

    return {
      'averageMood': averageMood,
      'totalEntries': _moodEntries.length,
      'moodDistribution': moodDistribution,
      'streak': streak,
    };
  }

  // Check if user has logged mood today
  bool hasLoggedMoodToday() {
    final today = DateTime.now();
    return _moodEntries.any(
      (entry) =>
          entry.date.day == today.day &&
          entry.date.month == today.month &&
          entry.date.year == today.year,
    );
  }

  // Clear all mood data
  Future<void> clearAllData() async {
    for (final entry in _moodEntries) {
      await _databaseService.deleteMoodEntry(entry.id);
    }
    _moodEntries.clear();
    notifyListeners();
  }
}
