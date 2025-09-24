import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../constants/app_colors.dart';

class JournalChart extends StatelessWidget {
  final int days;
  final String title;

  const JournalChart({
    super.key,
    this.days = 7,
    this.title = 'Actividad de escritura (últimos 7 días)',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        final entries = journalProvider.getEntriesForLastDays(days);

        if (entries.isEmpty) {
          return _buildEmptyState(context);
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(_buildBarChartData(entries)),
                ),
                const SizedBox(height: 16),
                _buildStats(context, entries),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No hay datos suficientes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribe en tu diario para ver gráficos',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildBarChartData(List<JournalEntry> entries) {
    // Agrupar entradas por día
    final Map<DateTime, int> dailyWords = {};
    for (final entry in entries) {
      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      dailyWords[date] = (dailyWords[date] ?? 0) + entry.wordCount;
    }

    // Ordenar por fecha
    final sortedEntries = dailyWords.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final bars = sortedEntries.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: AppColors.accentOrange,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _getMaxY(dailyWords.values),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < sortedEntries.length) {
                final entry = sortedEntries[value.toInt()];
                return Text(
                  '${entry.key.day}/${entry.key.month}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 50,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.textTertiary.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      barGroups: bars,
    );
  }

  double _getMaxY(Iterable<int> values) {
    if (values.isEmpty) {
      return 100;
      ;
    }
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max + 50).toDouble();
  }

  Widget _buildStats(BuildContext context, List<JournalEntry> entries) {
    final totalWords = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.wordCount,
    );
    final averageWords = entries.isNotEmpty ? totalWords / entries.length : 0;
    final totalEntries = entries.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          'Palabras',
          totalWords.toString(),
          Icons.text_fields,
          AppColors.accentOrange,
        ),
        _buildStatItem(
          context,
          'Promedio',
          averageWords.toStringAsFixed(0),
          Icons.analytics,
          AppColors.secondaryTeal,
        ),
        _buildStatItem(
          context,
          'Entradas',
          totalEntries.toString(),
          Icons.book,
          AppColors.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class JournalCategoryChart extends StatelessWidget {
  const JournalCategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        final entries = journalProvider.entries;

        if (entries.isEmpty) {
          return _buildEmptyState(context);
        }

        // Agrupar por categoría
        final Map<JournalCategory, int> categoryCount = {};
        for (final entry in entries) {
          categoryCount[entry.category] =
              (categoryCount[entry.category] ?? 0) + 1;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categorías más usadas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(_buildPieChartData(categoryCount)),
                ),
                const SizedBox(height: 16),
                _buildLegend(context, categoryCount),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.pie_chart, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No hay datos suficientes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribe en tu diario para ver estadísticas',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  PieChartData _buildPieChartData(Map<JournalCategory, int> categoryCount) {
    final total = categoryCount.values.fold(0, (sum, count) => sum + count);

    final colors = [
      AppColors.accentOrange,
      AppColors.primaryPurple,
      AppColors.secondaryBlue,
      AppColors.secondaryTeal,
      AppColors.success,
      AppColors.accentPink,
      AppColors.info,
      AppColors.warning,
    ];

    return PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {
          // Manejar toque en el gráfico
        },
      ),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: categoryCount.entries.map((entry) {
        final index = JournalCategory.values.indexOf(entry.key);
        final percentage = (entry.value / total) * 100;

        return PieChartSectionData(
          color: colors[index % colors.length],
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(
    BuildContext context,
    Map<JournalCategory, int> categoryCount,
  ) {
    final colors = [
      AppColors.accentOrange,
      AppColors.primaryPurple,
      AppColors.secondaryBlue,
      AppColors.secondaryTeal,
      AppColors.success,
      AppColors.accentPink,
      AppColors.info,
      AppColors.warning,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryCount.entries.map((entry) {
        final index = JournalCategory.values.indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key.icon} ${entry.value}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class WritingStreakChart extends StatelessWidget {
  const WritingStreakChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        final stats = journalProvider.getJournalStatistics();
        final streak = stats['writingStreak'] as int;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Racha de escritura',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentOrange,
                              AppColors.accentOrange.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            streak.toString(),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'días consecutivos',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        streak > 0
                            ? '¡Sigue así!'
                            : 'Comienza tu primera entrada',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: streak > 0
                              ? AppColors.success
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
