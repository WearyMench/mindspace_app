import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';
import '../services/language_service.dart';
import '../widgets/gradient_card.dart';
import '../widgets/advanced_analytics_widget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildHeader(context),
                  _buildTabSelector(context),
                  Expanded(
                    child: constraints.maxWidth > 600
                        ? Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTabContent(context),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: _buildSidePanel(context),
                              ),
                            ],
                          )
                        : _buildTabContent(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // Si no hay páginas en el stack, ir al home
                    context.go('/home');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: Theme.of(context).colorScheme.onBackground,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          languageService.getLocalizedText('statistics_title'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          languageService.getLocalizedText(
                            'statistics_subtitle',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Row(
              children: [
                _buildTabButton(
                  context,
                  languageService.getLocalizedText('mood_tab'),
                  0,
                ),
                _buildTabButton(
                  context,
                  languageService.getLocalizedText('meditation_tab'),
                  1,
                ),
                _buildTabButton(
                  context,
                  languageService.getLocalizedText('journal_tab'),
                  2,
                ),
                _buildTabButton(
                  context,
                  languageService.getLocalizedText('smart_analysis'),
                  3,
                ),
              ],
            );
          },
        ),
      ).animate().fadeIn(duration: 200.ms, delay: 50.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildTabButton(BuildContext context, String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:
        return _buildMoodStatistics(context);
      case 1:
        return _buildMeditationStatistics(context);
      case 2:
        return _buildJournalStatistics(context);
      case 3:
        return _buildAdvancedAnalytics(context);
      default:
        return _buildMoodStatistics(context);
    }
  }

  Widget _buildMoodStatistics(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final entries = moodProvider.moodEntries;
        final stats = moodProvider.getMoodStatistics();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildStatsCards(context, stats),
              const SizedBox(height: 24),
              _buildMoodChart(context, entries),
              const SizedBox(height: 24),
              _buildMoodTrends(context, entries),
            ],
          ),
        );
      },
    ).animate().fadeIn(duration: 200.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildMeditationStatistics(BuildContext context) {
    return Consumer<MeditationProvider>(
      builder: (context, meditationProvider, child) {
        final sessions = meditationProvider.sessions;
        final stats = meditationProvider.getMeditationStatistics();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildMeditationStatsCards(context, stats),
              const SizedBox(height: 24),
              _buildMeditationChart(context, sessions),
              const SizedBox(height: 24),
              _buildMeditationTrends(context, sessions),
            ],
          ),
        );
      },
    ).animate().fadeIn(duration: 200.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildJournalStatistics(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        final entries = journalProvider.entries;
        final stats = journalProvider.getJournalStatistics();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildJournalStatsCards(context, stats),
              const SizedBox(height: 24),
              _buildJournalChart(context, entries),
              const SizedBox(height: 24),
              _buildJournalTrends(context, entries),
            ],
          ),
        );
      },
    ).animate().fadeIn(duration: 200.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildStatsCards(BuildContext context, Map<String, dynamic> stats) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('entries'),
                value: stats['totalEntries'].toString(),
                subtitle: languageService.getLocalizedText('total'),
                icon: Icons.mood,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('average'),
                value: stats['averageMood'].toStringAsFixed(1),
                subtitle: languageService.getLocalizedText('mood_state'),
                icon: Icons.trending_up,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('streak'),
                value: stats['streak'].toString(),
                subtitle: languageService.getLocalizedText('days'),
                icon: Icons.local_fire_department,
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 200.ms, delay: 150.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildMeditationStatsCards(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('sessions'),
                value: stats['totalSessions'].toString(),
                subtitle: languageService.getLocalizedText('completed'),
                icon: Icons.self_improvement,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('time'),
                value: stats['totalMinutes'].toString(),
                subtitle: languageService.getLocalizedText('minutes'),
                icon: Icons.timer,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('streak'),
                value: stats['streak'].toString(),
                subtitle: languageService.getLocalizedText('days'),
                icon: Icons.local_fire_department,
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 200.ms, delay: 150.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildJournalStatsCards(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('entries'),
                value: stats['totalEntries'].toString(),
                subtitle: languageService.getLocalizedText('total'),
                icon: Icons.book,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('words'),
                value: stats['totalWords'].toString(),
                subtitle: languageService.getLocalizedText('written'),
                icon: Icons.text_fields,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: languageService.getLocalizedText('average'),
                value: (stats['averageWords'] ?? 0).toString(),
                subtitle: languageService.getLocalizedText('per_entry'),
                icon: Icons.trending_up,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 200.ms, delay: 150.ms).slideY(begin: 0.1);
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
  }) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
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
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context, List entries) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('mood_chart_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: entries.length < 2
                  ? Center(
                      child: Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            languageService.getLocalizedText('no_data_chart'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onBackground.withOpacity(0.7),
                                ),
                          );
                        },
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _generateMoodSpots(entries),
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryPurple.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationChart(BuildContext context, List sessions) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('meditation_chart_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: sessions.length < 2
                  ? Center(
                      child: Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            languageService.getLocalizedText('no_data_chart'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onBackground.withOpacity(0.7),
                                ),
                          );
                        },
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _calculateMaxY(sessions),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: _generateMeditationBars(sessions),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalChart(BuildContext context, List entries) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('journal_chart_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: entries.length < 2
                  ? Center(
                      child: Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            languageService.getLocalizedText('no_data_chart'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onBackground.withOpacity(0.7),
                                ),
                          );
                        },
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _calculateMaxYJournal(entries),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: _generateJournalBars(entries),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTrends(BuildContext context, List entries) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('trends'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Column(
                  children: [
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('best_day_week'),
                      languageService.getLocalizedText('monday'),
                      Icons.trending_up,
                      AppColors.success,
                    ),
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('preferred_time'),
                      languageService.getLocalizedText('morning'),
                      Icons.access_time,
                      AppColors.secondaryBlue,
                    ),
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('most_common_state'),
                      languageService.getLocalizedText('good'),
                      Icons.mood,
                      AppColors.primaryPurple,
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

  Widget _buildMeditationTrends(BuildContext context, List sessions) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('trends'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Column(
                  children: [
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('favorite_type'),
                      languageService.getLocalizedText('mindfulness'),
                      Icons.self_improvement,
                      AppColors.success,
                    ),
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('average_duration'),
                      '15 min',
                      Icons.timer,
                      AppColors.secondaryBlue,
                    ),
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('best_moment'),
                      languageService.getLocalizedText('morning'),
                      Icons.wb_sunny,
                      AppColors.accentOrange,
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

  Widget _buildJournalTrends(BuildContext context, List entries) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('trends'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Column(
                  children: [
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('favorite_category'),
                      languageService.getLocalizedText('reflection'),
                      Icons.lightbulb,
                      AppColors.success,
                    ),
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('average_length'),
                      languageService.getLocalizedText('words_count'),
                      Icons.text_fields,
                      AppColors.secondaryBlue,
                    ),
                    _buildTrendItem(
                      context,
                      languageService.getLocalizedText('most_active_day'),
                      languageService.getLocalizedText('sunday'),
                      Icons.today,
                      AppColors.primaryPurple,
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

  Widget _buildTrendItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateMoodSpots(List entries) {
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length && i < 7; i++) {
      final entry = entries[i];
      spots.add(FlSpot(i.toDouble(), entry.overallMood.value.toDouble()));
    }
    return spots;
  }

  double _calculateMaxY(List sessions) {
    final now = DateTime.now();
    double maxCount = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final daySessions = sessions.where((session) {
        return session.date.year == date.year &&
            session.date.month == date.month &&
            session.date.day == date.day;
      }).length;

      if (daySessions > maxCount) {
        maxCount = daySessions.toDouble();
      }
    }

    // Asegurar que maxY sea al menos 1 y agregar un poco de padding
    return (maxCount == 0 ? 1 : maxCount + 1).toDouble();
  }

  List<BarChartGroupData> _generateMeditationBars(List sessions) {
    final bars = <BarChartGroupData>[];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final daySessions = sessions.where((session) {
        return session.date.year == date.year &&
            session.date.month == date.month &&
            session.date.day == date.day;
      }).length;

      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: daySessions.toDouble(),
              color: Theme.of(context).colorScheme.secondary,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    return bars;
  }

  double _calculateMaxYJournal(List entries) {
    final now = DateTime.now();
    double maxCount = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayEntries = entries.where((entry) {
        return entry.createdAt.year == date.year &&
            entry.createdAt.month == date.month &&
            entry.createdAt.day == date.day;
      }).length;

      if (dayEntries > maxCount) {
        maxCount = dayEntries.toDouble();
      }
    }

    // Asegurar que maxY sea al menos 1 y agregar un poco de padding
    return (maxCount == 0 ? 1 : maxCount + 1).toDouble();
  }

  List<BarChartGroupData> _generateJournalBars(List entries) {
    final bars = <BarChartGroupData>[];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayEntries = entries.where((entry) {
        return entry.createdAt.year == date.year &&
            entry.createdAt.month == date.month &&
            entry.createdAt.day == date.day;
      }).length;

      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dayEntries.toDouble(),
              color: Theme.of(context).colorScheme.secondary,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    return bars;
  }

  Widget _buildAdvancedAnalytics(BuildContext context) {
    return const Padding(
          padding: EdgeInsets.all(20),
          child: AdvancedAnalyticsWidget(),
        )
        .animate()
        .fadeIn(duration: 200.ms, delay: 50.ms)
        .slideY(begin: 0.1)
        .scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSidePanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(
                languageService.getLocalizedText('quick_summary'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.1),
          const SizedBox(height: 16),
          Consumer<MoodProvider>(
            builder: (context, moodProvider, child) {
              final stats = moodProvider.getMoodStatistics();
              return GradientCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                languageService.getLocalizedText('mood_state'),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                '${languageService.getLocalizedText('average')}: ${stats['averageMood'].toStringAsFixed(1)}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              );
                            },
                          ),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                '${languageService.getLocalizedText('entries')}: ${stats['totalEntries']}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
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
                  )
                  .animate()
                  .fadeIn(duration: 200.ms, delay: 50.ms)
                  .scale(begin: const Offset(0.98, 0.98));
            },
          ),
        ],
      ),
    );
  }
}
