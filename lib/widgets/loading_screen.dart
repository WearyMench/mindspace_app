import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';
import '../constants/app_colors.dart';
import '../services/user_preferences_service.dart';

class LoadingScreen extends StatefulWidget {
  final Widget child;

  const LoadingScreen({super.key, required this.child});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Inicializar todos los providers
      await Future.wait([
        Provider.of<MoodProvider>(context, listen: false).initialize(),
        Provider.of<MeditationProvider>(context, listen: false).initialize(),
        Provider.of<JournalProvider>(context, listen: false).initialize(),
      ]);

      // Iniciar animación
      _animationController.forward();

      // Esperar un poco para mostrar la animación
      await Future.delayed(const Duration(milliseconds: 2000));

      // Verificar si el onboarding está completo
      final isOnboardingCompleted =
          await UserPreferencesService.isOnboardingCompleted();

      // Navegar según el estado del onboarding
      if (mounted) {
        if (isOnboardingCompleted) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    } catch (e) {
      // Manejar errores de inicialización
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_hasError) {
                return _buildErrorScreen();
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo de la aplicación
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryPurple,
                              AppColors.secondaryBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.self_improvement,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nombre de la aplicación
                      Text(
                        'MindSpace',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Subtítulo
                      Text(
                        'Tu espacio para el bienestar mental',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onBackground.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                            ),
                      ),
                      const SizedBox(height: 48),

                      // Indicador de carga
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Texto de carga
                      Text(
                        'Cargando tu espacio personal...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 80, color: AppColors.error),
        const SizedBox(height: 24),
        Text(
          'Error al cargar la aplicación',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _errorMessage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasError = false;
              _errorMessage = '';
            });
            _initializeData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text(
            'Reintentar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
