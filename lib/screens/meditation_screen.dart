import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../providers/meditation_provider.dart';
import '../models/meditation_session.dart';
import '../services/language_service.dart';
import '../widgets/gradient_card.dart';
import '../widgets/meditation_quick_start.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  Timer? _meditationTimer;
  Duration _remainingTime = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    _meditationTimer?.cancel();
    super.dispose();
  }

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
                _buildQuickStart(context),
                const SizedBox(height: 20),
                _buildMeditationTypes(context),
                const SizedBox(height: 20),
                _buildRecentSessions(context),
                const SizedBox(height: 20),
                _buildMeditationStats(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('meditation'),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        const SizedBox(height: 8),
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('meditation_subtitle'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.7),
              ),
            );
          },
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: -0.2),
      ],
    );
  }

  Widget _buildQuickStart(BuildContext context) {
    return const MeditationQuickStart()
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.2);
  }

  Widget _buildMeditationTypes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('meditation_types'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
          },
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: MeditationType.values.length,
          itemBuilder: (context, index) {
            final type = MeditationType.values[index];
            return _buildMeditationTypeCard(context, type);
          },
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 700.ms).slideY(begin: 0.2);
  }

  Widget _buildMeditationTypeCard(BuildContext context, MeditationType type) {
    return GradientCard(
      onTap: () => _showMeditationDetails(context, type),
      gradientColors: [
        Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type.icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(
                _getLocalizedMeditationTypeName(type, languageService),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 8),
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(
                _getLocalizedMeditationTypeDescription(type, languageService),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context) {
    return Consumer<MeditationProvider>(
      builder: (context, meditationProvider, child) {
        final recentSessions = meditationProvider.getSessionsForLastDays(7);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('recent_sessions_title'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 800.ms);
              },
            ),
            const SizedBox(height: 16),
            if (recentSessions.isEmpty)
              GradientCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.self_improvement_outlined,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Column(
                            children: [
                              Text(
                                languageService.getLocalizedText(
                                  'no_recent_sessions',
                                ),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                languageService.getLocalizedText(
                                  'start_first_meditation',
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentSessions
                  .take(3)
                  .map((session) => _buildSessionItem(context, session)),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 900.ms).slideY(begin: 0.2);
      },
    );
  }

  Widget _buildSessionItem(BuildContext context, MeditationSession session) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GradientCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  session.type.icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
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
                          _getLocalizedMeditationTypeName(
                            session.type,
                            languageService,
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          '${session.duration.inMinutes} ${languageService.getLocalizedText('minutes')} • ${_getLocalizedDifficultyLabel(session.difficulty, languageService)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.completedAt.day}/${session.completedAt.month}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (session.rating != null)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < session.rating! ? Icons.star : Icons.star_border,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 16,
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationStats(BuildContext context) {
    return Consumer<MeditationProvider>(
      builder: (context, meditationProvider, child) {
        final stats = meditationProvider.getMeditationStatistics();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: Provider.of<LanguageService>(
                      context,
                      listen: false,
                    ).getLocalizedText('sessions'),
                    value: stats['totalSessions'].toString(),
                    subtitle: Provider.of<LanguageService>(
                      context,
                      listen: false,
                    ).getLocalizedText('completed'),
                    icon: Icons.self_improvement,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: Provider.of<LanguageService>(
                      context,
                      listen: false,
                    ).getLocalizedText('time'),
                    value:
                        '${stats['totalMinutes']}${Provider.of<LanguageService>(context, listen: false).getLocalizedText('minutes')}',
                    subtitle: Provider.of<LanguageService>(
                      context,
                      listen: false,
                    ).getLocalizedText('total'),
                    icon: Icons.timer,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: Provider.of<LanguageService>(
                      context,
                      listen: false,
                    ).getLocalizedText('streak'),
                    value: stats['streak'].toString(),
                    subtitle: Provider.of<LanguageService>(
                      context,
                      listen: false,
                    ).getLocalizedText('days'),
                    icon: Icons.local_fire_department,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(child: SizedBox()), // Empty space for balance
              ],
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.2);
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
      gradientColors: [color.withOpacity(0.1), color.withOpacity(0.05)],
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
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showMeditationDetails(BuildContext context, MeditationType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MeditationDetailsBottomSheet(
        type: type,
        onStart: (duration, difficulty) {
          _startMeditation(type, duration, difficulty);
        },
      ),
    );
  }

  void _startMeditation(
    MeditationType type,
    Duration duration,
    DifficultyLevel difficulty,
  ) {
    setState(() {
      _remainingTime = duration;
    });

    Provider.of<MeditationProvider>(
      context,
      listen: false,
    ).startMeditationSession(type, duration, difficulty);

    _startTimer();
    _startBreathingAnimation();

    // Mostrar pantalla de meditación
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeditationSessionScreen(
          type: type,
          duration: duration,
          difficulty: difficulty,
          onComplete: _completeMeditation,
          onCancel: _cancelMeditation,
        ),
      ),
    );
  }

  void _startTimer() {
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingTime.inSeconds > 0) {
          setState(() {
            _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
          });
        } else {
          _completeMeditation();
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _startBreathingAnimation() {
    _breathingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  void _completeMeditation() {
    _meditationTimer?.cancel();
    _breathingController.stop();
    _pulseController.stop();

    Provider.of<MeditationProvider>(
      context,
      listen: false,
    ).completeMeditationSession(actualDuration: _remainingTime);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('meditation_completed')} ${_remainingTime.inMinutes} ${Provider.of<LanguageService>(context, listen: false).getLocalizedText('meditation_minutes')}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _cancelMeditation() {
    _meditationTimer?.cancel();
    _breathingController.stop();
    _pulseController.stop();

    Provider.of<MeditationProvider>(
      context,
      listen: false,
    ).cancelMeditationSession();

    Navigator.pop(context);
  }

  String _getLocalizedMeditationTypeName(
    MeditationType type,
    LanguageService languageService,
  ) {
    switch (type) {
      case MeditationType.breathing:
        return languageService.getLocalizedText('meditation_breathing');
      case MeditationType.mindfulness:
        return languageService.getLocalizedText('meditation_mindfulness');
      case MeditationType.bodyScan:
        return languageService.getLocalizedText('meditation_body_scan');
      case MeditationType.lovingKindness:
        return languageService.getLocalizedText('meditation_loving_kindness');
      case MeditationType.walking:
        return languageService.getLocalizedText('meditation_walking');
      case MeditationType.gratitude:
        return languageService.getLocalizedText('meditation_gratitude');
      case MeditationType.sleep:
        return languageService.getLocalizedText('meditation_sleep');
      case MeditationType.anxiety:
        return languageService.getLocalizedText('meditation_anxiety');
    }
  }

  String _getLocalizedMeditationTypeDescription(
    MeditationType type,
    LanguageService languageService,
  ) {
    switch (type) {
      case MeditationType.breathing:
        return languageService.getLocalizedText('meditation_breathing_desc');
      case MeditationType.mindfulness:
        return languageService.getLocalizedText('meditation_mindfulness_desc');
      case MeditationType.bodyScan:
        return languageService.getLocalizedText('meditation_body_scan_desc');
      case MeditationType.lovingKindness:
        return languageService.getLocalizedText(
          'meditation_loving_kindness_desc',
        );
      case MeditationType.walking:
        return languageService.getLocalizedText('meditation_walking_desc');
      case MeditationType.gratitude:
        return languageService.getLocalizedText('meditation_gratitude_desc');
      case MeditationType.sleep:
        return languageService.getLocalizedText('meditation_sleep_desc');
      case MeditationType.anxiety:
        return languageService.getLocalizedText('meditation_anxiety_desc');
    }
  }

  String _getLocalizedDifficultyLabel(
    DifficultyLevel difficulty,
    LanguageService languageService,
  ) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return languageService.getLocalizedText('difficulty_beginner');
      case DifficultyLevel.intermediate:
        return languageService.getLocalizedText('difficulty_intermediate');
      case DifficultyLevel.advanced:
        return languageService.getLocalizedText('difficulty_advanced');
    }
  }
}

class MeditationDetailsBottomSheet extends StatefulWidget {
  final MeditationType type;
  final Function(Duration, DifficultyLevel) onStart;

  const MeditationDetailsBottomSheet({
    super.key,
    required this.type,
    required this.onStart,
  });

  @override
  State<MeditationDetailsBottomSheet> createState() =>
      _MeditationDetailsBottomSheetState();
}

class _MeditationDetailsBottomSheetState
    extends State<MeditationDetailsBottomSheet> {
  Duration selectedDuration = const Duration(minutes: 5);
  DifficultyLevel selectedDifficulty = DifficultyLevel.beginner;

  final List<Duration> durations = [
    const Duration(minutes: 5),
    const Duration(minutes: 10),
    const Duration(minutes: 15),
    const Duration(minutes: 20),
    const Duration(minutes: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  widget.type.icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            _getLocalizedMeditationTypeName(
                              widget.type,
                              languageService,
                            ),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            _getLocalizedMeditationTypeDescription(
                              widget.type,
                              languageService,
                            ),
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
              ],
            ),
            const SizedBox(height: 24),
            _buildDurationSelector(),
            const SizedBox(height: 24),
            _buildDifficultySelector(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('duration'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: durations.map((duration) {
            final isSelected = selectedDuration == duration;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedDuration = duration),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${duration.inMinutes}m',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('difficulty'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: DifficultyLevel.values.map((difficulty) {
            final isSelected = selectedDifficulty == difficulty;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedDifficulty = difficulty),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        _getLocalizedDifficultyLabel(
                          difficulty,
                          languageService,
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('cancel'));
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onStart(selectedDuration, selectedDifficulty);
              Navigator.pop(context);
            },
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('start_meditation'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getLocalizedMeditationTypeName(
    MeditationType type,
    LanguageService languageService,
  ) {
    switch (type) {
      case MeditationType.breathing:
        return languageService.getLocalizedText('meditation_breathing');
      case MeditationType.mindfulness:
        return languageService.getLocalizedText('meditation_mindfulness');
      case MeditationType.bodyScan:
        return languageService.getLocalizedText('meditation_body_scan');
      case MeditationType.lovingKindness:
        return languageService.getLocalizedText('meditation_loving_kindness');
      case MeditationType.walking:
        return languageService.getLocalizedText('meditation_walking');
      case MeditationType.gratitude:
        return languageService.getLocalizedText('meditation_gratitude');
      case MeditationType.sleep:
        return languageService.getLocalizedText('meditation_sleep');
      case MeditationType.anxiety:
        return languageService.getLocalizedText('meditation_anxiety');
    }
  }

  String _getLocalizedMeditationTypeDescription(
    MeditationType type,
    LanguageService languageService,
  ) {
    switch (type) {
      case MeditationType.breathing:
        return languageService.getLocalizedText('meditation_breathing_desc');
      case MeditationType.mindfulness:
        return languageService.getLocalizedText('meditation_mindfulness_desc');
      case MeditationType.bodyScan:
        return languageService.getLocalizedText('meditation_body_scan_desc');
      case MeditationType.lovingKindness:
        return languageService.getLocalizedText(
          'meditation_loving_kindness_desc',
        );
      case MeditationType.walking:
        return languageService.getLocalizedText('meditation_walking_desc');
      case MeditationType.gratitude:
        return languageService.getLocalizedText('meditation_gratitude_desc');
      case MeditationType.sleep:
        return languageService.getLocalizedText('meditation_sleep_desc');
      case MeditationType.anxiety:
        return languageService.getLocalizedText('meditation_anxiety_desc');
    }
  }

  String _getLocalizedDifficultyLabel(
    DifficultyLevel difficulty,
    LanguageService languageService,
  ) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return languageService.getLocalizedText('difficulty_beginner');
      case DifficultyLevel.intermediate:
        return languageService.getLocalizedText('difficulty_intermediate');
      case DifficultyLevel.advanced:
        return languageService.getLocalizedText('difficulty_advanced');
    }
  }
}

class MeditationSessionScreen extends StatefulWidget {
  final MeditationType type;
  final Duration duration;
  final DifficultyLevel difficulty;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const MeditationSessionScreen({
    super.key,
    required this.type,
    required this.duration,
    required this.difficulty,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<MeditationSessionScreen> createState() =>
      _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends State<MeditationSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  Timer? _timer;
  Duration _remainingTime = const Duration(minutes: 5);
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _startTimer();
    _startBreathingAnimation();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingTime.inSeconds > 0) {
          setState(() {
            _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
          });
        } else {
          widget.onComplete();
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _startBreathingAnimation() {
    _breathingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _timer?.cancel();
      _breathingController.stop();
      _pulseController.stop();
    } else {
      _startTimer();
      _startBreathingAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildMeditationCircle(),
                const SizedBox(height: 40),
                _buildControls(),
                const SizedBox(height: 40),
                _buildInstructions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.close),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Expanded(
          child: Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(
                _getLocalizedMeditationTypeName(widget.type, languageService),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        IconButton(
          onPressed: _togglePause,
          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _buildMeditationCircle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _isPaused ? 1.0 : 1.0 + (_breathingController.value * 0.2),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                  blurRadius: _isPaused
                      ? 20
                      : 20 + (_pulseController.value * 30),
                  spreadRadius: _isPaused ? 0 : _pulseController.value * 10,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.type.icon,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatDuration(_remainingTime),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isPaused ? Icons.play_arrow : Icons.pause,
                  label: _isPaused
                      ? languageService.getLocalizedText('continue')
                      : languageService.getLocalizedText('pause'),
                  onTap: _togglePause,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                _buildControlButton(
                  icon: Icons.stop,
                  label: languageService.getLocalizedText('finish'),
                  onTap: widget.onComplete,
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('instructions'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              _getInstructionsForType(widget.type),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getInstructionsForType(MeditationType type) {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );

    switch (type) {
      case MeditationType.breathing:
        return languageService.getLocalizedText('breathing_instructions');
      case MeditationType.mindfulness:
        return languageService.getLocalizedText('mindfulness_instructions');
      case MeditationType.bodyScan:
        return languageService.getLocalizedText('body_scan_instructions');
      case MeditationType.lovingKindness:
        return languageService.getLocalizedText('loving_kindness_instructions');
      case MeditationType.gratitude:
        return languageService.getLocalizedText('gratitude_instructions');
      case MeditationType.sleep:
        return languageService.getLocalizedText('sleep_instructions');
      case MeditationType.anxiety:
        return languageService.getLocalizedText('anxiety_instructions');
      default:
        return languageService.getLocalizedText(
          'default_meditation_instructions',
        );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _getLocalizedMeditationTypeName(
    MeditationType type,
    LanguageService languageService,
  ) {
    switch (type) {
      case MeditationType.breathing:
        return languageService.getLocalizedText('meditation_breathing');
      case MeditationType.mindfulness:
        return languageService.getLocalizedText('meditation_mindfulness');
      case MeditationType.bodyScan:
        return languageService.getLocalizedText('meditation_body_scan');
      case MeditationType.lovingKindness:
        return languageService.getLocalizedText('meditation_loving_kindness');
      case MeditationType.walking:
        return languageService.getLocalizedText('meditation_walking');
      case MeditationType.gratitude:
        return languageService.getLocalizedText('meditation_gratitude');
      case MeditationType.sleep:
        return languageService.getLocalizedText('meditation_sleep');
      case MeditationType.anxiety:
        return languageService.getLocalizedText('meditation_anxiety');
    }
  }
}
