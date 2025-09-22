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

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: languageService.getLocalizedText('mood_stat'),
                    value: moodStats['streak'].toString(),
                    subtitle: languageService.getLocalizedText('days_streak'),
                    icon: Icons.mood,
                    color: Theme.of(context).colorScheme.primary,
                    gradient: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: languageService.getLocalizedText('meditation_stat'),
                    value: meditationStats['streak'].toString(),
                    subtitle: languageService.getLocalizedText('days_streak'),
                    icon: Icons.self_improvement,
                    color: Theme.of(context).colorScheme.secondary,
                    gradient: [
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: languageService.getLocalizedText('journal_stat'),
                    value: journalStats['writingStreak'].toString(),
                    subtitle: languageService.getLocalizedText('days_streak'),
                    icon: Icons.book,
                    color: Theme.of(context).colorScheme.tertiary,
                    gradient: [
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
                    ],
                  ),
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
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
