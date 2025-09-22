import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';
import '../services/language_service.dart';
import '../widgets/gradient_card.dart';

class WellnessMetricsWidget extends StatefulWidget {
  const WellnessMetricsWidget({super.key});

  @override
  State<WellnessMetricsWidget> createState() => _WellnessMetricsWidgetState();
}

class _WellnessMetricsWidgetState extends State<WellnessMetricsWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<MoodProvider, MeditationProvider, JournalProvider>(
      builder:
          (context, moodProvider, meditationProvider, journalProvider, child) {
            final moodStats = moodProvider.getMoodStatistics();
            final meditationStats = meditationProvider
                .getMeditationStatistics();
            final recentJournals = journalProvider.getRecentEntries();

            // Calcular métricas de bienestar
            final wellnessScore = _calculateWellnessScore(
              moodStats,
              meditationStats,
              recentJournals.length,
            );
            final moodTrend = _calculateMoodTrend(moodProvider);
            final consistencyScore = _calculateConsistencyScore(
              moodStats,
              meditationStats,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('wellness_metrics'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Puntuación general de bienestar
                _buildWellnessScoreCard(wellnessScore),
                const SizedBox(height: 16),

                // Métricas detalladas
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Estado de Ánimo',
                        value:
                            moodStats['averageMood']?.toStringAsFixed(1) ??
                            '0.0',
                        subtitle: 'Promedio (1-5)',
                        icon: Icons.mood,
                        color: _getMoodColor(
                          moodStats['averageMood'] as double? ?? 0,
                        ),
                        trend: moodTrend,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Consistencia',
                        value: '${(consistencyScore * 100).toInt()}%',
                        subtitle: 'Esta semana',
                        icon: Icons.trending_up,
                        color: _getConsistencyColor(consistencyScore),
                        trend: consistencyScore > 0.7 ? Trend.up : Trend.stable,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Meditación',
                        value: '${meditationStats['streak'] ?? 0}',
                        subtitle: 'Días seguidos',
                        icon: Icons.self_improvement,
                        color: _getStreakColor(
                          meditationStats['streak'] as int? ?? 0,
                        ),
                        trend: (meditationStats['streak'] as int? ?? 0) > 0
                            ? Trend.up
                            : Trend.stable,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Reflexión',
                        value: '${recentJournals.length}',
                        subtitle: 'Entradas esta semana',
                        icon: Icons.book,
                        color: recentJournals.isNotEmpty
                            ? Colors.green
                            : Colors.grey,
                        trend: recentJournals.length > 2
                            ? Trend.up
                            : Trend.stable,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
    );
  }

  Widget _buildWellnessScoreCard(double score) {
    final scoreColor = _getWellnessScoreColor(score);
    final scoreLabel = _getWellnessScoreLabel(score);

    return GradientCard(
      gradientColors: [
        scoreColor.withOpacity(0.1),
        scoreColor.withOpacity(0.05),
      ],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Círculo de puntuación
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.1),
                border: Border.all(color: scoreColor, width: 3),
              ),
              child: Center(
                child: Text(
                  score.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Información de la puntuación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.getLocalizedText('wellness_score'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scoreLabel,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.getLocalizedText('based_on_activity'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Icono de tendencia
            Icon(_getTrendIcon(score), color: scoreColor, size: 32),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale();
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Trend trend,
  }) {
    return GradientCard(
      gradientColors: [color.withOpacity(0.1), color.withOpacity(0.05)],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(_getTrendIcon(trend), color: color, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  double _calculateWellnessScore(
    Map<String, dynamic> moodStats,
    Map<String, dynamic> meditationStats,
    int journalCount,
  ) {
    final moodScore =
        (moodStats['averageMood'] as double? ?? 3.0) / 5.0; // Normalizar a 0-1
    final meditationScore = ((meditationStats['streak'] as int? ?? 0) / 7.0)
        .clamp(0.0, 1.0); // Normalizar a 0-1
    final journalScore = (journalCount / 7.0).clamp(
      0.0,
      1.0,
    ); // Normalizar a 0-1

    // Ponderación: 50% estado de ánimo, 30% meditación, 20% diario
    return (moodScore * 0.5 + meditationScore * 0.3 + journalScore * 0.2) *
        10; // Escala 0-10
  }

  Trend _calculateMoodTrend(MoodProvider moodProvider) {
    final recentMoods = moodProvider.getMoodEntriesForLastDays(7);
    if (recentMoods.length < 2) return Trend.stable;

    final firstHalfMoods = recentMoods.take(3).toList();
    final secondHalfMoods = recentMoods.skip(3).toList();

    if (firstHalfMoods.isEmpty || secondHalfMoods.isEmpty) return Trend.stable;

    final firstHalf =
        firstHalfMoods.map((e) => e.overallMood.value).reduce((a, b) => a + b) /
        firstHalfMoods.length;
    final secondHalf =
        secondHalfMoods
            .map((e) => e.overallMood.value)
            .reduce((a, b) => a + b) /
        secondHalfMoods.length;

    if (secondHalf > firstHalf + 0.5) return Trend.up;
    if (secondHalf < firstHalf - 0.5) return Trend.down;
    return Trend.stable;
  }

  double _calculateConsistencyScore(
    Map<String, dynamic> moodStats,
    Map<String, dynamic> meditationStats,
  ) {
    final moodStreak = moodStats['streak'] as int? ?? 0;
    final meditationStreak = meditationStats['streak'] as int? ?? 0;

    // Calcular consistencia basada en rachas
    final moodConsistency = (moodStreak / 7.0).clamp(0.0, 1.0);
    final meditationConsistency = (meditationStreak / 7.0).clamp(0.0, 1.0);

    return (moodConsistency + meditationConsistency) / 2;
  }

  Color _getWellnessScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.orange;
    return Colors.red;
  }

  String _getWellnessScoreLabel(double score) {
    if (score >= 8.0) return 'Excelente';
    if (score >= 6.0) return 'Bueno';
    if (score >= 4.0) return 'Regular';
    return 'Necesita mejorar';
  }

  Color _getMoodColor(double mood) {
    if (mood >= 4.0) return Colors.green;
    if (mood >= 3.0) return Colors.orange;
    return Colors.red;
  }

  Color _getConsistencyColor(double consistency) {
    if (consistency >= 0.7) return Colors.green;
    if (consistency >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Color _getStreakColor(int streak) {
    if (streak >= 7) return Colors.green;
    if (streak >= 3) return Colors.orange;
    return Colors.grey;
  }

  IconData _getTrendIcon(dynamic trend) {
    if (trend is Trend) {
      switch (trend) {
        case Trend.up:
          return Icons.trending_up;
        case Trend.down:
          return Icons.trending_down;
        case Trend.stable:
          return Icons.trending_flat;
      }
    } else if (trend is double) {
      if (trend >= 8.0) return Icons.trending_up;
      if (trend >= 6.0) return Icons.trending_flat;
      return Icons.trending_down;
    }
    return Icons.trending_flat;
  }
}

enum Trend { up, down, stable }
