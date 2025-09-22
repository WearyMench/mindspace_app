import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';
import '../services/user_preferences_service.dart';

class AIInsightsService {
  // Análisis predictivo del estado de ánimo
  static Future<MoodPrediction> predictMoodTrend({
    required List<MoodEntry> recentMoods,
    required List<MeditationSession> recentSessions,
    required List<JournalEntry> recentJournals,
  }) async {
    if (recentMoods.length < 3) {
      return MoodPrediction(
        trend: MoodTrend.stable,
        confidence: 0.3,
        recommendation: 'Necesitas más datos para hacer predicciones precisas',
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
      recommendation =
          'Tu estado de ánimo está mejorando. ¡Sigue con las actividades que te hacen sentir bien!';
      factors.add('Tendencia positiva en los últimos días');
    } else if (slope < -0.2) {
      trend = MoodTrend.declining;
      confidence = 0.7;
      recommendation =
          'Notamos una tendencia a la baja. Te sugerimos probar técnicas de relajación o hablar con alguien de confianza.';
      factors.add('Tendencia negativa en los últimos días');
    } else {
      trend = MoodTrend.stable;
      confidence = 0.6;
      recommendation =
          'Tu estado de ánimo se mantiene estable. Es un buen momento para explorar nuevas actividades de bienestar.';
      factors.add('Estado de ánimo estable');
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
      factors.add('La meditación mejora tu estado de ánimo');
      if (trend == MoodTrend.declining) {
        recommendation += ' Considera meditar más frecuentemente.';
      }
    }

    if (journalCorrelation > 0.3) {
      factors.add('Escribir en tu diario te ayuda a procesar emociones');
      if (trend == MoodTrend.declining) {
        recommendation +=
            ' Escribir sobre tus sentimientos puede ser muy útil.';
      }
    }

    // Analizar patrones estacionales
    final seasonalPattern = _analyzeSeasonalPattern(recentMoods);
    if (seasonalPattern.isNotEmpty) {
      factors.add(seasonalPattern);
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
  }) async {
    final recommendations = <PersonalizedRecommendation>[];

    // Recomendación basada en objetivo del usuario
    if (userPreferences.userGoal.isNotEmpty) {
      recommendations.add(
        _createGoalBasedRecommendation(userPreferences.userGoal),
      );
    }

    // Recomendación basada en patrones de meditación
    if (recentSessions.isEmpty) {
      recommendations.add(
        PersonalizedRecommendation(
          type: RecommendationType.meditation,
          title: 'Comienza tu práctica de meditación',
          description:
              'La meditación puede ayudarte a alcanzar tu objetivo de ${userPreferences.userGoal}',
          priority: Priority.high,
          actionText: 'Meditar ahora',
          estimatedTime: '5-10 minutos',
          benefits: [
            'Reduce el estrés',
            'Mejora la concentración',
            'Aumenta la autoconciencia',
          ],
        ),
      );
    } else if (recentSessions.length < 3) {
      recommendations.add(
        PersonalizedRecommendation(
          type: RecommendationType.meditation,
          title: 'Mantén tu práctica de meditación',
          description:
              'Has meditado ${recentSessions.length} veces. ¡Sigue así para ver mejores resultados!',
          priority: Priority.medium,
          actionText: 'Continuar práctica',
          estimatedTime: '10-15 minutos',
          benefits: [
            'Consolida el hábito',
            'Mejora la consistencia',
            'Aumenta los beneficios',
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
            title: 'Técnicas para mejorar tu estado de ánimo',
            description:
                'Notamos que te has sentido un poco bajo. Aquí tienes algunas técnicas que pueden ayudar.',
            priority: Priority.high,
            actionText: 'Ver técnicas',
            estimatedTime: '15-20 minutos',
            benefits: [
              'Mejora el estado de ánimo',
              'Reduce la ansiedad',
              'Aumenta la energía',
            ],
          ),
        );
      }
    }

    // Recomendación basada en intereses del usuario
    for (final interest in userPreferences.userInterests) {
      recommendations.add(_createInterestBasedRecommendation(interest));
    }

    // Recomendación de horario óptimo
    final optimalTime = _findOptimalTime(recentMoods, recentSessions);
    if (optimalTime != null) {
      recommendations.add(
        PersonalizedRecommendation(
          type: RecommendationType.timing,
          title: 'Horario óptimo para tu bienestar',
          description:
              'Basado en tus datos, el mejor momento para tus actividades de bienestar es $optimalTime',
          priority: Priority.low,
          actionText: 'Configurar recordatorio',
          estimatedTime: '2 minutos',
          benefits: [
            'Mayor efectividad',
            'Mejor adherencia',
            'Resultados más consistentes',
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
        return 'Tienes tendencia a sentirte mejor en diciembre';
      } else if (januaryAvg > decemberAvg + 0.5) {
        return 'Tienes tendencia a sentirte mejor en enero';
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
  ) {
    final goalRecommendations = {
      'Reducir el estrés': PersonalizedRecommendation(
        type: RecommendationType.meditation,
        title: 'Meditación para reducir el estrés',
        description:
            'Prueba esta meditación específicamente diseñada para reducir el estrés',
        priority: Priority.high,
        actionText: 'Comenzar meditación',
        estimatedTime: '10-15 minutos',
        benefits: [
          'Reduce cortisol',
          'Mejora la relajación',
          'Aumenta la claridad mental',
        ],
      ),
      'Mejorar el estado de ánimo': PersonalizedRecommendation(
        type: RecommendationType.wellness,
        title: 'Actividades para mejorar el estado de ánimo',
        description:
            'Una combinación de técnicas que han demostrado mejorar el estado de ánimo',
        priority: Priority.high,
        actionText: 'Ver actividades',
        estimatedTime: '20-30 minutos',
        benefits: [
          'Aumenta la serotonina',
          'Mejora la autoestima',
          'Reduce la ansiedad',
        ],
      ),
      'Dormir mejor': PersonalizedRecommendation(
        type: RecommendationType.meditation,
        title: 'Meditación para el sueño',
        description:
            'Técnicas de relajación específicas para mejorar la calidad del sueño',
        priority: Priority.medium,
        actionText: 'Preparar para dormir',
        estimatedTime: '15-20 minutos',
        benefits: [
          'Mejora la calidad del sueño',
          'Reduce el insomnio',
          'Aumenta la relajación',
        ],
      ),
    };

    return goalRecommendations[goal] ??
        PersonalizedRecommendation(
          type: RecommendationType.wellness,
          title: 'Plan personalizado para tu objetivo',
          description:
              'Hemos creado un plan específico para ayudarte a alcanzar: $goal',
          priority: Priority.medium,
          actionText: 'Ver plan',
          estimatedTime: 'Variable',
          benefits: ['Personalizado', 'Adaptable', 'Efectivo'],
        );
  }

  // Crear recomendaciones basadas en intereses
  static PersonalizedRecommendation _createInterestBasedRecommendation(
    String interest,
  ) {
    final interestRecommendations = {
      'Meditación': PersonalizedRecommendation(
        type: RecommendationType.meditation,
        title: 'Nueva técnica de meditación',
        description:
            'Explora esta nueva técnica que puede enriquecer tu práctica',
        priority: Priority.medium,
        actionText: 'Aprender técnica',
        estimatedTime: '15-20 minutos',
        benefits: [
          'Diversifica tu práctica',
          'Aumenta la motivación',
          'Mejora los resultados',
        ],
      ),
      'Respiración': PersonalizedRecommendation(
        type: RecommendationType.meditation,
        title: 'Ejercicio de respiración avanzado',
        description:
            'Técnica de respiración que puedes practicar en cualquier momento',
        priority: Priority.medium,
        actionText: 'Practicar ahora',
        estimatedTime: '5-10 minutos',
        benefits: [
          'Reduce el estrés inmediatamente',
          'Mejora la concentración',
          'Regula el sistema nervioso',
        ],
      ),
      'Gratitud': PersonalizedRecommendation(
        type: RecommendationType.journal,
        title: 'Diario de gratitud',
        description:
            'Escribe sobre las cosas por las que te sientes agradecido hoy',
        priority: Priority.low,
        actionText: 'Escribir gratitud',
        estimatedTime: '5-10 minutos',
        benefits: [
          'Aumenta la felicidad',
          'Mejora la perspectiva',
          'Reduce la ansiedad',
        ],
      ),
    };

    return interestRecommendations[interest] ??
        PersonalizedRecommendation(
          type: RecommendationType.wellness,
          title: 'Explora más sobre $interest',
          description: 'Descubre nuevas formas de profundizar en $interest',
          priority: Priority.low,
          actionText: 'Explorar',
          estimatedTime: 'Variable',
          benefits: [
            'Aprendizaje continuo',
            'Motivación',
            'Crecimiento personal',
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
