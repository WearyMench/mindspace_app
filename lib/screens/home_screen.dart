import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';
import '../services/language_service.dart';
import '../widgets/gradient_card.dart';
import '../widgets/mood_quick_entry.dart';
import '../widgets/meditation_quick_start.dart';
import '../widgets/journal_quick_entry.dart';
import '../widgets/stats_overview.dart';
import '../widgets/smart_insights_widget.dart';
import '../widgets/wellness_metrics_widget.dart';
import '../widgets/ai_recommendations_widget.dart';
import '../widgets/mood_prediction_widget.dart';
import 'search_screen.dart';
import '../models/meditation_session.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),

                    // Sección principal con layout responsivo
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideScreen = constraints.maxWidth > 800;

                        if (isWideScreen) {
                          // Layout de 2 columnas para pantallas muy anchas
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Columna izquierda - Métricas y AI
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildWellnessMetrics(context),
                                    const SizedBox(height: 20),
                                    _buildMoodPrediction(context)
                                        .animate()
                                        .fadeIn(duration: 350.ms, delay: 100.ms)
                                        .slideY(begin: 0.1),
                                    const SizedBox(height: 20),
                                    _buildAIRecommendations(context)
                                        .animate()
                                        .fadeIn(duration: 350.ms, delay: 175.ms)
                                        .slideY(begin: 0.1),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Columna derecha - Acciones y insights
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildQuickActions(context),
                                    const SizedBox(height: 20),
                                    _buildSmartInsights(context)
                                        .animate()
                                        .fadeIn(duration: 350.ms, delay: 250.ms)
                                        .slideY(begin: 0.1),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Layout de una columna para pantallas normales
                          return Column(
                            children: [
                              _buildQuickActions(context),
                              const SizedBox(height: 20),
                              _buildWellnessMetrics(context),
                              const SizedBox(height: 20),
                              _buildMoodPrediction(context)
                                  .animate()
                                  .fadeIn(duration: 350.ms, delay: 100.ms)
                                  .slideY(begin: 0.1),
                              const SizedBox(height: 20),
                              _buildAIRecommendations(context)
                                  .animate()
                                  .fadeIn(duration: 350.ms, delay: 175.ms)
                                  .slideY(begin: 0.1),
                              const SizedBox(height: 20),
                              _buildSmartInsights(context)
                                  .animate()
                                  .fadeIn(duration: 350.ms, delay: 250.ms)
                                  .slideY(begin: 0.1),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Sección de estadísticas y actividad reciente
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideScreen = constraints.maxWidth > 600;

                        if (isWideScreen) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildStatsOverview(context),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: _buildRecentActivity(context),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildStatsOverview(context),
                              const SizedBox(height: 20),
                              _buildRecentActivity(context),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greetingKey;

    if (hour < 12) {
      greetingKey = 'good_morning';
    } else if (hour < 18) {
      greetingKey = 'good_afternoon';
    } else {
      greetingKey = 'good_evening';
    }

    return GradientCard(
      gradientColors: [
        Theme.of(context).colorScheme.surface.withOpacity(0.8),
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.getLocalizedText(greetingKey),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w300,
                            ),
                      );
                    },
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
                  const SizedBox(height: 4),
                  Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            languageService.getLocalizedText(
                              'how_are_you_feeling',
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                          );
                        },
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideY(begin: -0.1),
                ],
              ),
            ),
            Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 150.ms)
                .scale(begin: const Offset(0.95, 0.95)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GradientCard(
      gradientColors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.05),
        Theme.of(context).colorScheme.primary.withOpacity(0.02),
      ],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('quick_actions'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                const minChildWidth = 240.0;
                int columns = (constraints.maxWidth / (minChildWidth + spacing))
                    .floor()
                    .clamp(1, 3);
                final childWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: childWidth,
                      child: const MoodQuickEntry()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 150.ms)
                          .slideY(begin: 0.05),
                    ),
                    SizedBox(
                      width: childWidth,
                      child: const MeditationQuickStart()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 225.ms)
                          .slideY(begin: 0.05),
                    ),
                    SizedBox(
                      width: childWidth,
                      child: const JournalQuickEntry()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 300.ms)
                          .slideY(begin: 0.05),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessMetrics(BuildContext context) {
    return const WellnessMetricsWidget()
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1);
  }

  Widget _buildMoodPrediction(BuildContext context) {
    return const MoodPredictionWidget()
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1);
  }

  Widget _buildAIRecommendations(BuildContext context) {
    return const AIRecommendationsWidget()
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1);
  }

  Widget _buildSmartInsights(BuildContext context) {
    return const SmartInsightsWidget()
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1);
  }

  Widget _buildStatsOverview(BuildContext context) {
    return GradientCard(
      gradientColors: [
        Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
        Theme.of(context).colorScheme.tertiary.withOpacity(0.02),
      ],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('progress_title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            const SizedBox(height: 16),
            const StatsOverview()
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return GradientCard(
      gradientColors: [
        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        Theme.of(context).colorScheme.secondary.withOpacity(0.02),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('recent_activity'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            const SizedBox(height: 12),
            _buildActivityList(context)
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return Consumer3<MoodProvider, MeditationProvider, JournalProvider>(
      builder: (context, moodProvider, meditationProvider, journalProvider, child) {
        final recentMoods = moodProvider.getMoodEntriesForLastDays(3);
        final recentMeditations = meditationProvider.getSessionsForLastDays(3);
        final recentJournals = journalProvider.getRecentEntries();

        if (recentMoods.isEmpty &&
            recentMeditations.isEmpty &&
            recentJournals.isEmpty) {
          return GradientCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.timeline,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.getLocalizedText('no_recent_activity'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.getLocalizedText('start_journey'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
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

        final items = <Widget>[];
        if (recentMoods.isNotEmpty) {
          items.add(
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildDenseActivityRow(
                  context,
                  icon: Icons.mood,
                  title: languageService.getLocalizedText('mood_entry'),
                  subtitle:
                      '${languageService.getLocalizedText('last_entry')}: ${recentMoods.first.overallMood.label}',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => context.go('/mood'),
                );
              },
            ),
          );
        }
        if (recentMeditations.isNotEmpty) {
          items.add(
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildDenseActivityRow(
                  context,
                  icon: Icons.self_improvement,
                  title: languageService.getLocalizedText('meditation_session'),
                  subtitle:
                      '${languageService.getLocalizedText('last_session')}: ${_getLocalizedMeditationTypeName(recentMeditations.first.type, languageService)}',
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: () => context.go('/meditation'),
                );
              },
            ),
          );
        }
        if (recentJournals.isNotEmpty) {
          items.add(
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildDenseActivityRow(
                  context,
                  icon: Icons.book,
                  title: languageService.getLocalizedText('journal_entry'),
                  subtitle:
                      '${languageService.getLocalizedText('last_journal')}: ${recentJournals.first.title}',
                  color: Theme.of(context).colorScheme.tertiary,
                  onTap: () => context.go('/journal'),
                );
              },
            ),
          );
        }

        return Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.15),
                  height: 1,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: items[i],
              ),
            ],
          ],
        );
      },
    );
  }

  // Removed old dense card layout; now using a compact row layout

  Widget _buildDenseActivityRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            size: 14,
          ),
        ],
      ),
    );
  }

  String _getLocalizedMeditationTypeName(
    MeditationType type,
    LanguageService languageService,
  ) {
    switch (type) {
      case MeditationType.breathing:
        return languageService.getLocalizedText('meditation_breathing');
      case MeditationType.mindfulness:
        return languageService.getLocalizedText('meditation_mindfulness');
      case MeditationType.bodyScan:
        return languageService.getLocalizedText('meditation_body_scan');
      case MeditationType.lovingKindness:
        return languageService.getLocalizedText('meditation_loving_kindness');
      case MeditationType.walking:
        return languageService.getLocalizedText('meditation_walking');
      case MeditationType.gratitude:
        return languageService.getLocalizedText('meditation_gratitude');
      case MeditationType.sleep:
        return languageService.getLocalizedText('meditation_sleep');
      case MeditationType.anxiety:
        return languageService.getLocalizedText('meditation_anxiety');
    }
  }
}
