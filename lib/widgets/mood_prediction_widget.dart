import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/ai_insights_service.dart';
import '../widgets/gradient_card.dart';
import '../services/language_service.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';

class MoodPredictionWidget extends StatefulWidget {
  const MoodPredictionWidget({super.key});

  @override
  State<MoodPredictionWidget> createState() => _MoodPredictionWidgetState();
}

class _MoodPredictionWidgetState extends State<MoodPredictionWidget> {
  MoodPrediction? _prediction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrediction();
  }

  String _localizeRecommendation(String text, LanguageService languageService) {
    // Map simple Spanish phrases to keys; fallback to original text
    final mapping = {
      'Necesitas más datos para hacer predicciones precisas': languageService
          .getLocalizedText('rec_need_more_data'),
      'Tu estado de ánimo está mejorando. ¡Sigue con las actividades que te hacen sentir bien!':
          languageService.getLocalizedText('rec_mood_improving'),
      'Notamos una tendencia a la baja. Te sugerimos probar técnicas de relajación o hablar con alguien de confianza.':
          languageService.getLocalizedText('rec_mood_declining'),
      'Tu estado de ánimo se mantiene estable. Es un buen momento para explorar nuevas actividades de bienestar.':
          languageService.getLocalizedText('rec_mood_stable'),
    };
    return mapping[text] ?? text;
  }

  String _localizeFactor(String text, LanguageService languageService) {
    final mapping = {
      'Tendencia positiva en los últimos días': languageService
          .getLocalizedText('factor_positive_trend'),
      'Tendencia negativa en los últimos días': languageService
          .getLocalizedText('factor_negative_trend'),
      'Estado de ánimo estable': languageService.getLocalizedText(
        'factor_stable_mood',
      ),
      'La meditación mejora tu estado de ánimo': languageService
          .getLocalizedText('factor_meditation_helps'),
      'Escribir en tu diario te ayuda a procesar emociones': languageService
          .getLocalizedText('factor_journaling_helps'),
      'Tienes tendencia a sentirte mejor en diciembre': languageService
          .getLocalizedText('factor_december_better'),
      'Tienes tendencia a sentirte mejor en enero': languageService
          .getLocalizedText('factor_january_better'),
    };
    return mapping[text] ?? text;
  }

  Future<void> _loadPrediction() async {
    setState(() => _isLoading = true);

    try {
      // Obtener datos reales de los providers
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final meditationProvider = Provider.of<MeditationProvider>(
        context,
        listen: false,
      );
      final journalProvider = Provider.of<JournalProvider>(
        context,
        listen: false,
      );

      final recentMoods = moodProvider.getMoodEntriesForLastDays(30);
      final recentSessions = meditationProvider.getSessionsForLastDays(30);
      final recentJournals = journalProvider.getEntriesForLastDays(30);

      // Generar predicción basada en datos reales
      final prediction = await AIInsightsService.predictMoodTrend(
        recentMoods: recentMoods,
        recentSessions: recentSessions,
        recentJournals: recentJournals,
        languageService: Provider.of<LanguageService>(context, listen: false),
      );

      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _prediction = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradientColors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.1),
        Theme.of(context).colorScheme.primary.withOpacity(0.05),
      ],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                      Icons.psychology,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    )
                    .animate()
                    .scale(duration: 300.ms, curve: Curves.easeOut)
                    .then()
                    .shimmer(
                      duration: 1000.ms,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                const SizedBox(width: 12),
                Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          languageService.getLocalizedText(
                            'advanced_prediction',
                          ),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideX(begin: -0.2),
                const Spacer(),
                IconButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await _loadPrediction();
                              // Mostrar feedback visual
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Consumer<LanguageService>(
                                      builder: (context, languageService, child) {
                                        final conf = _prediction?.confidence;
                                        final confText = conf != null
                                            ? ' (${conf.toStringAsFixed(0)}%)'
                                            : '';
                                        return Text(
                                          languageService.getLocalizedText(
                                                'prediction_updated',
                                              ) +
                                              confText,
                                        );
                                      },
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      tooltip: Provider.of<LanguageService>(
                        context,
                        listen: false,
                      ).getLocalizedText('refresh_prediction'),
                    )
                    .animate()
                    .scale(duration: 200.ms)
                    .then()
                    .shimmer(
                      duration: 1000.ms,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              _buildLoadingState()
            else if (_prediction != null)
              _buildPredictionContent()
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 1000.ms),
        const SizedBox(width: 16),
        Expanded(
          child: Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(
                languageService.getLocalizedText('analyzing_patterns'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              );
            },
          ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.insights,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('not_enough_data'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText(
                'use_app_for_better_predictions',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            context.go('/mood');
          },
          icon: const Icon(Icons.add),
          label: Text(
            Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('log_mood'),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionContent() {
    if (_prediction == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tendencias
        _buildTrendSection(),
        const SizedBox(height: 16),

        // Recomendación principal
        _buildRecommendationSection(),
        const SizedBox(height: 16),

        // Factores
        if (_prediction!.factors.isNotEmpty) ...[
          _buildFactorsSection(),
          const SizedBox(height: 16),
        ],

        // Predicción próxima semana
        _buildNextWeekPrediction(),
        const SizedBox(height: 16),

        // Botón de acción
        _buildActionButton(),
      ],
    );
  }

  Widget _buildTrendSection() {
    final trend = _prediction!.trend;
    final confidence = _prediction!.confidence;

    final colors = _getTrendColors(trend);
    final icon = _getTrendIcon(trend);
    final label = _getTrendLabel(trend);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    '${languageService.getLocalizedText('trend')}: $label',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        '${languageService.getLocalizedText('confidence')}: ${(confidence * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: confidence,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    languageService.getLocalizedText('recommendation'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(
                _localizeRecommendation(
                  _prediction!.recommendation,
                  languageService,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.4,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('identified_factors'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _prediction!.factors.map((factor) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        _localizeFactor(factor, languageService),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNextWeekPrediction() {
    final prediction = _prediction!.nextWeekPrediction;
    final moodLevel = _getMoodLevelFromValue(prediction);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('next_week_prediction'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      '${languageService.getLocalizedText('expected_mood')}: ${moodLevel.label}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              prediction.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TrendColors _getTrendColors(MoodTrend trend) {
    switch (trend) {
      case MoodTrend.improving:
        return TrendColors(
          primary: Colors.green,
          secondary: Colors.green.shade100,
        );
      case MoodTrend.declining:
        return TrendColors(primary: Colors.red, secondary: Colors.red.shade100);
      case MoodTrend.stable:
        return TrendColors(
          primary: Colors.blue,
          secondary: Colors.blue.shade100,
        );
    }
  }

  IconData _getTrendIcon(MoodTrend trend) {
    switch (trend) {
      case MoodTrend.improving:
        return Icons.trending_up;
      case MoodTrend.declining:
        return Icons.trending_down;
      case MoodTrend.stable:
        return Icons.trending_flat;
    }
  }

  String _getTrendLabel(MoodTrend trend) {
    switch (trend) {
      case MoodTrend.improving:
        return 'Mejorando';
      case MoodTrend.declining:
        return 'Bajando';
      case MoodTrend.stable:
        return 'Estable';
    }
  }

  MoodLevel _getMoodLevelFromValue(double value) {
    if (value >= 4.5) return MoodLevel.excellent;
    if (value >= 3.5) return MoodLevel.good;
    if (value >= 2.5) return MoodLevel.neutral;
    if (value >= 1.5) return MoodLevel.bad;
    return MoodLevel.terrible;
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navegar a estadísticas de estado de ánimo
          context.go('/statistics');
        },
        icon: const Icon(Icons.analytics),
        label: Text(
          Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('view_detailed_analysis'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class TrendColors {
  final Color primary;
  final Color secondary;

  TrendColors({required this.primary, required this.secondary});
}

// Enum temporal para MoodLevel (debería importarse del modelo)
enum MoodLevel {
  excellent('Excelente'),
  good('Bien'),
  neutral('Neutral'),
  bad('Mal'),
  terrible('Terrible');

  const MoodLevel(this.label);
  final String label;
}
