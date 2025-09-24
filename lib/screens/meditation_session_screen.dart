import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../models/meditation_session.dart';
import '../constants/app_colors.dart';
import '../services/language_service.dart';
import 'package:provider/provider.dart';

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
  Timer? _meditationTimer;
  Duration _remainingTime = const Duration(minutes: 5);
  bool _isPaused = false;
  bool _isCompleted = false;

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
    _meditationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isCompleted
                    ? _buildCompletionScreen(context)
                    : _buildMeditationScreen(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _showCancelDialog(context);
            },
            icon: const Icon(Icons.close),
            color: AppColors.textPrimary,
          ),
          const Spacer(),
          Text(
            _localizedTypeName(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance del botón de cerrar
        ],
      ),
    );
  }

  Widget _buildMeditationScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Círculo de respiración
        _buildBreathingCircle(context),
        const SizedBox(height: 40),

        // Tiempo restante
        _buildTimeDisplay(context),
        const SizedBox(height: 40),

        // Instrucciones
        _buildInstructions(context),
        const SizedBox(height: 60),

        // Controles
        _buildControls(context),
      ],
    );
  }

  Widget _buildBreathingCircle(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(
                      0.3 + (_breathingController.value * 0.4),
                    ),
                    AppColors.secondaryBlue.withOpacity(
                      0.2 + (_breathingController.value * 0.3),
                    ),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(
                      0.3 + (_pulseController.value * 0.2),
                    ),
                    blurRadius: 20 + (_pulseController.value * 10),
                    spreadRadius: 5 + (_pulseController.value * 5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isPaused
                      ? Icons.pause_circle_filled
                      : Icons.self_improvement,
                  size: 60 + (_breathingController.value * 20),
                  color: Colors.white.withOpacity(
                    0.8 + (_breathingController.value * 0.2),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).animate().fadeIn(duration: 600.ms).scale();
  }

  Widget _buildTimeDisplay(BuildContext context) {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;

    return Column(
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w300,
            fontSize: 64,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        Text(
          _isPaused
              ? Provider.of<LanguageService>(
                  context,
                  listen: false,
                ).getLocalizedText('pause')
              : Provider.of<LanguageService>(
                  context,
                  listen: false,
                ).getLocalizedText('time'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _isPaused
            ? Provider.of<LanguageService>(
                context,
                listen: false,
              ).getLocalizedText('continue')
            : Provider.of<LanguageService>(
                context,
                listen: false,
              ).getLocalizedText('breathing_instructions'),
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón de pausa/reanudar
        FloatingActionButton(
          onPressed: _togglePause,
          backgroundColor: AppColors.primaryPurple,
          child: Icon(
            _isPaused ? Icons.play_arrow : Icons.pause,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 20),

        // Botón de completar
        FloatingActionButton(
          onPressed: _completeMeditation,
          backgroundColor: AppColors.success,
          child: const Icon(Icons.check, color: Colors.white, size: 32),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildCompletionScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.success, AppColors.accentOrange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 32),

            Text(
              Provider.of<LanguageService>(
                context,
                listen: false,
              ).getLocalizedText('meditation_completed'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('time')}: ${widget.duration.inMinutes} ${Provider.of<LanguageService>(context, listen: false).getLocalizedText('minutes')}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                widget.onComplete();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                Provider.of<LanguageService>(
                  context,
                  listen: false,
                ).getLocalizedText('finish'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale();
  }

  void _startTimer() {
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      } else if (_remainingTime.inSeconds <= 0) {
        _completeMeditation();
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
      _breathingController.stop();
      _pulseController.stop();
    } else {
      _breathingController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    }
  }

  void _completeMeditation() {
    setState(() {
      _isCompleted = true;
    });
    _meditationTimer?.cancel();
    _breathingController.stop();
    _pulseController.stop();
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('cancel'),
        ),
        content: Text(
          Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('restore_warning'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Provider.of<LanguageService>(
                context,
                listen: false,
              ).getLocalizedText('continue'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              Provider.of<LanguageService>(
                context,
                listen: false,
              ).getLocalizedText('cancel'),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedTypeName(BuildContext context) {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    switch (widget.type) {
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
