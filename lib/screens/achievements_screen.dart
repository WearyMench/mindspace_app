import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../widgets/gradient_card.dart';
import '../services/language_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabSelector(context),
              Expanded(child: _buildTabContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                color: Theme.of(context).colorScheme.onBackground,
              ),
              const SizedBox(width: 8),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    languageService.getLocalizedText('achievements'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
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
                languageService.getLocalizedText('achievements_subtitle'),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildTabSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return Row(
            children: [
              _buildTabButton(
                context,
                languageService.getLocalizedText('all_achievements'),
                0,
              ),
              _buildTabButton(
                context,
                languageService.getLocalizedText('mood_achievements'),
                1,
              ),
              _buildTabButton(
                context,
                languageService.getLocalizedText('meditation_achievements'),
                2,
              ),
              _buildTabButton(
                context,
                languageService.getLocalizedText('journal_achievements'),
                3,
              ),
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildTabButton(BuildContext context, String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:
        return _buildAllAchievements(context);
      case 1:
        return _buildMoodAchievements(context);
      case 2:
        return _buildMeditationAchievements(context);
      case 3:
        return _buildJournalAchievements(context);
      default:
        return _buildAllAchievements(context);
    }
  }

  Widget _buildAllAchievements(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProgressOverview(context),
          const SizedBox(height: 24),
          _buildAchievementGrid(context, _getAllAchievements()),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildMoodAchievements(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildAchievementGrid(context, _getMoodAchievements()),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildMeditationAchievements(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildAchievementGrid(context, _getMeditationAchievements()),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildJournalAchievements(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildAchievementGrid(context, _getJournalAchievements()),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildProgressOverview(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('your_progress'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildProgressItem(
                        context,
                        languageService.getLocalizedText('level'),
                        '12',
                        Icons.star,
                        AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressItem(
                        context,
                        languageService.getLocalizedText('points'),
                        '2,450',
                        Icons.emoji_events,
                        AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressItem(
                        context,
                        languageService.getLocalizedText('achievements'),
                        '8/24',
                        Icons.workspace_premium,
                        AppColors.secondaryBlue,
                      ),
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

  Widget _buildProgressItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAchievementGrid(
    BuildContext context,
    List<Achievement> achievements,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(context, achievement);
      },
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    return GradientCard(
      gradientColors: achievement.isUnlocked
          ? [
              achievement.color.withOpacity(0.1),
              achievement.color.withOpacity(0.05),
            ]
          : [
              AppColors.textTertiary.withOpacity(0.1),
              AppColors.textTertiary.withOpacity(0.05),
            ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? achievement.color.withOpacity(0.2)
                    : AppColors.textTertiary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                color: achievement.isUnlocked
                    ? achievement.color
                    : AppColors.textTertiary,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: achievement.isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: achievement.isUnlocked
                    ? AppColors.textSecondary
                    : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (achievement.isUnlocked)
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: achievement.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${achievement.points} ${languageService.getLocalizedText('pts')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              )
            else
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    languageService.getLocalizedText('locked'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<Achievement> _getAllAchievements() {
    return [
      ..._getMoodAchievements(),
      ..._getMeditationAchievements(),
      ..._getJournalAchievements(),
    ];
  }

  List<Achievement> _getMoodAchievements() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    return [
      Achievement(
        id: 'mood_first',
        title: languageService.getLocalizedText('achievement_first_day'),
        description: languageService.getLocalizedText(
          'achievement_first_day_desc',
        ),
        icon: Icons.mood,
        color: AppColors.primaryPurple,
        points: 10,
        isUnlocked: true,
      ),
      Achievement(
        id: 'mood_week',
        title: languageService.getLocalizedText('achievement_week'),
        description: languageService.getLocalizedText('achievement_week_desc'),
        icon: Icons.calendar_today,
        color: AppColors.secondaryBlue,
        points: 50,
        isUnlocked: true,
      ),
      Achievement(
        id: 'mood_month',
        title: languageService.getLocalizedText('achievement_month'),
        description: languageService.getLocalizedText('achievement_month_desc'),
        icon: Icons.calendar_month,
        color: AppColors.accentOrange,
        points: 200,
        isUnlocked: false,
      ),
      Achievement(
        id: 'mood_positive',
        title: languageService.getLocalizedText('achievement_optimist'),
        description: languageService.getLocalizedText(
          'achievement_optimist_desc',
        ),
        icon: Icons.sentiment_very_satisfied,
        color: AppColors.success,
        points: 100,
        isUnlocked: false,
      ),
    ];
  }

  List<Achievement> _getMeditationAchievements() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    return [
      Achievement(
        id: 'meditation_first',
        title: languageService.getLocalizedText('achievement_first_meditation'),
        description: languageService.getLocalizedText(
          'achievement_first_meditation_desc',
        ),
        icon: Icons.self_improvement,
        color: AppColors.primaryPurple,
        points: 15,
        isUnlocked: true,
      ),
      Achievement(
        id: 'meditation_week',
        title: languageService.getLocalizedText('achievement_zen_week'),
        description: languageService.getLocalizedText(
          'achievement_zen_week_desc',
        ),
        icon: Icons.spa,
        color: AppColors.secondaryBlue,
        points: 75,
        isUnlocked: false,
      ),
      Achievement(
        id: 'meditation_hour',
        title: languageService.getLocalizedText('achievement_hour_peace'),
        description: languageService.getLocalizedText(
          'achievement_hour_peace_desc',
        ),
        icon: Icons.timer,
        color: AppColors.accentOrange,
        points: 150,
        isUnlocked: false,
      ),
      Achievement(
        id: 'meditation_master',
        title: languageService.getLocalizedText('achievement_zen_master'),
        description: languageService.getLocalizedText(
          'achievement_zen_master_desc',
        ),
        icon: Icons.workspace_premium,
        color: AppColors.success,
        points: 500,
        isUnlocked: false,
      ),
    ];
  }

  List<Achievement> _getJournalAchievements() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    return [
      Achievement(
        id: 'journal_first',
        title: languageService.getLocalizedText('achievement_first_entry'),
        description: languageService.getLocalizedText(
          'achievement_first_entry_desc',
        ),
        icon: Icons.book,
        color: AppColors.primaryPurple,
        points: 10,
        isUnlocked: true,
      ),
      Achievement(
        id: 'journal_week',
        title: languageService.getLocalizedText(
          'achievement_consistent_writer',
        ),
        description: languageService.getLocalizedText(
          'achievement_consistent_writer_desc',
        ),
        icon: Icons.edit,
        color: AppColors.secondaryBlue,
        points: 50,
        isUnlocked: false,
      ),
      Achievement(
        id: 'journal_words',
        title: languageService.getLocalizedText('achievement_words_wisdom'),
        description: languageService.getLocalizedText(
          'achievement_words_wisdom_desc',
        ),
        icon: Icons.text_fields,
        color: AppColors.accentOrange,
        points: 100,
        isUnlocked: false,
      ),
      Achievement(
        id: 'journal_reflection',
        title: languageService.getLocalizedText('achievement_deep_reflection'),
        description: languageService.getLocalizedText(
          'achievement_deep_reflection_desc',
        ),
        icon: Icons.psychology,
        color: AppColors.success,
        points: 300,
        isUnlocked: false,
      ),
    ];
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int points;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.points,
    required this.isUnlocked,
  });
}
