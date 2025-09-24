import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';
import '../constants/app_colors.dart';
import '../services/language_service.dart';
import 'gradient_card.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      MoodProvider,
      MeditationProvider,
      JournalProvider,
      LanguageService
    >(
      builder:
          (
            context,
            moodProvider,
            meditationProvider,
            journalProvider,
            languageService,
            child,
          ) {
            final moodStats = moodProvider.getMoodStatistics();
            final meditationStats = meditationProvider
                .getMeditationStatistics();
            final journalStats = journalProvider.getJournalStatistics();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 12.0;
                    const minChildWidth = 140.0;
                    int columns =
                        (constraints.maxWidth / (minChildWidth + spacing))
                            .floor()
                            .clamp(1, 3);
                    final childWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;

                    final cards = <Widget>[
                      _buildStatCard(
                        context,
                        title: languageService.getLocalizedText('mood_stat'),
                        value: moodStats['streak'].toString(),
                        subtitle: languageService.getLocalizedText(
                          'days_streak',
                        ),
                        icon: Icons.mood,
                        color: Theme.of(context).colorScheme.primary,
                        gradient: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.05),
                        ],
                      ),
                      _buildStatCard(
                        context,
                        title: languageService.getLocalizedText(
                          'meditation_stat',
                        ),
                        value: meditationStats['streak'].toString(),
                        subtitle: languageService.getLocalizedText(
                          'days_streak',
                        ),
                        icon: Icons.self_improvement,
                        color: Theme.of(context).colorScheme.secondary,
                        gradient: [
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.1),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.05),
                        ],
                      ),
                      _buildStatCard(
                        context,
                        title: languageService.getLocalizedText('journal_stat'),
                        value: journalStats['writingStreak'].toString(),
                        subtitle: languageService.getLocalizedText(
                          'days_streak',
                        ),
                        icon: Icons.book,
                        color: Theme.of(context).colorScheme.tertiary,
                        gradient: [
                          Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.1),
                          Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.05),
                        ],
                      ),
                    ];

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: cards
                          .map((w) => SizedBox(width: childWidth, child: w))
                          .toList(),
                    );
                  },
                ),
              ],
            );
          },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return GradientCard(
      gradientColors: gradient,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
