import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/meditation_provider.dart';
import '../models/meditation_session.dart';
import '../constants/app_colors.dart';

class MeditationChart extends StatelessWidget {
  final int days;
  final String title;

  const MeditationChart({
    super.key,
    this.days = 7,
    this.title = 'Tiempo de meditación (últimos 7 días)',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MeditationProvider>(
      builder: (context, meditationProvider, child) {
        final sessions = meditationProvider.getSessionsForLastDays(days);
        final completedSessions = sessions.where((s) => s.completed).toList();

        if (completedSessions.isEmpty) {
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
                  child: BarChart(_buildBarChartData(completedSessions)),
                ),
                const SizedBox(height: 16),
                _buildStats(context, completedSessions),
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
              'Completa algunas meditaciones para ver gráficos',
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

  BarChartData _buildBarChartData(List<MeditationSession> sessions) {
    // Agrupar sesiones por día
    final Map<DateTime, int> dailyMinutes = {};
    for (final session in sessions) {
      final date = DateTime(
        session.completedAt.year,
        session.completedAt.month,
        session.completedAt.day,
      );
      final minutes =
          session.actualDuration?.inMinutes ?? session.duration.inMinutes;
      dailyMinutes[date] = (dailyMinutes[date] ?? 0) + minutes;
    }

    // Ordenar por fecha
    final sortedEntries = dailyMinutes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final bars = sortedEntries.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: AppColors.secondaryBlue,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _getMaxY(dailyMinutes.values),
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
            interval: 5,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}m',
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
        horizontalInterval: 5,
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
      return 10;
      ;
    }
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max + 5).toDouble();
  }

  Widget _buildStats(BuildContext context, List<MeditationSession> sessions) {
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) =>
          sum +
          (session.actualDuration?.inMinutes ?? session.duration.inMinutes),
    );
    final averageMinutes = sessions.isNotEmpty
        ? totalMinutes / sessions.length
        : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          'Total',
          '${totalMinutes}m',
          Icons.timer,
          AppColors.secondaryBlue,
        ),
        _buildStatItem(
          context,
          'Promedio',
          '${averageMinutes.toStringAsFixed(1)}m',
          Icons.analytics,
          AppColors.secondaryTeal,
        ),
        _buildStatItem(
          context,
          'Sesiones',
          '${sessions.length}',
          Icons.self_improvement,
          AppColors.accentOrange,
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

class MeditationTypeChart extends StatelessWidget {
  const MeditationTypeChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MeditationProvider>(
      builder: (context, meditationProvider, child) {
        final sessions = meditationProvider.sessions
            .where((s) => s.completed)
            .toList();

        if (sessions.isEmpty) {
          return _buildEmptyState(context);
        }

        // Agrupar por tipo
        final Map<MeditationType, int> typeCount = {};
        for (final session in sessions) {
          typeCount[session.type] = (typeCount[session.type] ?? 0) + 1;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipos de meditación más usados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(_buildHorizontalBarChartData(typeCount)),
                ),
                const SizedBox(height: 16),
                _buildLegend(context, typeCount),
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
              'Completa algunas meditaciones para ver estadísticas',
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

  BarChartData _buildHorizontalBarChartData(
    Map<MeditationType, int> typeCount,
  ) {
    final sortedTypes = typeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppColors.secondaryBlue,
      AppColors.secondaryTeal,
      AppColors.accentOrange,
      AppColors.primaryPurple,
      AppColors.success,
    ];

    final bars = sortedTypes.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: colors[entry.key % colors.length],
            width: 20,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _getMaxY(typeCount.values),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < sortedTypes.length) {
                final entry = sortedTypes[value.toInt()];
                return Icon(
                  entry.key.icon,
                  size: 16,
                  color: AppColors.textSecondary,
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
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
      return 5;
      ;
    }
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max + 1).toDouble();
  }

  Widget _buildLegend(
    BuildContext context,
    Map<MeditationType, int> typeCount,
  ) {
    final sortedTypes = typeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppColors.secondaryBlue,
      AppColors.secondaryTeal,
      AppColors.accentOrange,
      AppColors.primaryPurple,
      AppColors.success,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: sortedTypes.asMap().entries.map((entry) {
        final type = entry.value.key;
        final count = entry.value.value;
        final color = colors[entry.key % colors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(type.icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}
