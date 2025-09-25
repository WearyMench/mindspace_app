import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import '../services/language_service.dart';

class JournalProvider with ChangeNotifier {
  List<JournalEntry> _entries = [];
  JournalEntry? _draftEntry;
  final DatabaseService _databaseService = DatabaseService();

  List<JournalEntry> get entries => _entries;
  JournalEntry? get draftEntry => _draftEntry;

  // Inicializar datos desde la base de datos
  Future<void> initialize() async {
    await loadJournalEntries();
  }

  Future<void> loadJournalEntries() async {
    _entries = await _databaseService.getAllJournalEntries();
    notifyListeners();
  }

  // Get entries for a specific date range
  List<JournalEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      return entry.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.createdAt.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get entries for the last N days
  List<JournalEntry> getEntriesForLastDays(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return getEntriesForDateRange(startDate, endDate);
  }

  // Get entries by category
  List<JournalEntry> getEntriesByCategory(JournalCategory category) {
    return _entries.where((entry) => entry.category == category).toList();
  }

  // Search entries by text
  List<JournalEntry> searchEntries(String query) {
    if (query.isEmpty) {
      return _entries;
    }

    final lowercaseQuery = query.toLowerCase();
    return _entries.where((entry) {
      return entry.title.toLowerCase().contains(lowercaseQuery) ||
          entry.content.toLowerCase().contains(lowercaseQuery) ||
          entry.customTags.any(
            (tag) => tag.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  // Add a new journal entry
  Future<void> addJournalEntry(JournalEntry entry) async {
    await _databaseService.insertJournalEntry(entry);
    _entries.add(entry);
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  // Update an existing journal entry
  Future<void> updateJournalEntry(JournalEntry updatedEntry) async {
    await _databaseService.updateJournalEntry(updatedEntry);
    final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry.copyWith(updatedAt: DateTime.now());
      _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  // Delete a journal entry
  Future<void> deleteJournalEntry(String id) async {
    await _databaseService.deleteJournalEntry(id);
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  // Save a draft entry
  void saveDraftEntry(JournalEntry entry) {
    _draftEntry = entry;
    notifyListeners();
  }

  // Clear draft entry
  void clearDraftEntry() {
    _draftEntry = null;
    notifyListeners();
  }

  // Get journal statistics
  Map<String, dynamic> getJournalStatistics() {
    if (_entries.isEmpty) {
      return {
        'totalEntries': 0,
        'totalWords': 0,
        'averageWordsPerEntry': 0.0,
        'favoriteCategory': null,
        'writingStreak': 0,
        'mostUsedTags': <String>[],
      };
    }

    final totalWords = _entries.fold<int>(
      0,
      (sum, entry) => sum + entry.wordCount,
    );
    final averageWordsPerEntry = totalWords / _entries.length;

    // Find favorite category
    final categoryCount = <JournalCategory, int>{};
    for (final entry in _entries) {
      categoryCount[entry.category] = (categoryCount[entry.category] ?? 0) + 1;
    }
    final favoriteCategory = categoryCount.isNotEmpty
        ? categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    // Calculate writing streak
    int writingStreak = 0;
    final sortedEntries = List<JournalEntry>.from(_entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    DateTime currentDate = DateTime.now();
    for (final entry in sortedEntries) {
      if (entry.createdAt.day == currentDate.day &&
          entry.createdAt.month == currentDate.month &&
          entry.createdAt.year == currentDate.year) {
        writingStreak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Find most used tags
    final tagCount = <String, int>{};
    for (final entry in _entries) {
      for (final tag in entry.customTags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    final mostUsedTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = mostUsedTags.take(5).map((e) => e.key).toList();

    return {
      'totalEntries': _entries.length,
      'totalWords': totalWords,
      'averageWordsPerEntry': averageWordsPerEntry,
      'favoriteCategory': favoriteCategory,
      'writingStreak': writingStreak,
      'mostUsedTags': topTags,
    };
  }

  // Get entries by mood tags
  List<JournalEntry> getEntriesByMoodTag(MoodTag moodTag) {
    return _entries.where((entry) => entry.moodTags.contains(moodTag)).toList();
  }

  // Get recent entries (last 7 days)
  List<JournalEntry> getRecentEntries() {
    return getEntriesForLastDays(7);
  }

  // Check if user has written today
  bool hasWrittenToday() {
    final today = DateTime.now();
    return _entries.any(
      (entry) =>
          entry.createdAt.day == today.day &&
          entry.createdAt.month == today.month &&
          entry.createdAt.year == today.year,
    );
  }

  // Get writing prompts based on recent entries
  List<String> getWritingPrompts(LanguageService languageService) {
    final prompts = <String>[
      languageService.getLocalizedText('prompt_how_do_you_feel'),
      languageService.getLocalizedText('prompt_best_thing_today'),
      languageService.getLocalizedText('prompt_challenge_today'),
      languageService.getLocalizedText('prompt_grateful_today'),
      languageService.getLocalizedText('prompt_learned_about_self'),
      languageService.getLocalizedText('prompt_ideal_day'),
      languageService.getLocalizedText('prompt_what_worries_you'),
      languageService.getLocalizedText('prompt_what_makes_proud'),
      languageService.getLocalizedText('prompt_dream_for_future'),
      languageService.getLocalizedText('prompt_person_inspired_you'),
    ];

    // Shuffle and return first 3 prompts
    prompts.shuffle();
    return prompts.take(3).toList();
  }

  // Clear all journal data
  Future<void> clearAllData() async {
    for (final entry in _entries) {
      await _databaseService.deleteJournalEntry(entry.id);
    }
    _entries.clear();
    _draftEntry = null;
    notifyListeners();
  }
}
