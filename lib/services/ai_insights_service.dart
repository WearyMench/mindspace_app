import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';
import '../services/user_preferences_service.dart';
import '../services/language_service.dart';

class AIInsightsService {
  // Análisis predictivo del estado de ánimo
  static Future<MoodPrediction> predictMoodTrend({
    required List<MoodEntry> recentMoods,
    required List<MeditationSession> recentSessions,
    required List<JournalEntry> recentJournals,
    required LanguageService languageService,
  }) async {
    if (recentMoods.length < 3) {
      return MoodPrediction(
        trend: MoodTrend.stable,
        confidence: 0.3,
        recommendation: languageService.getLocalizedText('rec_need_more_data'),
        factors: [],
        nextWeekPrediction: 3.0,
      );
    }

    // Calcular tendencia basada en los últimos 7 días
    final lastWeekMoods = recentMoods.take(7).toList();
    final moodValues = lastWeekMoods
        .map((m) => m.overallMood.value.toDouble())
        .toList();

    // Calcular pendiente de la tendencia
    final slope = _calculateSlope(moodValues);

    // Determinar tendencia
    MoodTrend trend;
    double confidence;
    String recommendation;
    List<String> factors = [];

    if (slope > 0.2) {
      trend = MoodTrend.improving;
      confidence = 0.8;
      recommendation = languageService.getLocalizedText('rec_mood_improving');
      factors.add(languageService.getLocalizedText('factor_positive_trend'));
    } else if (slope < -0.2) {
      trend = MoodTrend.declining;
      confidence = 0.7;
      recommendation = languageService.getLocalizedText('rec_mood_declining');
      factors.add(languageService.getLocalizedText('factor_negative_trend'));
    } else {
      trend = MoodTrend.stable;
      confidence = 0.6;
      recommendation = languageService.getLocalizedText('rec_mood_stable');
      factors.add(languageService.getLocalizedText('factor_stable_mood'));
    }

    // Analizar correlaciones
    final meditationCorrelation = _analyzeMeditationCorrelation(
      recentMoods,
      recentSessions,
    );
    final journalCorrelation = _analyzeJournalCorrelation(
      recentMoods,
      recentJournals,
    );

    if (meditationCorrelation > 0.5) {
      factors.add(languageService.getLocalizedText('factor_meditation_helps'));
      if (trend == MoodTrend.declining) {
        recommendation +=
            ' ' +
            languageService.getLocalizedText('rec_consider_meditating_more');
      }
    }

    if (journalCorrelation > 0.3) {
      factors.add(languageService.getLocalizedText('factor_journaling_helps'));
      if (trend == MoodTrend.declining) {
        recommendation +=
            ' ' + languageService.getLocalizedText('rec_consider_journaling');
      }
    }

    // Analizar patrones estacionales
    final seasonalPattern = _analyzeSeasonalPattern(recentMoods);
    if (seasonalPattern.isNotEmpty) {
      factors.add(
        seasonalPattern == 'december_better'
            ? languageService.getLocalizedText('factor_december_better')
            : languageService.getLocalizedText('factor_january_better'),
      );
    }

    return MoodPrediction(
      trend: trend,
      confidence: confidence,
      recommendation: recommendation,
      factors: factors,
      nextWeekPrediction: _predictNextWeekMood(moodValues, slope),
    );
  }

  // Generar recomendaciones personalizadas
  static Future<List<PersonalizedRecommendation>> generateRecommendations({
    required UserPreferences userPreferences,
    required List<MoodEntry> recentMoods,
    required List<MeditationSession> recentSessions,
    required List<JournalEntry> recentJournals,
    required LanguageService languageService,
  }) async {
    final recommendations = <PersonalizedRecommendation>[];

    // Recomendación basada en objetivo del usuario
    if (userPreferences.userGoal.isNotEmpty) {
      recommendations.add(
        _createGoalBasedRecommendation(
          userPreferences.userGoal,
          languageService,
        ),
      );
    }

    // Recomendación basada en patrones de meditación
    if (recentSessions.isEmpty) {
      recommendations.add(
        PersonalizedRecommendation(
          type: RecommendationType.meditation,
          title: languageService.getLocalizedText(
            'rec_start_meditation_practice_title',
          ),
          description: languageService
              .getLocalizedText('rec_start_meditation_practice_description')
              .replaceFirst('{goal}', userPreferences.userGoal),
          priority: Priority.high,
          actionText: languageService.getLocalizedText('action_meditate_now'),
          estimatedTime: '5-10 ' + languageService.getLocalizedText('minutes'),
          benefits: [
            languageService.getLocalizedText('benefit_reduce_stress'),
            languageService.getLocalizedText('benefit_improve_focus'),
            languageService.getLocalizedText('benefit_increase_self_awareness'),
          ],
        ),
      );
    } else if (recentSessions.length < 3) {
      recommendations.add(
        PersonalizedRecommendation(
          type: RecommendationType.meditation,
          title: languageService.getLocalizedText(
            'rec_maintain_meditation_practice_title',
          ),
          description: languageService
              .getLocalizedText('rec_maintain_meditation_practice_description')
              .replaceFirst('{count}', recentSessions.length.toString()),
          priority: Priority.medium,
          actionText: languageService.getLocalizedText(
            'action_continue_practice',
          ),
          estimatedTime: '10-15 ' + languageService.getLocalizedText('minutes'),
          benefits: [
            languageService.getLocalizedText('benefit_build_habit'),
            languageService.getLocalizedText('benefit_improve_consistency'),
            languageService.getLocalizedText('benefit_increase_benefits'),
          ],
        ),
      );
    }

    // Recomendación basada en estado de ánimo
    if (recentMoods.isNotEmpty) {
      final lastMood = recentMoods.first.overallMood;
      if (lastMood.value <= 2) {
        recommendations.add(
          PersonalizedRecommendation(
            type: RecommendationType.wellness,
            title: languageService.getLocalizedText('rec_low_mood_title'),
            description: languageService.getLocalizedText(
              'rec_low_mood_description',
            ),
            priority: Priority.high,
            actionText: languageService.getLocalizedText(
              'action_view_techniques',
            ),
            estimatedTime:
                '15-20 ' + languageService.getLocalizedText('minutes'),
            benefits: [
              languageService.getLocalizedText('benefit_mood_improvement'),
              languageService.getLocalizedText('benefit_reduce_anxiety'),
              languageService.getLocalizedText('benefit_increase_energy'),
            ],
          ),
        );
      }
    }

    // Recomendación basada en intereses del usuario
    for (final interest in userPreferences.userInterests) {
      recommendations.add(
        _createInterestBasedRecommendation(interest, languageService),
      );
    }

    // Recomendación de horario óptimo
    final optimalTime = _findOptimalTime(recentMoods, recentSessions);
    if (optimalTime != null) {
      final timeLabel = optimalTime == 'morning'
          ? languageService.getLocalizedText('morning_label')
          : optimalTime == 'afternoon'
          ? languageService.getLocalizedText('afternoon_label')
          : languageService.getLocalizedText('evening_label');
      recommendations.add(
        PersonalizedRecommendation(
          type: RecommendationType.timing,
          title: languageService.getLocalizedText('optimal_time_title'),
          description: languageService
              .getLocalizedText('optimal_time_message')
              .replaceFirst('{time}', timeLabel),
          priority: Priority.low,
          actionText: languageService.getLocalizedText(
            'action_configure_reminder',
          ),
          estimatedTime: '2 ' + languageService.getLocalizedText('minutes'),
          benefits: [
            languageService.getLocalizedText('benefit_more_effective'),
            languageService.getLocalizedText('benefit_better_adherence'),
            languageService.getLocalizedText('benefit_more_consistent_results'),
          ],
        ),
      );
    }

    // Ordenar por prioridad y limitar a 5 recomendaciones
    recommendations.sort(
      (a, b) => b.priority.index.compareTo(a.priority.index),
    );
    return recommendations.take(5).toList();
  }

  // Análisis de correlaciones
  static double _analyzeMeditationCorrelation(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
  ) {
    if (moods.length < 3 || sessions.length < 2) return 0.0;

    // Buscar días donde hubo meditación y comparar con el estado de ánimo
    double correlation = 0.0;
    int validComparisons = 0;

    for (final session in sessions) {
      final sameDayMood = moods
          .where(
            (m) =>
                m.date.year == session.completedAt.year &&
                m.date.month == session.completedAt.month &&
                m.date.day == session.completedAt.day,
          )
          .firstOrNull;

      if (sameDayMood != null) {
        // Buscar el estado de ánimo del día anterior para comparar
        final previousDay = session.completedAt.subtract(
          const Duration(days: 1),
        );
        final previousDayMood = moods
            .where(
              (m) =>
                  m.date.year == previousDay.year &&
                  m.date.month == previousDay.month &&
                  m.date.day == previousDay.day,
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

  static double _analyzeJournalCorrelation(
    List<MoodEntry> moods,
    List<JournalEntry> journals,
  ) {
    if (moods.length < 3 || journals.length < 2) return 0.0;

    // Similar análisis para el diario
    double correlation = 0.0;
    int validComparisons = 0;

    for (final journal in journals) {
      final sameDayMood = moods
          .where(
            (m) =>
                m.date.year == journal.createdAt.year &&
                m.date.month == journal.createdAt.month &&
                m.date.day == journal.createdAt.day,
          )
          .firstOrNull;

      if (sameDayMood != null) {
        final previousDay = journal.createdAt.subtract(const Duration(days: 1));
        final previousDayMood = moods
            .where(
              (m) =>
                  m.date.year == previousDay.year &&
                  m.date.month == previousDay.month &&
                  m.date.day == previousDay.day,
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

  // Análisis de patrones estacionales
  static String _analyzeSeasonalPattern(List<MoodEntry> moods) {
    if (moods.length < 14) return '';

    // Agrupar por mes
    final monthlyAverages = <int, double>{};
    for (final mood in moods) {
      final month = mood.date.month;
      monthlyAverages[month] =
          (monthlyAverages[month] ?? 0) + mood.overallMood.value;
    }

    // Calcular promedios mensuales
    for (final month in monthlyAverages.keys) {
      final count = moods.where((m) => m.date.month == month).length;
      monthlyAverages[month] = monthlyAverages[month]! / count;
    }

    // Detectar patrones estacionales
    if (monthlyAverages.containsKey(12) && monthlyAverages.containsKey(1)) {
      final decemberAvg = monthlyAverages[12]!;
      final januaryAvg = monthlyAverages[1]!;

      if (decemberAvg > januaryAvg + 0.5) {
        return 'december_better';
      } else if (januaryAvg > decemberAvg + 0.5) {
        return 'january_better';
      }
    }

    return '';
  }

  // Calcular pendiente de tendencia
  static double _calculateSlope(List<double> values) {
    if (values.length < 2) return 0.0;

    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;

    for (int i = 0; i < n; i++) {
      sumX += i.toDouble();
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }

    return (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  }

  // Predecir estado de ánimo de la próxima semana
  static double _predictNextWeekMood(List<double> recentMoods, double slope) {
    final lastMood = recentMoods.last;
    return (lastMood + slope * 7).clamp(1.0, 5.0);
  }

  // Encontrar horario óptimo
  static String? _findOptimalTime(
    List<MoodEntry> moods,
    List<MeditationSession> sessions,
  ) {
    if (moods.isEmpty && sessions.isEmpty) return null;

    // Analizar horarios de mayor actividad y mejor estado de ánimo
    final hourMoods = <int, List<double>>{};

    for (final mood in moods) {
      final hour = mood.date.hour;
      hourMoods[hour] = hourMoods[hour] ?? [];
      hourMoods[hour]!.add(mood.overallMood.value.toDouble());
    }

    double bestHour = 9.0; // Default
    double bestScore = 0.0;

    for (final hour in hourMoods.keys) {
      final avgMood =
          hourMoods[hour]!.reduce((a, b) => a + b) / hourMoods[hour]!.length;
      final frequency = hourMoods[hour]!.length;
      final score = avgMood * frequency; // Ponderar por frecuencia y calidad

      if (score > bestScore) {
        bestScore = score;
        bestHour = hour.toDouble();
      }
    }

    if (bestHour < 12) return 'Mañana (${bestHour.toInt()}:00)';
    if (bestHour < 18) return 'Tarde (${bestHour.toInt()}:00)';
    return 'Noche (${bestHour.toInt()}:00)';
  }

  // Crear recomendaciones basadas en objetivos
  static PersonalizedRecommendation _createGoalBasedRecommendation(
    String goal,
    LanguageService languageService,
  ) {
    final goalRecommendations = {
      'Reducir el estrés': PersonalizedRecommendation(
        type: RecommendationType.meditation,
        title: languageService.getLocalizedText('goal_reduce_stress_title'),
        description: languageService.getLocalizedText(
          'goal_reduce_stress_description',
        ),
        priority: Priority.high,
        actionText: languageService.getLocalizedText('action_start_meditation'),
        estimatedTime: '10-15 ' + languageService.getLocalizedText('minutes'),
        benefits: [
          languageService.getLocalizedText('benefit_reduce_cortisol'),
          languageService.getLocalizedText('benefit_improve_relaxation'),
          languageService.getLocalizedText('benefit_increase_mental_clarity'),
        ],
      ),
      'Mejorar el estado de ánimo': PersonalizedRecommendation(
        type: RecommendationType.wellness,
        title: languageService.getLocalizedText('goal_improve_mood_title'),
        description: languageService.getLocalizedText(
          'goal_improve_mood_description',
        ),
        priority: Priority.high,
        actionText: languageService.getLocalizedText('action_view_activities'),
        estimatedTime: '20-30 ' + languageService.getLocalizedText('minutes'),
        benefits: [
          languageService.getLocalizedText('benefit_increase_serotonin'),
          languageService.getLocalizedText('benefit_improve_self_esteem'),
          languageService.getLocalizedText('benefit_reduce_anxiety'),
        ],
      ),
      'Dormir mejor': PersonalizedRecommendation(
        type: RecommendationType.meditation,
        title: languageService.getLocalizedText('goal_sleep_better_title'),
        description: languageService.getLocalizedText(
          'goal_sleep_better_description',
        ),
        priority: Priority.medium,
        actionText: languageService.getLocalizedText('action_prepare_sleep'),
        estimatedTime: '15-20 ' + languageService.getLocalizedText('minutes'),
        benefits: [
          languageService.getLocalizedText('benefit_improve_sleep_quality'),
          languageService.getLocalizedText('benefit_reduce_insomnia'),
          languageService.getLocalizedText('benefit_increase_relaxation'),
        ],
      ),
    };

    return goalRecommendations[goal] ??
        PersonalizedRecommendation(
          type: RecommendationType.wellness,
          title: languageService.getLocalizedText('goal_custom_plan_title'),
          description: languageService
              .getLocalizedText('goal_custom_plan_description')
              .replaceFirst('{goal}', goal),
          priority: Priority.medium,
          actionText: languageService.getLocalizedText('action_view_plan'),
          estimatedTime: languageService.getLocalizedText('time_variable'),
          benefits: [
            languageService.getLocalizedText('benefit_personal_growth'),
            languageService.getLocalizedText('benefit_motivation'),
            languageService.getLocalizedText('benefit_continuous_learning'),
          ],
        );
  }

  // Crear recomendaciones basadas en intereses
  static PersonalizedRecommendation _createInterestBasedRecommendation(
    String interest,
    LanguageService languageService,
  ) {
    final interestRecommendations = {
      'Meditación': PersonalizedRecommendation(
        type: RecommendationType.meditation,
        title: languageService.getLocalizedText('interest_meditation_title'),
        description: languageService.getLocalizedText(
          'interest_meditation_description',
        ),
        priority: Priority.medium,
        actionText: languageService.getLocalizedText('action_learn_technique'),
        estimatedTime: '15-20 ' + languageService.getLocalizedText('minutes'),
        benefits: [
          languageService.getLocalizedText('benefit_diversify_practice'),
          languageService.getLocalizedText('benefit_increase_motivation'),
          languageService.getLocalizedText('benefit_improve_results'),
        ],
      ),
      'Respiración': PersonalizedRecommendation(
        type: RecommendationType.meditation,
        title: languageService.getLocalizedText('interest_breathing_title'),
        description: languageService.getLocalizedText(
          'interest_breathing_description',
        ),
        priority: Priority.medium,
        actionText: languageService.getLocalizedText('action_practice_now'),
        estimatedTime: '5-10 ' + languageService.getLocalizedText('minutes'),
        benefits: [
          languageService.getLocalizedText(
            'benefit_immediate_stress_reduction',
          ),
          languageService.getLocalizedText('benefit_improve_focus'),
          languageService.getLocalizedText('benefit_regulate_nervous_system'),
        ],
      ),
      'Gratitud': PersonalizedRecommendation(
        type: RecommendationType.journal,
        title: languageService.getLocalizedText('interest_gratitude_title'),
        description: languageService.getLocalizedText(
          'interest_gratitude_description',
        ),
        priority: Priority.low,
        actionText: languageService.getLocalizedText('action_write_gratitude'),
        estimatedTime: '5-10 ' + languageService.getLocalizedText('minutes'),
        benefits: [
          languageService.getLocalizedText('benefit_increase_happiness'),
          languageService.getLocalizedText('benefit_improve_perspective'),
          languageService.getLocalizedText('benefit_reduce_anxiety'),
        ],
      ),
    };

    return interestRecommendations[interest] ??
        PersonalizedRecommendation(
          type: RecommendationType.wellness,
          title: languageService
              .getLocalizedText('interest_explore_title')
              .replaceFirst('{interest}', interest),
          description: languageService
              .getLocalizedText('interest_explore_description')
              .replaceFirst('{interest}', interest),
          priority: Priority.low,
          actionText: languageService.getLocalizedText('action_explore'),
          estimatedTime: languageService.getLocalizedText('time_variable'),
          benefits: [
            languageService.getLocalizedText('benefit_continuous_learning'),
            languageService.getLocalizedText('benefit_motivation'),
            languageService.getLocalizedText('benefit_personal_growth'),
          ],
        );
  }
}

// Modelos de datos para IA
class MoodPrediction {
  final MoodTrend trend;
  final double confidence;
  final String recommendation;
  final List<String> factors;
  final double nextWeekPrediction;

  MoodPrediction({
    required this.trend,
    required this.confidence,
    required this.recommendation,
    required this.factors,
    required this.nextWeekPrediction,
  });
}

class PersonalizedRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final Priority priority;
  final String actionText;
  final String estimatedTime;
  final List<String> benefits;

  PersonalizedRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.actionText,
    required this.estimatedTime,
    required this.benefits,
  });
}

enum MoodTrend { improving, declining, stable }

enum RecommendationType { meditation, journal, wellness, timing }

enum Priority { high, medium, low }
