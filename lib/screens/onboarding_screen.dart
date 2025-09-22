import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isLastPage = false;

  // Datos de configuración inicial
  String _selectedGoal = '';
  List<String> _selectedInterests = [];
  String _preferredTime = 'morning';
  int _experienceLevel = 0; // 0: principiante, 1: intermedio, 2: avanzado

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenido a MindSpace',
      subtitle: 'Tu espacio personal para el bienestar mental',
      description:
          'Comienza tu viaje hacia una mejor salud mental con herramientas diseñadas específicamente para ti.',
      icon: Icons.spa,
      color: 0xFF6B46C1,
    ),
    OnboardingPage(
      title: 'Seguimiento del Estado de Ánimo',
      subtitle: 'Conoce tus patrones emocionales',
      description:
          'Registra tu estado de ánimo diario y descubre patrones que te ayuden a entender mejor tus emociones.',
      icon: Icons.mood,
      color: 0xFF3B82F6,
    ),
    OnboardingPage(
      title: 'Meditación Guiada',
      subtitle: 'Encuentra tu momento de paz',
      description:
          'Accede a meditaciones personalizadas que se adaptan a tu nivel y necesidades específicas.',
      icon: Icons.self_improvement,
      color: 0xFF10B981,
    ),
    OnboardingPage(
      title: 'Diario Digital',
      subtitle: 'Reflexiona y crece',
      description:
          'Mantén un diario personal con prompts inteligentes que te guían en tu proceso de autoconocimiento.',
      icon: Icons.book,
      color: 0xFFF59E0B,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount:
                    _pages.length + 1, // +1 para la pantalla de configuración
                itemBuilder: (context, index) {
                  if (index < _pages.length) {
                    return _buildOnboardingPage(_pages[index]);
                  } else {
                    return _buildConfigurationPage();
                  }
                },
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(_pages.length + 1, (index) {
          final isActive = index <= _currentPage;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
          );
        }),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono animado
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(page.color).withOpacity(0.8),
                      Color(page.color).withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(page.color).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(page.icon, size: 60, color: Colors.white),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .then()
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          // Título
          Text(
                page.title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut),

          const SizedBox(height: 16),

          // Subtítulo
          Text(
                page.subtitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Color(page.color),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut),

          const SizedBox(height: 24),

          // Descripción
          Text(
                page.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut),
        ],
      ),
    );
  }

  Widget _buildConfigurationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Título
          Text(
            'Personaliza tu experiencia',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

          const SizedBox(height: 8),

          Text(
                'Cuéntanos sobre ti para crear una experiencia personalizada',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.7),
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: -0.2),

          const SizedBox(height: 40),

          // Objetivos
          _buildGoalsSection(),
          const SizedBox(height: 32),

          // Intereses
          _buildInterestsSection(),
          const SizedBox(height: 32),

          // Horario preferido
          _buildTimePreferenceSection(),
          const SizedBox(height: 32),

          // Nivel de experiencia
          _buildExperienceLevelSection(),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    final goals = [
      'Reducir el estrés',
      'Mejorar el estado de ánimo',
      'Dormir mejor',
      'Aumentar la concentración',
      'Desarrollar mindfulness',
      'Manejar la ansiedad',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cuál es tu objetivo principal?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: goals.map((goal) {
            final isSelected = _selectedGoal == goal;
            return GestureDetector(
              onTap: () => setState(() => _selectedGoal = goal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  goal,
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
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildInterestsSection() {
    final interests = [
      'Meditación',
      'Respiración',
      'Gratitud',
      'Mindfulness',
      'Relajación',
      'Autoconocimiento',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Qué te interesa más? (Selecciona varias)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    if (isSelected) const SizedBox(width: 8),
                    Text(
                      interest,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildTimePreferenceSection() {
    final timeOptions = [
      {'key': 'morning', 'label': 'Mañana', 'icon': Icons.wb_sunny},
      {'key': 'afternoon', 'label': 'Tarde', 'icon': Icons.wb_sunny_outlined},
      {'key': 'evening', 'label': 'Noche', 'icon': Icons.nightlight_round},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cuándo prefieres usar la app?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: timeOptions.map((option) {
            final isSelected = _preferredTime == option['key'] as String;
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _preferredTime = option['key'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        option['icon'] as IconData,
                        color: isSelected
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option['label'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildExperienceLevelSection() {
    final levels = ['Principiante', 'Intermedio', 'Avanzado'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cuál es tu nivel de experiencia?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: levels.asMap().entries.map((entry) {
            final index = entry.key;
            final level = entry.value;
            final isSelected = _experienceLevel == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _experienceLevel = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                    level,
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
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                child: const Text('Anterior'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLastPage ? _completeOnboarding : _nextPage,
              child: Text(_isLastPage ? 'Comenzar' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _pages.length;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Guardar configuración inicial
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_goal', _selectedGoal);
    await prefs.setStringList('user_interests', _selectedInterests);
    await prefs.setString('preferred_time', _preferredTime);
    await prefs.setInt('experience_level', _experienceLevel);
    await prefs.setString(
      'first_launch_date',
      DateTime.now().toIso8601String(),
    );
    await prefs.setBool('onboarding_completed', true);

    // Navegar a la pantalla principal
    if (mounted) {
      context.go('/home');
    }
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final int color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
