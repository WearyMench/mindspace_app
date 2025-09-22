import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry.dart';
import '../constants/app_colors.dart';

class MoodChart extends StatelessWidget {
  final int days;
  final String title;

  const MoodChart({
    super.key,
    this.days = 7,
    this.title = 'Estado de ánimo (últimos 7 días)',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final moodEntries = moodProvider.getMoodEntriesForLastDays(days);

        if (moodEntries.isEmpty) {
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
                  child: LineChart(_buildLineChartData(moodEntries)),
                ),
                const SizedBox(height: 16),
                _buildLegend(context),
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
            Icon(Icons.show_chart, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No hay datos suficientes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Registra tu estado de ánimo para ver gráficos',
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

  LineChartData _buildLineChartData(List<MoodEntry> moodEntries) {
    // Ordenar entradas por fecha
    moodEntries.sort((a, b) => a.date.compareTo(b.date));

    final spots = moodEntries.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.overallMood.value.toDouble(),
      );
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.textTertiary.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < moodEntries.length) {
                final date = moodEntries[value.toInt()].date;
                return Text(
                  '${date.day}/${date.month}',
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
            interval: 1,
            getTitlesWidget: (value, meta) {
              final moodLevel = MoodLevel.values.firstWhere(
                (mood) => mood.value == value.toInt(),
                orElse: () => MoodLevel.neutral,
              );
              return Text(
                moodLevel.emoji,
                style: const TextStyle(fontSize: 16),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (moodEntries.length - 1).toDouble(),
      minY: 0.5,
      maxY: 5.5,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primaryPurple,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primaryPurple,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryPurple.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MoodLevel.values.map((mood) {
        return Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              mood.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class MoodDistributionChart extends StatelessWidget {
  const MoodDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final stats = moodProvider.getMoodStatistics();
        final moodDistribution =
            stats['moodDistribution'] as Map<MoodLevel, int>;

        if (moodDistribution.isEmpty) {
          return _buildEmptyState(context);
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribución de estados de ánimo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(_buildPieChartData(moodDistribution)),
                ),
                const SizedBox(height: 16),
                _buildLegend(context, moodDistribution),
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
              'Registra tu estado de ánimo para ver estadísticas',
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

  PieChartData _buildPieChartData(Map<MoodLevel, int> moodDistribution) {
    final total = moodDistribution.values.fold(0, (sum, count) => sum + count);

    final colors = [
      AppColors.moodTerrible,
      AppColors.moodBad,
      AppColors.moodNeutral,
      AppColors.moodGood,
      AppColors.moodExcellent,
    ];

    return PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {
          // Manejar toque en el gráfico
        },
      ),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: moodDistribution.entries.map((entry) {
        final index = MoodLevel.values.indexOf(entry.key);
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
    Map<MoodLevel, int> moodDistribution,
  ) {
    final colors = [
      AppColors.moodTerrible,
      AppColors.moodBad,
      AppColors.moodNeutral,
      AppColors.moodGood,
      AppColors.moodExcellent,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: moodDistribution.entries.map((entry) {
        final index = MoodLevel.values.indexOf(entry.key);
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
              '${entry.key.emoji} ${entry.value}',
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
