import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/ai_insights_service.dart';
import '../services/language_service.dart';
import '../services/user_preferences_service.dart';
import '../widgets/gradient_card.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';

class AIRecommendationsWidget extends StatefulWidget {
  const AIRecommendationsWidget({super.key});

  @override
  State<AIRecommendationsWidget> createState() =>
      _AIRecommendationsWidgetState();
}

class _AIRecommendationsWidgetState extends State<AIRecommendationsWidget> {
  List<PersonalizedRecommendation> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
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

      // Generar recomendaciones basadas en datos reales
      final recommendations = await AIInsightsService.generateRecommendations(
        userPreferences: await UserPreferencesService.getUserPreferences(),
        recentMoods: recentMoods,
        recentSessions: recentSessions,
        recentJournals: recentJournals,
        languageService: Provider.of<LanguageService>(context, listen: false),
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _recommendations = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('advanced_recommendations'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1);
              },
            ),
            IconButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          await _loadRecommendations();
                          // Mostrar feedback visual
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Builder(
                                  builder: (context) {
                                    final languageService =
                                        Provider.of<LanguageService>(
                                          context,
                                          listen: false,
                                        );
                                    return Text(
                                      languageService
                                          .getLocalizedText(
                                            'recommendations_updated',
                                          )
                                          .replaceFirst(
                                            '{count}',
                                            _recommendations.length.toString(),
                                          ),
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
                  ).getLocalizedText('refresh_recommendations'),
                )
                .animate()
                .scale(duration: 200.ms)
                .then()
                .shimmer(
                  duration: 1000.ms,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          _buildLoadingState()
        else if (_recommendations.isEmpty)
          _buildEmptyState()
        else
          _buildRecommendationsList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
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
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildEmptyState() {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.psychology,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('no_recommendations'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText(
                    'use_app_for_better_recommendations',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          // Layout de 2 columnas para pantallas anchas
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              return _buildRecommendationCard(_recommendations[index], index);
            },
          );
        } else {
          // Layout de lista para pantallas estrechas
          return Column(
            children: _recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _recommendations.length - 1 ? 16 : 0,
                ),
                child: _buildRecommendationCard(recommendation, index),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildRecommendationCard(
    PersonalizedRecommendation recommendation,
    int index,
  ) {
    final colors = _getRecommendationColors(recommendation.type);

    return GradientCard(
          onTap: () => _handleRecommendationTap(recommendation),
          gradientColors: [
            colors.primary.withOpacity(0.1),
            colors.primary.withOpacity(0.05),
          ],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getRecommendationIcon(recommendation.type),
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    recommendation.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                _buildPriorityBadge(recommendation.priority),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recommendation.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Beneficios
                  if (recommendation.benefits.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: recommendation.benefits.take(3).map((benefit) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            benefit,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Información adicional
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recommendation.estimatedTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _handleRecommendationTap(recommendation),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            recommendation.actionText,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: (index * 100).ms)
        .slideY(begin: 0.2);
  }

  Widget _buildPriorityBadge(Priority priority) {
    final colors = _getPriorityColors(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPriorityIcon(priority), size: 12, color: colors.textColor),
          const SizedBox(width: 4),
          Text(
            _getPriorityLabel(priority),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleRecommendationTap(PersonalizedRecommendation recommendation) {
    // Implementar navegación basada en el tipo de recomendación
    switch (recommendation.type) {
      case RecommendationType.meditation:
        _navigateToMeditation(context);
        break;
      case RecommendationType.journal:
        _navigateToJournal(context);
        break;
      case RecommendationType.wellness:
        _showWellnessModal(context, recommendation);
        break;
      case RecommendationType.timing:
        _showTimingSettings(context, recommendation);
        break;
    }
  }

  void _navigateToMeditation(BuildContext context) {
    // Usar GoRouter para mantener la navegación
    context.go('/meditation');
  }

  void _navigateToJournal(BuildContext context) {
    // Usar GoRouter para mantener la navegación
    context.go('/journal');
  }

  void _showWellnessModal(
    BuildContext context,
    PersonalizedRecommendation recommendation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recommendation.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation.description),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('benefits') + ':',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                );
              },
            ),
            const SizedBox(height: 8),
            ...recommendation.benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  '${languageService.getLocalizedText('estimated_time')}: ${recommendation.estimatedTime}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('close'));
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToMeditation(context);
            },
            child: Text(recommendation.actionText),
          ),
        ],
      ),
    );
  }

  void _showTimingSettings(
    BuildContext context,
    PersonalizedRecommendation recommendation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recommendation.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation.description),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('benefits') + ':',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                );
              },
            ),
            const SizedBox(height: 8),
            ...recommendation.benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('cancel'));
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profile');
            },
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('configure'));
              },
            ),
          ),
        ],
      ),
    );
  }

  RecommendationColors _getRecommendationColors(RecommendationType type) {
    switch (type) {
      case RecommendationType.meditation:
        return RecommendationColors(
          primary: Colors.purple,
          secondary: Colors.purple.shade100,
        );
      case RecommendationType.journal:
        return RecommendationColors(
          primary: Colors.amber,
          secondary: Colors.amber.shade100,
        );
      case RecommendationType.wellness:
        return RecommendationColors(
          primary: Colors.green,
          secondary: Colors.green.shade100,
        );
      case RecommendationType.timing:
        return RecommendationColors(
          primary: Colors.blue,
          secondary: Colors.blue.shade100,
        );
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.meditation:
        return Icons.self_improvement;
      case RecommendationType.journal:
        return Icons.book;
      case RecommendationType.wellness:
        return Icons.favorite;
      case RecommendationType.timing:
        return Icons.schedule;
    }
  }

  PriorityColors _getPriorityColors(Priority priority) {
    switch (priority) {
      case Priority.high:
        return PriorityColors(
          backgroundColor: Colors.red.shade100,
          textColor: Colors.red.shade700,
        );
      case Priority.medium:
        return PriorityColors(
          backgroundColor: Colors.orange.shade100,
          textColor: Colors.orange.shade700,
        );
      case Priority.low:
        return PriorityColors(
          backgroundColor: Colors.grey.shade100,
          textColor: Colors.grey.shade700,
        );
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Icons.priority_high;
      case Priority.medium:
        return Icons.remove;
      case Priority.low:
        return Icons.keyboard_arrow_down;
    }
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('priority_high');
      case Priority.medium:
        return Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('priority_medium');
      case Priority.low:
        return Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('priority_low');
    }
  }
}

class RecommendationColors {
  final Color primary;
  final Color secondary;

  RecommendationColors({required this.primary, required this.secondary});
}

class PriorityColors {
  final Color backgroundColor;
  final Color textColor;

  PriorityColors({required this.backgroundColor, required this.textColor});
}
