import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';
import '../services/language_service.dart';
import '../services/user_preferences_service.dart';
import '../widgets/gradient_card.dart';

class SmartInsightsWidget extends StatefulWidget {
  const SmartInsightsWidget({super.key});

  @override
  State<SmartInsightsWidget> createState() => _SmartInsightsWidgetState();
}

class _SmartInsightsWidgetState extends State<SmartInsightsWidget> {
  List<Insight> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateInsights();
  }

  Future<void> _generateInsights() async {
    setState(() => _isLoading = true);

    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final meditationProvider = Provider.of<MeditationProvider>(
      context,
      listen: false,
    );
    final journalProvider = Provider.of<JournalProvider>(
      context,
      listen: false,
    );
    final userPreferences = await UserPreferencesService.getUserPreferences();

    final insights = <Insight>[];

    // Analizar estado de ánimo
    final moodStats = moodProvider.getMoodStatistics();
    final recentMoods = moodProvider.getMoodEntriesForLastDays(7);

    if (recentMoods.isNotEmpty) {
      final averageMood = moodStats['averageMood'] as double;
      final streak = moodStats['streak'] as int;

      if (averageMood >= 4.0) {
        insights.add(
          Insight(
            type: InsightType.positive,
            title: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('insight_great_mood_title'),
            description: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('insight_great_mood_description'),
            icon: Icons.sentiment_very_satisfied,
            color: Colors.green,
            actionText: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('view_statistics'),
            onAction: () => _navigateToMood(),
          ),
        );
      } else if (averageMood <= 2.5) {
        insights.add(
          Insight(
            type: InsightType.suggestion,
            title: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('insight_feeling_low_title'),
            description: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('insight_feeling_low_description'),
            icon: Icons.self_improvement,
            color: Colors.orange,
            actionText: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('action_meditate_now'),
            onAction: () => _navigateToMeditation(),
          ),
        );
      }

      if (streak >= 7) {
        insights.add(
          Insight(
            type: InsightType.achievement,
            title: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('insight_mood_streak_title'),
            description: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('insight_mood_streak_description'),
            icon: Icons.local_fire_department,
            color: Colors.red,
            actionText: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('view_streak'),
            onAction: () => _navigateToMood(),
          ),
        );
      }
    }

    // Analizar meditación
    final meditationStats = meditationProvider.getMeditationStatistics();
    final recentSessions = meditationProvider.getSessionsForLastDays(7);

    if (recentSessions.isNotEmpty) {
      final totalSessions = meditationStats['totalSessions'] as int;
      final streak = meditationStats['streak'] as int;

      if (streak >= 3) {
        insights.add(
          Insight(
            type: InsightType.achievement,
            title: '¡Racha de meditación!',
            description:
                'Has meditado durante $streak días seguidos. ¡Excelente hábito!',
            icon: Icons.self_improvement,
            color: Colors.purple,
            actionText: 'Continuar',
            onAction: () => _navigateToMeditation(),
          ),
        );
      } else if (streak == 0 && totalSessions > 0) {
        insights.add(
          Insight(
            type: InsightType.reminder,
            title: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('insight_ready_to_meditate_title'),
            description: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('insight_ready_to_meditate_description'),
            icon: Icons.timer,
            color: Colors.blue,
            actionText: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('action_meditate_now'),
            onAction: () => _navigateToMeditation(),
          ),
        );
      }
    }

    // Analizar diario
    final recentJournals = journalProvider.getRecentEntries();
    if (recentJournals.isNotEmpty) {
      final lastJournal = recentJournals.first;
      final daysSinceLastJournal = DateTime.now()
          .difference(lastJournal.createdAt)
          .inDays;

      if (daysSinceLastJournal >= 3) {
        insights.add(
          Insight(
            type: InsightType.reminder,
            title: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('how_are_you_feeling'),
            description: Provider.of<LanguageService>(context, listen: false)
                .getLocalizedText('insight_journal_reminder_description')
                .replaceFirst('{days}', daysSinceLastJournal.toString()),
            icon: Icons.book,
            color: Colors.amber,
            actionText: Provider.of<LanguageService>(
              context,
              listen: false,
            ).getLocalizedText('write_now'),
            onAction: () => _navigateToJournal(),
          ),
        );
      }
    }

    // Insights basados en objetivos del usuario
    if (userPreferences.userGoal.isNotEmpty) {
      insights.add(
        Insight(
          type: InsightType.motivation,
          title: Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('insight_goal_reminder_title'),
          description: Provider.of<LanguageService>(context, listen: false)
              .getLocalizedText('insight_goal_reminder_description')
              .replaceFirst('{goal}', userPreferences.userGoal),
          icon: Icons.flag,
          color: Colors.teal,
          actionText: Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('view_progress'),
          onAction: () => _navigateToProfile(),
        ),
      );
    }

    // Insight de bienvenida para nuevos usuarios
    if (recentMoods.isEmpty &&
        recentSessions.isEmpty &&
        recentJournals.isEmpty) {
      insights.add(
        Insight(
          type: InsightType.welcome,
          title: Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('insight_welcome_title'),
          description: Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('insight_welcome_description'),
          icon: Icons.waving_hand,
          color: Colors.indigo,
          actionText: Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('start'),
          onAction: () => _navigateToMood(),
        ),
      );
    }

    setState(() {
      _insights = insights.take(3).toList(); // Mostrar máximo 3 insights
      _isLoading = false;
    });
  }

  void _navigateToMood() {
    context.go('/mood');
  }

  void _navigateToMeditation() {
    context.go('/meditation');
  }

  void _navigateToJournal() {
    context.go('/journal');
  }

  void _navigateToProfile() {
    context.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_insights.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('insights'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            TextButton(
              onPressed: _generateInsights,
              child: Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    languageService.getLocalizedText('refresh'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._insights.map((insight) => _buildInsightCard(insight)),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('insights'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        GradientCard(
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
                ),
                const SizedBox(width: 16),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('analyzing_data'),
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
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('insights'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        GradientCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.insights,
                  size: 48,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('no_insights_yet'),
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
                      languageService.getLocalizedText('start_using_app'),
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
        ),
      ],
    );
  }

  Widget _buildInsightCard(Insight insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GradientCard(
        onTap: insight.onAction,
        gradientColors: [
          insight.color.withOpacity(0.1),
          insight.color.withOpacity(0.05),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(insight.icon, color: insight.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (insight.actionText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: insight.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: insight.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    insight.actionText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: insight.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
  }
}

class Insight {
  final InsightType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String actionText;
  final VoidCallback? onAction;

  Insight({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.actionText,
    this.onAction,
  });
}

enum InsightType {
  positive,
  suggestion,
  achievement,
  reminder,
  motivation,
  welcome,
}
