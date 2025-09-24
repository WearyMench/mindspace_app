import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';
import 'language_service.dart';

class AdvancedAnalyticsService {
  // Análisis de correlaciones entre diferentes métricas
  static Future<CorrelationAnalysis> analyzeCorrelations({
    required List<MoodEntry> moods,
    required List<MeditationSession> sessions,
    required List<JournalEntry> journals,
    LanguageService? languageService,
  }) async {
    final correlations = <String, double>{};

    // Correlación meditación-estado de ánimo
    correlations['meditation_mood'] = _calculateMeditationMoodCorrelation(
      moods,
      sessions,
    );

    // Correlación diario-estado de ánimo
    correlations['journal_mood'] = _calculateJournalMoodCorrelation(
      moods,
      journals,
    );

    // Correlación frecuencia de uso-estado de ánimo
    correlations['usage_mood'] = _calculateUsageMoodCorrelation(
      moods,
      sessions,
      journals,
    );

    // Correlación horario-estado de ánimo
    correlations['time_mood'] = _calculateTimeMoodCorrelation(moods);

    return CorrelationAnalysis(
      correlations: correlations,
      strongestCorrelation: _findStrongestCorrelation(correlations),
      insights: _generateCorrelationInsights(correlations, languageService),
    );
  }

  // Análisis de patrones temporales
  static Future<TemporalPatterns> analyzeTemporalPatterns({
    required List<MoodEntry> moods,
    required List<MeditationSession> sessions,
    required List<JournalEntry> journals,
    LanguageService? languageService,
  }) async {
    final patterns = <String, Map<String, double>>{};

    // Patrones por día de la semana
    patterns['weekly'] = _analyzeWeeklyPatterns(
      moods,
      sessions,
      journals,
      languageService,
    );

    // Patrones por hora del día
    patterns['hourly'] = _analyzeHourlyPatterns(moods, sessions, journals);

    // Patrones estacionales
    patterns['seasonal'] = _analyzeSeasonalPatterns(moods, sessions, journals);

    return TemporalPatterns(
      patterns: patterns,
      bestDays: _findBestDays(patterns['weekly']!, languageService),
      bestHours: _findBestHours(patterns['hourly']!),
      seasonalInsights: _generateSeasonalInsights(
        patterns['seasonal']!,
        languageService,
      ),
    );
  }

  // Análisis de progreso y tendencias
  static Future<ProgressAnalysis> analyzeProgress({
    required List<MoodEntry> moods,
    required List<MeditationSession> sessions,
    required List<JournalEntry> journals,
    LanguageService? languageService,
  }) async {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));

    // Filtrar datos de los últimos 30 días
    final recentMoods = moods.where((m) => m.date.isAfter(last30Days)).toList();
    final recentSessions = sessions
        .where((s) => s.completedAt.isAfter(last30Days))
        .toList();
    final recentJournals = journals
        .where((j) => j.createdAt.isAfter(last30Days))
        .toList();

    // Calcular métricas de progreso
    final moodProgress = _calculateMoodProgress(recentMoods);
    final meditationProgress = _calculateMeditationProgress(recentSessions);
    final journalProgress = _calculateJournalProgress(recentJournals);

    // Calcular tendencias
    final trends = _calculateTrends(
      recentMoods,
      recentSessions,
      recentJournals,
    );

    return ProgressAnalysis(
      moodProgress: moodProgress,
      meditationProgress: meditationProgress,
      journalProgress: journalProgress,
      overallProgress: _calculateOverallProgress(
        moodProgress,
        meditationProgress,
        journalProgress,
      ),
      trends: trends,
      achievements: _identifyAchievements(
        moodProgress,
        meditationProgress,
        journalProgress,
        languageService,
      ),
      recommendations: _generateProgressRecommendations(
        moodProgress,
        meditationProgress,
        journalProgress,
      ),
    );
  }

  // Análisis de bienestar integral
  static Future<WellnessAnalysis> analyzeWellness({
    required List<MoodEntry> moods,
    required List<MeditationSession> sessions,
    required List<JournalEntry> journals,
    LanguageService? languageService,
  }) async {
    final wellnessScore = _calculateWellnessScore(moods, sessions, journals);
    final wellnessFactors = _analyzeWellnessFactors(moods, sessions, journals);
    final riskFactors = _identifyRiskFactors(
      moods,
      sessions,
      journals,
      languageService,
    );
    final protectiveFactors = _identifyProtectiveFactors(
      moods,
      sessions,
      journals,
      languageService,
    );

    return WellnessAnalysis(
      overallScore: wellnessScore,
      factors: wellnessFactors,
      riskFactors: riskFactors,
      protectiveFactors: protectiveFactors,
      recommendations: _generateWellnessRecommendations(
        wellnessScore,
        riskFactors,
        protectiveFactors,
      ),
      trends: _analyzeWellnessTrends(moods, sessions, journals),
    );
  }

  // Métodos de cálculo de correlaciones
  static double _calculateMeditationMoodCorrelation(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
  ) {
    if (moods.length < 3 || sessions.length < 2) return 0.0;

    double correlation = 0.0;
    int validComparisons = 0;

    for (final session in sessions) {
      final sameDayMood = moods
          .where((m) => _isSameDay(m.date, session.completedAt))
          .firstOrNull;

      if (sameDayMood != null) {
        final previousDayMood = moods
            .where(
              (m) => _isSameDay(
                m.date,
                session.completedAt.subtract(const Duration(days: 1)),
              ),
            )
            .firstOrNull;

        if (previousDayMood != null) {
          final moodImprovement =
              sameDayMood.overallMood.value - previousDayMood.overallMood.value;
          if (moodImprovement > 0) {
            correlation += 1.0;
          }
          validComparisons++;
        }
      }
    }

    return validComparisons > 0 ? correlation / validComparisons : 0.0;
  }

  static double _calculateJournalMoodCorrelation(
    List<MoodEntry> moods,
    List<JournalEntry> journals,
  ) {
    if (moods.length < 3 || journals.length < 2) return 0.0;

    double correlation = 0.0;
    int validComparisons = 0;

    for (final journal in journals) {
      final sameDayMood = moods
          .where((m) => _isSameDay(m.date, journal.createdAt))
          .firstOrNull;

      if (sameDayMood != null) {
        final previousDayMood = moods
            .where(
              (m) => _isSameDay(
                m.date,
                journal.createdAt.subtract(const Duration(days: 1)),
              ),
            )
            .firstOrNull;

        if (previousDayMood != null) {
          final moodImprovement =
              sameDayMood.overallMood.value - previousDayMood.overallMood.value;
          if (moodImprovement > 0) {
            correlation += 1.0;
          }
          validComparisons++;
        }
      }
    }

    return validComparisons > 0 ? correlation / validComparisons : 0.0;
  }

  static double _calculateUsageMoodCorrelation(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
  ) {
    if (moods.length < 7) return 0.0;

    final dailyUsage = <DateTime, int>{};
    final dailyMoods = <DateTime, double>{};

    // Contar uso diario
    for (final session in sessions) {
      final day = DateTime(
        session.completedAt.year,
        session.completedAt.month,
        session.completedAt.day,
      );
      dailyUsage[day] = (dailyUsage[day] ?? 0) + 1;
    }

    for (final journal in journals) {
      final day = DateTime(
        journal.createdAt.year,
        journal.createdAt.month,
        journal.createdAt.day,
      );
      dailyUsage[day] = (dailyUsage[day] ?? 0) + 1;
    }

    // Promedio de estado de ánimo por día
    for (final mood in moods) {
      final day = DateTime(mood.date.year, mood.date.month, mood.date.day);
      dailyMoods[day] = mood.overallMood.value.toDouble();
    }

    // Calcular correlación
    double correlation = 0.0;
    int validComparisons = 0;

    for (final day in dailyUsage.keys) {
      if (dailyMoods.containsKey(day)) {
        final usage = dailyUsage[day]!;
        final mood = dailyMoods[day]!;

        if (usage > 0 && mood > 0) {
          correlation += usage * mood;
          validComparisons++;
        }
      }
    }

    return validComparisons > 0 ? correlation / validComparisons : 0.0;
  }

  static double _calculateTimeMoodCorrelation(List<MoodEntry> moods) {
    if (moods.length < 7) return 0.0;

    final hourlyMoods = <int, List<double>>{};

    for (final mood in moods) {
      final hour = mood.date.hour;
      hourlyMoods[hour] = hourlyMoods[hour] ?? [];
      hourlyMoods[hour]!.add(mood.overallMood.value.toDouble());
    }

    // Encontrar la hora con mejor estado de ánimo promedio
    double bestHourScore = 0.0;
    for (final hour in hourlyMoods.keys) {
      final avgMood =
          hourlyMoods[hour]!.reduce((a, b) => a + b) /
          hourlyMoods[hour]!.length;
      if (avgMood > bestHourScore) {
        bestHourScore = avgMood;
      }
    }

    return bestHourScore / 5.0; // Normalizar a 0-1
  }

  // Métodos de análisis de patrones temporales
  static Map<String, double> _analyzeWeeklyPatterns(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
    LanguageService? languageService,
  ) {
    final weeklyData = <String, List<double>>{};
    final days = [
      languageService?.getLocalizedText('monday') ?? 'Lunes',
      languageService?.getLocalizedText('tuesday') ?? 'Martes',
      languageService?.getLocalizedText('wednesday') ?? 'Miércoles',
      languageService?.getLocalizedText('thursday') ?? 'Jueves',
      languageService?.getLocalizedText('friday') ?? 'Viernes',
      languageService?.getLocalizedText('saturday') ?? 'Sábado',
      languageService?.getLocalizedText('sunday') ?? 'Domingo',
    ];

    for (int i = 0; i < 7; i++) {
      weeklyData[days[i]] = [];
    }

    // Analizar estado de ánimo por día de la semana
    for (final mood in moods) {
      final dayOfWeek = mood.date.weekday - 1; // 0 = Lunes, 6 = Domingo
      weeklyData[days[dayOfWeek]]!.add(mood.overallMood.value.toDouble());
    }

    // Calcular promedios
    final averages = <String, double>{};
    for (final day in days) {
      if (weeklyData[day]!.isNotEmpty) {
        averages[day] =
            weeklyData[day]!.reduce((a, b) => a + b) / weeklyData[day]!.length;
      } else {
        averages[day] = 0.0;
      }
    }

    return averages;
  }

  static Map<String, double> _analyzeHourlyPatterns(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
  ) {
    final hourlyData = <int, List<double>>{};

    for (int i = 0; i < 24; i++) {
      hourlyData[i] = [];
    }

    // Analizar estado de ánimo por hora
    for (final mood in moods) {
      final hour = mood.date.hour;
      hourlyData[hour]!.add(mood.overallMood.value.toDouble());
    }

    // Calcular promedios
    final averages = <String, double>{};
    for (int i = 0; i < 24; i++) {
      if (hourlyData[i]!.isNotEmpty) {
        averages[i.toString()] =
            hourlyData[i]!.reduce((a, b) => a + b) / hourlyData[i]!.length;
      } else {
        averages[i.toString()] = 0.0;
      }
    }

    return averages;
  }

  static Map<String, double> _analyzeSeasonalPatterns(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
  ) {
    final monthlyData = <int, List<double>>{};

    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = [];
    }

    // Analizar estado de ánimo por mes
    for (final mood in moods) {
      final month = mood.date.month;
      monthlyData[month]!.add(mood.overallMood.value.toDouble());
    }

    // Calcular promedios
    final averages = <String, double>{};
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    for (int i = 1; i <= 12; i++) {
      if (monthlyData[i]!.isNotEmpty) {
        averages[months[i - 1]] =
            monthlyData[i]!.reduce((a, b) => a + b) / monthlyData[i]!.length;
      } else {
        averages[months[i - 1]] = 0.0;
      }
    }

    return averages;
  }

  // Métodos de análisis de progreso
  static ProgressMetrics _calculateMoodProgress(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return ProgressMetrics(
        current: 0.0,
        previous: 0.0,
        change: 0.0,
        trend: ProgressTrend.stable,
      );
    }

    final current =
        moods
            .map((m) => m.overallMood.value.toDouble())
            .reduce((a, b) => a + b) /
        moods.length;
    final previous = moods.length > 7
        ? moods
                  .skip(7)
                  .map((m) => m.overallMood.value.toDouble())
                  .reduce((a, b) => a + b) /
              (moods.length - 7)
        : current;

    final change = current - previous;
    final trend = change > 0.2
        ? ProgressTrend.improving
        : change < -0.2
        ? ProgressTrend.declining
        : ProgressTrend.stable;

    return ProgressMetrics(
      current: current,
      previous: previous,
      change: change,
      trend: trend,
    );
  }

  static ProgressMetrics _calculateMeditationProgress(
    List<MeditationSession> sessions,
  ) {
    if (sessions.isEmpty) {
      return ProgressMetrics(
        current: 0.0,
        previous: 0.0,
        change: 0.0,
        trend: ProgressTrend.stable,
      );
    }

    final current = sessions.length.toDouble();
    final previous = sessions.length > 7
        ? (sessions.length - 7).toDouble()
        : 0.0;

    final change = current - previous;
    final trend = change > 0
        ? ProgressTrend.improving
        : change < 0
        ? ProgressTrend.declining
        : ProgressTrend.stable;

    return ProgressMetrics(
      current: current,
      previous: previous,
      change: change,
      trend: trend,
    );
  }

  static ProgressMetrics _calculateJournalProgress(
    List<JournalEntry> journals,
  ) {
    if (journals.isEmpty) {
      return ProgressMetrics(
        current: 0.0,
        previous: 0.0,
        change: 0.0,
        trend: ProgressTrend.stable,
      );
    }

    final current = journals.length.toDouble();
    final previous = journals.length > 7
        ? (journals.length - 7).toDouble()
        : 0.0;

    final change = current - previous;
    final trend = change > 0
        ? ProgressTrend.improving
        : change < 0
        ? ProgressTrend.declining
        : ProgressTrend.stable;

    return ProgressMetrics(
      current: current,
      previous: previous,
      change: change,
      trend: trend,
    );
  }

  // Métodos auxiliares
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String _findStrongestCorrelation(Map<String, double> correlations) {
    if (correlations.isEmpty) return 'Ninguna';

    String strongest = correlations.keys.first;
    double maxValue = correlations[strongest]!;

    for (final entry in correlations.entries) {
      if (entry.value > maxValue) {
        maxValue = entry.value;
        strongest = entry.key;
      }
    }

    return strongest;
  }

  static List<String> _generateCorrelationInsights(
    Map<String, double> correlations,
    LanguageService? languageService,
  ) {
    final insights = <String>[];

    if (correlations['meditation_mood']! > 0.5) {
      insights.add(
        languageService?.getLocalizedText('insight_meditation_positive') ??
            'La meditación tiene un impacto positivo en tu estado de ánimo',
      );
    }

    if (correlations['journal_mood']! > 0.3) {
      insights.add(
        languageService?.getLocalizedText('insight_journal_emotions') ??
            'Escribir en tu diario te ayuda a procesar emociones',
      );
    }

    if (correlations['usage_mood']! > 0.4) {
      insights.add(
        languageService?.getLocalizedText('insight_app_usage_wellness') ??
            'El uso frecuente de la app mejora tu bienestar general',
      );
    }

    if (correlations['time_mood']! > 0.6) {
      insights.add(
        languageService?.getLocalizedText('insight_specific_schedules') ??
            'Tienes horarios específicos donde te sientes mejor',
      );
    }

    return insights;
  }

  static List<String> _findBestDays(
    Map<String, double> weeklyPatterns,
    LanguageService? languageService,
  ) {
    final sortedDays = weeklyPatterns.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedDays.take(3).map((e) => e.key).toList();
  }

  static List<String> _findBestHours(Map<String, double> hourlyPatterns) {
    final sortedHours = hourlyPatterns.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHours.take(3).map((e) => '${e.key}:00').toList();
  }

  static List<String> _generateSeasonalInsights(
    Map<String, double> seasonalPatterns,
    LanguageService? languageService,
  ) {
    final insights = <String>[];

    final sortedMonths = seasonalPatterns.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedMonths.isNotEmpty) {
      final bestMonth = sortedMonths.first;
      final message =
          languageService?.getLocalizedText('feel_better_in') ??
          'Te sientes mejor en';
      insights.add('$message ${bestMonth.key}');
    }

    return insights;
  }

  static double _calculateOverallProgress(
    ProgressMetrics mood,
    ProgressMetrics meditation,
    ProgressMetrics journal,
  ) {
    final moodScore = mood.change.clamp(-1.0, 1.0);
    final meditationScore = meditation.change.clamp(-1.0, 1.0);
    final journalScore = journal.change.clamp(-1.0, 1.0);

    return (moodScore + meditationScore + journalScore) / 3.0;
  }

  static Map<String, dynamic> _calculateTrends(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
  ) {
    return {
      'mood_trend': moods.isNotEmpty ? moods.last.overallMood.value : 0.0,
      'meditation_frequency': sessions.length,
      'journal_consistency': journals.length,
    };
  }

  static List<String> _identifyAchievements(
    ProgressMetrics mood,
    ProgressMetrics meditation,
    ProgressMetrics journal,
    LanguageService? languageService,
  ) {
    final achievements = <String>[];

    if (mood.trend == ProgressTrend.improving) {
      achievements.add(
        languageService?.getLocalizedText('achievement_mood_improvement') ??
            'Mejora en estado de ánimo',
      );
    }

    if (meditation.trend == ProgressTrend.improving) {
      achievements.add(
        languageService?.getLocalizedText(
              'achievement_meditation_consistency',
            ) ??
            'Mayor consistencia en meditación',
      );
    }

    if (journal.trend == ProgressTrend.improving) {
      achievements.add(
        languageService?.getLocalizedText('achievement_journal_activity') ??
            'Más actividad en el diario',
      );
    }

    return achievements;
  }

  static List<String> _generateProgressRecommendations(
    ProgressMetrics mood,
    ProgressMetrics meditation,
    ProgressMetrics journal,
  ) {
    final recommendations = <String>[];

    if (mood.trend == ProgressTrend.declining) {
      recommendations.add('Considera aumentar la frecuencia de meditación');
    }

    if (meditation.trend == ProgressTrend.declining) {
      recommendations.add('Intenta meditar al menos 5 minutos al día');
    }

    if (journal.trend == ProgressTrend.declining) {
      recommendations.add('Escribe en tu diario al menos 3 veces por semana');
    }

    return recommendations;
  }

  static double _calculateWellnessScore(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
  ) {
    double score = 50.0; // Base score

    if (moods.isNotEmpty) {
      final avgMood =
          moods
              .map((m) => m.overallMood.value.toDouble())
              .reduce((a, b) => a + b) /
          moods.length;
      score += (avgMood - 3.0) * 10; // -20 to +20
    }

    score += sessions.length * 2; // +2 per session
    score += journals.length * 1.5; // +1.5 per journal entry

    return score.clamp(0.0, 100.0);
  }

  static Map<String, double> _analyzeWellnessFactors(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
  ) {
    return {
      'mood_consistency': moods.length / 30.0, // Normalized to 30 days
      'meditation_frequency': sessions.length / 30.0,
      'journal_activity': journals.length / 30.0,
      'overall_engagement':
          (moods.length + sessions.length + journals.length) / 90.0,
    };
  }

  static List<String> _identifyRiskFactors(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
    LanguageService? languageService,
  ) {
    final riskFactors = <String>[];

    if (moods.isNotEmpty) {
      final recentMoods = moods
          .take(7)
          .map((m) => m.overallMood.value)
          .toList();
      final avgRecentMood =
          recentMoods.reduce((a, b) => a + b) / recentMoods.length;

      if (avgRecentMood < 2.5) {
        riskFactors.add(
          languageService?.getLocalizedText('risk_recent_low_mood') ??
              'Estado de ánimo bajo reciente',
        );
      }
    }

    if (sessions.length < 3) {
      riskFactors.add(
        languageService?.getLocalizedText('risk_low_meditation_frequency') ??
            'Baja frecuencia de meditación',
      );
    }

    if (journals.length < 5) {
      riskFactors.add(
        languageService?.getLocalizedText('risk_low_journal_activity') ??
            'Poca actividad en el diario',
      );
    }

    return riskFactors;
  }

  static List<String> _identifyProtectiveFactors(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
    LanguageService? languageService,
  ) {
    final protectiveFactors = <String>[];

    if (sessions.length >= 7) {
      protectiveFactors.add(
        languageService?.getLocalizedText('protective_regular_meditation') ??
            'Práctica regular de meditación',
      );
    }

    if (journals.length >= 10) {
      protectiveFactors.add(
        languageService?.getLocalizedText('protective_regular_journaling') ??
            'Reflexión regular en el diario',
      );
    }

    if (moods.isNotEmpty) {
      final avgMood =
          moods.map((m) => m.overallMood.value).reduce((a, b) => a + b) /
          moods.length;
      if (avgMood >= 4.0) {
        protectiveFactors.add(
          languageService?.getLocalizedText('protective_positive_mood') ??
              'Estado de ánimo positivo general',
        );
      }
    }

    return protectiveFactors;
  }

  static List<String> _generateWellnessRecommendations(
    double score,
    List<String> riskFactors,
    List<String> protectiveFactors,
  ) {
    final recommendations = <String>[];

    if (score < 60) {
      recommendations.add(
        'Considera aumentar la frecuencia de tus actividades de bienestar',
      );
    }

    if (riskFactors.contains('Estado de ánimo bajo reciente')) {
      recommendations.add(
        'Prueba técnicas de relajación o habla con un profesional',
      );
    }

    if (riskFactors.contains('Baja frecuencia de meditación')) {
      recommendations.add('Intenta meditar al menos 5 minutos diarios');
    }

    if (riskFactors.contains('Poca actividad en el diario')) {
      recommendations.add('Escribe en tu diario al menos 3 veces por semana');
    }

    return recommendations;
  }

  static Map<String, dynamic> _analyzeWellnessTrends(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
    List<JournalEntry> journals,
  ) {
    return {
      'mood_trend': moods.length > 7
          ? _calculateTrend(
              moods.take(7).map((m) => m.overallMood.value.toDouble()).toList(),
            )
          : 0.0,
      'meditation_trend': sessions.length > 7
          ? _calculateTrend(
              sessions
                  .take(7)
                  .map((s) => s.duration.inMinutes.toDouble())
                  .toList(),
            )
          : 0.0,
      'journal_trend': journals.length > 7
          ? _calculateTrend(List.filled(7, 1.0))
          : 0.0,
    };
  }

  static double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    final n = values.length;

    for (int i = 0; i < n; i++) {
      sumX += i.toDouble();
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }

    return (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  }
}

// Modelos de datos para analytics avanzados
class CorrelationAnalysis {
  final Map<String, double> correlations;
  final String strongestCorrelation;
  final List<String> insights;

  CorrelationAnalysis({
    required this.correlations,
    required this.strongestCorrelation,
    required this.insights,
  });
}

class TemporalPatterns {
  final Map<String, Map<String, double>> patterns;
  final List<String> bestDays;
  final List<String> bestHours;
  final List<String> seasonalInsights;

  TemporalPatterns({
    required this.patterns,
    required this.bestDays,
    required this.bestHours,
    required this.seasonalInsights,
  });
}

class ProgressAnalysis {
  final ProgressMetrics moodProgress;
  final ProgressMetrics meditationProgress;
  final ProgressMetrics journalProgress;
  final double overallProgress;
  final Map<String, dynamic> trends;
  final List<String> achievements;
  final List<String> recommendations;

  ProgressAnalysis({
    required this.moodProgress,
    required this.meditationProgress,
    required this.journalProgress,
    required this.overallProgress,
    required this.trends,
    required this.achievements,
    required this.recommendations,
  });
}

class WellnessAnalysis {
  final double overallScore;
  final Map<String, double> factors;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final List<String> recommendations;
  final Map<String, dynamic> trends;

  WellnessAnalysis({
    required this.overallScore,
    required this.factors,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.recommendations,
    required this.trends,
  });
}

class ProgressMetrics {
  final double current;
  final double previous;
  final double change;
  final ProgressTrend trend;

  ProgressMetrics({
    required this.current,
    required this.previous,
    required this.change,
    required this.trend,
  });
}

enum ProgressTrend { improving, declining, stable }
