import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';

enum SearchCategory {
  all('Todo'),
  mood('Estado de Ánimo'),
  meditation('Meditación'),
  journal('Diario');

  const SearchCategory(this.label);
  final String label;
}

enum SortBy {
  relevance('Relevancia'),
  dateDesc('Fecha (Reciente)'),
  dateAsc('Fecha (Antigua)'),
  alphabetical('Alfabético');

  const SortBy(this.label);
  final String label;
}

class SearchFilters {
  final SearchCategory category;
  final SortBy sortBy;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<MoodLevel>? moodLevels;
  final List<MeditationType>? meditationTypes;
  final List<JournalCategory>? journalCategories;
  final int? minRating;
  final int? maxRating;
  final bool? isPrivate;

  const SearchFilters({
    this.category = SearchCategory.all,
    this.sortBy = SortBy.relevance,
    this.startDate,
    this.endDate,
    this.moodLevels,
    this.meditationTypes,
    this.journalCategories,
    this.minRating,
    this.maxRating,
    this.isPrivate,
  });

  SearchFilters copyWith({
    SearchCategory? category,
    SortBy? sortBy,
    DateTime? startDate,
    DateTime? endDate,
    List<MoodLevel>? moodLevels,
    List<MeditationType>? meditationTypes,
    List<JournalCategory>? journalCategories,
    int? minRating,
    int? maxRating,
    bool? isPrivate,
  }) {
    return SearchFilters(
      category: category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      moodLevels: moodLevels ?? this.moodLevels,
      meditationTypes: meditationTypes ?? this.meditationTypes,
      journalCategories: journalCategories ?? this.journalCategories,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String preview;
  final DateTime date;
  final SearchCategory category;
  final dynamic originalData;
  final double relevanceScore;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.date,
    required this.category,
    required this.originalData,
    required this.relevanceScore,
  });
}

class SearchService {
  final DatabaseService _databaseService = DatabaseService();

  /// Buscar con filtros avanzados
  Future<List<SearchResult>> search(String query, SearchFilters filters) async {
    final results = <SearchResult>[];

    // Buscar en mood entries
    if (filters.category == SearchCategory.all ||
        filters.category == SearchCategory.mood) {
      final moodResults = await _searchMoodEntries(query, filters);
      results.addAll(moodResults);
    }

    // Buscar en meditation sessions
    if (filters.category == SearchCategory.all ||
        filters.category == SearchCategory.meditation) {
      final meditationResults = await _searchMeditationSessions(query, filters);
      results.addAll(meditationResults);
    }

    // Buscar en journal entries
    if (filters.category == SearchCategory.all ||
        filters.category == SearchCategory.journal) {
      final journalResults = await _searchJournalEntries(query, filters);
      results.addAll(journalResults);
    }

    // Ordenar resultados
    _sortResults(results, filters.sortBy);

    return results;
  }

  /// Buscar en mood entries
  Future<List<SearchResult>> _searchMoodEntries(
    String query,
    SearchFilters filters,
  ) async {
    final entries = await _databaseService.getAllMoodEntries();
    final results = <SearchResult>[];

    for (final entry in entries) {
      // Aplicar filtros de fecha
      if (!_isWithinDateRange(entry.date, filters.startDate, filters.endDate)) {
        continue;
      }

      // Aplicar filtros de mood level
      if (filters.moodLevels != null &&
          !filters.moodLevels!.contains(entry.overallMood)) {
        continue;
      }

      // Calcular relevancia
      final relevanceScore = _calculateMoodRelevance(entry, query);

      if (query.isEmpty || relevanceScore > 0) {
        results.add(
          SearchResult(
            id: entry.id,
            title: 'Estado de ánimo: ${entry.overallMood.label}',
            subtitle:
                '${entry.date.day}/${entry.date.month}/${entry.date.year}',
            preview: entry.notes ?? 'Sin notas',
            date: entry.date,
            category: SearchCategory.mood,
            originalData: entry,
            relevanceScore: relevanceScore,
          ),
        );
      }
    }

    return results;
  }

  /// Buscar en meditation sessions
  Future<List<SearchResult>> _searchMeditationSessions(
    String query,
    SearchFilters filters,
  ) async {
    final sessions = await _databaseService.getAllMeditationSessions();
    final results = <SearchResult>[];

    for (final session in sessions) {
      // Aplicar filtros de fecha
      if (!_isWithinDateRange(
        session.completedAt,
        filters.startDate,
        filters.endDate,
      )) {
        continue;
      }

      // Aplicar filtros de tipo de meditación
      if (filters.meditationTypes != null &&
          !filters.meditationTypes!.contains(session.type)) {
        continue;
      }

      // Aplicar filtros de rating
      if (filters.minRating != null &&
          (session.rating ?? 0) < filters.minRating!) {
        continue;
      }
      if (filters.maxRating != null &&
          (session.rating ?? 0) > filters.maxRating!) {
        continue;
      }

      // Calcular relevancia
      final relevanceScore = _calculateMeditationRelevance(session, query);

      if (query.isEmpty || relevanceScore > 0) {
        results.add(
          SearchResult(
            id: session.id,
            title: session.type.name,
            subtitle:
                '${session.duration.inMinutes} min • ${session.difficulty.label}',
            preview: session.notes ?? 'Sin notas',
            date: session.completedAt,
            category: SearchCategory.meditation,
            originalData: session,
            relevanceScore: relevanceScore,
          ),
        );
      }
    }

    return results;
  }

  /// Buscar en journal entries
  Future<List<SearchResult>> _searchJournalEntries(
    String query,
    SearchFilters filters,
  ) async {
    final entries = await _databaseService.getAllJournalEntries();
    final results = <SearchResult>[];

    for (final entry in entries) {
      // Aplicar filtros de fecha
      if (!_isWithinDateRange(
        entry.createdAt,
        filters.startDate,
        filters.endDate,
      )) {
        continue;
      }

      // Aplicar filtros de categoría de diario
      if (filters.journalCategories != null &&
          !filters.journalCategories!.contains(entry.category)) {
        continue;
      }

      // Aplicar filtros de privacidad
      if (filters.isPrivate != null && entry.isPrivate != filters.isPrivate) {
        continue;
      }

      // Calcular relevancia
      final relevanceScore = _calculateJournalRelevance(entry, query);

      if (query.isEmpty || relevanceScore > 0) {
        results.add(
          SearchResult(
            id: entry.id,
            title: entry.title,
            subtitle:
                '${entry.category.name} • ${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
            preview: entry.preview,
            date: entry.createdAt,
            category: SearchCategory.journal,
            originalData: entry,
            relevanceScore: relevanceScore,
          ),
        );
      }
    }

    return results;
  }

  /// Verificar si una fecha está dentro del rango
  bool _isWithinDateRange(
    DateTime date,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate != null && date.isBefore(startDate)) {
      return false;
    }
    if (endDate != null && date.isAfter(endDate.add(const Duration(days: 1)))) {
      return false;
    }
    return true;
  }

  /// Calcular relevancia para mood entries
  double _calculateMoodRelevance(MoodEntry entry, String query) {
    if (query.isEmpty) {
      return 1.0;
    }

    double score = 0.0;
    final lowercaseQuery = query.toLowerCase();

    // Buscar en mood level
    if (entry.overallMood.label.toLowerCase().contains(lowercaseQuery)) {
      score += 0.8;
    }

    // Buscar en notas
    if (entry.notes != null &&
        entry.notes!.toLowerCase().contains(lowercaseQuery)) {
      score += 0.6;
    }

    // Buscar en tags
    for (final tag in entry.tags) {
      if (tag.toLowerCase().contains(lowercaseQuery)) {
        score += 0.4;
      }
    }

    return score;
  }

  /// Calcular relevancia para meditation sessions
  double _calculateMeditationRelevance(
    MeditationSession session,
    String query,
  ) {
    if (query.isEmpty) {
      return 1.0;
    }

    double score = 0.0;
    final lowercaseQuery = query.toLowerCase();

    // Buscar en tipo de meditación
    if (session.type.name.toLowerCase().contains(lowercaseQuery)) {
      score += 0.8;
    }

    // Buscar en dificultad
    if (session.difficulty.label.toLowerCase().contains(lowercaseQuery)) {
      score += 0.6;
    }

    // Buscar en notas
    if (session.notes != null &&
        session.notes!.toLowerCase().contains(lowercaseQuery)) {
      score += 0.4;
    }

    return score;
  }

  /// Calcular relevancia para journal entries
  double _calculateJournalRelevance(JournalEntry entry, String query) {
    if (query.isEmpty) {
      return 1.0;
    }

    double score = 0.0;
    final lowercaseQuery = query.toLowerCase();

    // Buscar en título (mayor peso)
    if (entry.title.toLowerCase().contains(lowercaseQuery)) {
      score += 1.0;
    }

    // Buscar en contenido
    if (entry.content.toLowerCase().contains(lowercaseQuery)) {
      score += 0.8;
    }

    // Buscar en categoría
    if (entry.category.name.toLowerCase().contains(lowercaseQuery)) {
      score += 0.6;
    }

    // Buscar en tags personalizados
    for (final tag in entry.customTags) {
      if (tag.toLowerCase().contains(lowercaseQuery)) {
        score += 0.4;
      }
    }

    // Buscar en mood tags
    for (final moodTag in entry.moodTags) {
      if (moodTag.label.toLowerCase().contains(lowercaseQuery)) {
        score += 0.3;
      }
    }

    return score;
  }

  /// Ordenar resultados
  void _sortResults(List<SearchResult> results, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.relevance:
        results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
        break;
      case SortBy.dateDesc:
        results.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortBy.dateAsc:
        results.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortBy.alphabetical:
        results.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }

  /// Obtener sugerencias de búsqueda
  Future<List<String>> getSuggestions(String query) async {
    if (query.length < 2) {
      return [];
    }

    final suggestions = <String>{};
    final lowercaseQuery = query.toLowerCase();

    // Sugerencias de mood levels
    for (final mood in MoodLevel.values) {
      if (mood.label.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(mood.label);
      }
    }

    // Sugerencias de meditation types
    for (final type in MeditationType.values) {
      if (type.name.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(type.name);
      }
    }

    // Sugerencias de journal categories
    for (final category in JournalCategory.values) {
      if (category.name.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(category.name);
      }
    }

    // Obtener sugerencias de contenido de journal
    final journalEntries = await _databaseService.getAllJournalEntries();
    for (final entry in journalEntries.take(50)) {
      // Limitar para performance
      // Títulos
      if (entry.title.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(entry.title);
      }

      // Tags personalizados
      for (final tag in entry.customTags) {
        if (tag.toLowerCase().contains(lowercaseQuery)) {
          suggestions.add(tag);
        }
      }
    }

    return suggestions.take(10).toList();
  }

  /// Buscar por fecha específica
  Future<List<SearchResult>> searchByDate(DateTime date) async {
    final filters = SearchFilters(
      startDate: DateTime(date.year, date.month, date.day),
      endDate: DateTime(date.year, date.month, date.day, 23, 59, 59),
    );

    return await search('', filters);
  }

  /// Buscar entradas recientes
  Future<List<SearchResult>> getRecentEntries({int limit = 20}) async {
    final filters = SearchFilters(sortBy: SortBy.dateDesc);
    final results = await search('', filters);

    return results.take(limit).toList();
  }

  /// Buscar por categoría específica
  Future<List<SearchResult>> searchByCategory(SearchCategory category) async {
    final filters = SearchFilters(category: category, sortBy: SortBy.dateDesc);

    return await search('', filters);
  }
}
