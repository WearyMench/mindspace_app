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
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildStatsOverview(context),
                const SizedBox(height: 20),
                _buildRecentActivity(context),
              ],
            ),
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

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    languageService.getLocalizedText(greetingKey),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w300,
                    ),
                  );
                },
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              const SizedBox(height: 8),
              Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.getLocalizedText('how_are_you_feeling'),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onBackground.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                            ),
                      );
                    },
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: -0.2),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          icon: const Icon(Icons.search),
          iconSize: 28,
          color: Theme.of(context).colorScheme.primary,
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('quick_actions'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: const MoodQuickEntry()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 500.ms)
                  .slideX(begin: -0.2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: const MeditationQuickStart()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideX(begin: 0.2),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const JournalQuickEntry()
            .animate()
            .fadeIn(duration: 600.ms, delay: 700.ms)
            .slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('progress_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 800.ms);
          },
        ),
        const SizedBox(height: 16),
        const StatsOverview()
            .animate()
            .fadeIn(duration: 600.ms, delay: 900.ms)
            .slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('recent_activity'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
        const SizedBox(height: 16),
        _buildActivityList(
          context,
        ).animate().fadeIn(duration: 600.ms, delay: 1100.ms).slideY(begin: 0.2),
      ],
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

        return Column(
          children: [
            if (recentMoods.isNotEmpty)
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildActivityItem(
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
            if (recentMeditations.isNotEmpty)
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildActivityItem(
                    context,
                    icon: Icons.self_improvement,
                    title: languageService.getLocalizedText(
                      'meditation_session',
                    ),
                    subtitle:
                        '${languageService.getLocalizedText('last_session')}: ${recentMeditations.first.type.name}',
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () => context.go('/meditation'),
                  );
                },
              ),
            if (recentJournals.isNotEmpty)
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildActivityItem(
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
          ],
        );
      },
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GradientCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
