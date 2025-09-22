import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/advanced_analytics_service.dart';
import '../widgets/gradient_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';

class AdvancedAnalyticsWidget extends StatefulWidget {
  const AdvancedAnalyticsWidget({super.key});

  @override
  State<AdvancedAnalyticsWidget> createState() =>
      _AdvancedAnalyticsWidgetState();
}

class _AdvancedAnalyticsWidgetState extends State<AdvancedAnalyticsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CorrelationAnalysis? _correlationAnalysis;
  TemporalPatterns? _temporalPatterns;
  ProgressAnalysis? _progressAnalysis;
  WellnessAnalysis? _wellnessAnalysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      // Obtener datos reales de los providers
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final meditationProvider = Provider.of<MeditationProvider>(
        context,
        listen: false,
      );
      final journalProvider = Provider.of<JournalProvider>(
        context,
        listen: false,
      );

      final moods = moodProvider.getMoodEntriesForLastDays(90);
      final sessions = meditationProvider.getSessionsForLastDays(90);
      final journals = journalProvider.getEntriesForLastDays(90);

      // Generar analytics basados en datos reales
      final correlationAnalysis =
          await AdvancedAnalyticsService.analyzeCorrelations(
            moods: moods,
            sessions: sessions,
            journals: journals,
          );

      final temporalPatterns =
          await AdvancedAnalyticsService.analyzeTemporalPatterns(
            moods: moods,
            sessions: sessions,
            journals: journals,
          );

      final progressAnalysis = await AdvancedAnalyticsService.analyzeProgress(
        moods: moods,
        sessions: sessions,
        journals: journals,
      );

      final wellnessAnalysis = await AdvancedAnalyticsService.analyzeWellness(
        moods: moods,
        sessions: sessions,
        journals: journals,
      );

      setState(() {
        _correlationAnalysis = correlationAnalysis;
        _temporalPatterns = temporalPatterns;
        _progressAnalysis = progressAnalysis;
        _wellnessAnalysis = wellnessAnalysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _correlationAnalysis = null;
        _temporalPatterns = null;
        _progressAnalysis = null;
        _wellnessAnalysis = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                      Icons.analytics,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(
                      duration: 2000.ms,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                const SizedBox(width: 12),
                Text(
                      'Análisis Inteligente',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideX(begin: -0.2),
                const Spacer(),
                IconButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await _loadAnalytics();
                              // Mostrar feedback visual
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Análisis actualizado${_correlationAnalysis != null ? ' (${_correlationAnalysis!.insights.length} insights)' : ''}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      tooltip: 'Actualizar analytics',
                    )
                    .animate()
                    .scale(duration: 200.ms)
                    .then()
                    .shimmer(
                      duration: 1000.ms,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading) _buildLoadingState() else _buildAnalyticsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
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
            )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 1000.ms),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Analizando tus datos...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildAnalyticsContent() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Correlaciones'),
            Tab(text: 'Patrones'),
            Tab(text: 'Progreso'),
            Tab(text: 'Bienestar'),
          ],
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        const SizedBox(height: 16),
        SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCorrelationsTab(),
                  _buildPatternsTab(),
                  _buildProgressTab(),
                  _buildWellnessTab(),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms)
            .scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildCorrelationsTab() {
    if (_correlationAnalysis == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correlaciones Identificadas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Gráfico de correlaciones
          SizedBox(height: 200, child: _buildCorrelationsChart()),
          const SizedBox(height: 16),

          // Botón de acción
          _buildActionButton('Ver Análisis Completo', Icons.analytics, () {
            // Mostrar modal con análisis más detallado
            _showDetailedAnalysisModal(context);
          }),

          // Insights
          if (_correlationAnalysis!.insights.isNotEmpty) ...[
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ..._correlationAnalysis!.insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatternsTab() {
    if (_temporalPatterns == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patrones Temporales',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Mejores días
          if (_temporalPatterns!.bestDays.isNotEmpty) ...[
            _buildPatternCard(
              'Mejores Días',
              _temporalPatterns!.bestDays,
              Icons.calendar_today,
              Colors.green,
            ),
            const SizedBox(height: 16),
          ],

          // Mejores horas
          if (_temporalPatterns!.bestHours.isNotEmpty) ...[
            _buildPatternCard(
              'Mejores Horas',
              _temporalPatterns!.bestHours,
              Icons.access_time,
              Colors.blue,
            ),
            const SizedBox(height: 16),
          ],

          // Insights estacionales
          if (_temporalPatterns!.seasonalInsights.isNotEmpty) ...[
            _buildPatternCard(
              'Patrones Estacionales',
              _temporalPatterns!.seasonalInsights,
              Icons.wb_sunny,
              Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_progressAnalysis == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Progreso',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Progreso general
          _buildProgressCard(
            'Progreso General',
            _progressAnalysis!.overallProgress,
            Icons.trending_up,
          ),
          const SizedBox(height: 16),

          // Métricas individuales
          _buildProgressMetricsCard(
            'Estado de Ánimo',
            _progressAnalysis!.moodProgress,
          ),
          const SizedBox(height: 12),
          _buildProgressMetricsCard(
            'Meditación',
            _progressAnalysis!.meditationProgress,
          ),
          const SizedBox(height: 12),
          _buildProgressMetricsCard(
            'Diario',
            _progressAnalysis!.journalProgress,
          ),

          // Logros
          if (_progressAnalysis!.achievements.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAchievementsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildWellnessTab() {
    if (_wellnessAnalysis == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Bienestar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Puntuación general
          _buildWellnessScoreCard(),
          const SizedBox(height: 16),

          // Factores de riesgo
          if (_wellnessAnalysis!.riskFactors.isNotEmpty) ...[
            _buildFactorsCard(
              'Factores de Riesgo',
              _wellnessAnalysis!.riskFactors,
              Icons.warning,
              Colors.red,
            ),
            const SizedBox(height: 16),
          ],

          // Factores protectores
          if (_wellnessAnalysis!.protectiveFactors.isNotEmpty) ...[
            _buildFactorsCard(
              'Factores Protectores',
              _wellnessAnalysis!.protectiveFactors,
              Icons.shield,
              Colors.green,
            ),
            const SizedBox(height: 16),
          ],

          // Recomendaciones
          if (_wellnessAnalysis!.recommendations.isNotEmpty) ...[
            _buildFactorsCard(
              'Recomendaciones',
              _wellnessAnalysis!.recommendations,
              Icons.lightbulb,
              Colors.blue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCorrelationsChart() {
    if (_correlationAnalysis == null) return const SizedBox.shrink();

    final correlations = _correlationAnalysis!.correlations;
    final entries = correlations.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < entries.length) {
                  return Text(
                    _getCorrelationLabel(entries[value.toInt()].key),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final correlation = entry.value.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: correlation,
                color: _getCorrelationColor(correlation),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPatternCard(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress, IconData icon) {
    final percentage = (progress * 100).toInt();
    final color = progress > 0
        ? Colors.green
        : progress < 0
        ? Colors.red
        : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.abs(),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetricsCard(String title, ProgressMetrics metrics) {
    final color = metrics.trend == ProgressTrend.improving
        ? Colors.green
        : metrics.trend == ProgressTrend.declining
        ? Colors.red
        : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_getTrendIcon(metrics.trend), color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${metrics.change > 0 ? '+' : ''}${metrics.change.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Logros Recientes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._progressAnalysis!.achievements.map(
            (achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    achievement,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessScoreCard() {
    final score = _wellnessAnalysis!.overallScore;
    final color = score >= 80
        ? Colors.green
        : score >= 60
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                score.toInt().toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntuación de Bienestar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getWellnessLabel(score),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsCard(
    String title,
    List<String> factors,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...factors.map(
            (factor) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, color: color, size: 8),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      factor,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCorrelationLabel(String key) {
    switch (key) {
      case 'meditation_mood':
        return 'Meditación';
      case 'journal_mood':
        return 'Diario';
      case 'usage_mood':
        return 'Uso';
      case 'time_mood':
        return 'Horario';
      default:
        return key;
    }
  }

  Color _getCorrelationColor(double value) {
    if (value > 0.7) return Colors.green;
    if (value > 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getTrendIcon(ProgressTrend trend) {
    switch (trend) {
      case ProgressTrend.improving:
        return Icons.trending_up;
      case ProgressTrend.declining:
        return Icons.trending_down;
      case ProgressTrend.stable:
        return Icons.trending_flat;
    }
  }

  String _getWellnessLabel(double score) {
    if (score >= 80) return 'Excelente';
    if (score >= 60) return 'Bueno';
    if (score >= 40) return 'Regular';
    return 'Necesita mejorar';
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showDetailedAnalysisModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Análisis Detallado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_correlationAnalysis != null) ...[
                Text(
                  'Correlaciones Encontradas:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._correlationAnalysis!.correlations.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_getCorrelationLabel(entry.key)}: ${entry.value.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Insights:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._correlationAnalysis!.insights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'No hay datos suficientes para mostrar análisis detallado.',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
