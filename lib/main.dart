import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/meditation_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/mood_tracking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/statistics_screen.dart';
import 'providers/mood_provider.dart';
import 'providers/meditation_provider.dart';
import 'providers/journal_provider.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'widgets/loading_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar SQLite para desktop (no web)
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Inicializar el servicio de notificaciones
    try {
      await NotificationService.initialize();

      // Programar notificaciones inteligentes
      await NotificationService.scheduleSmartNotifications();
    } catch (e) {
      print('Error inicializando notificaciones: $e');
      // Continuar sin notificaciones si hay error
    }

    // Inicializar la base de datos
    final databaseService = DatabaseService();
    await databaseService.database;

    // Inicializar servicios
    final languageService = LanguageService();
    final themeService = ThemeService();
    await languageService.initialize();
    await themeService.initialize();

    runApp(
      MindSpaceApp(
        languageService: languageService,
        themeService: themeService,
      ),
    );
  } catch (e) {
    // Si hay un error crítico, mostrar una pantalla de error simple
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error al inicializar la aplicación: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reiniciar la aplicación
                    main();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MindSpaceApp extends StatelessWidget {
  final LanguageService languageService;
  final ThemeService themeService;

  const MindSpaceApp({
    super.key,
    required this.languageService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => MeditationProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider.value(value: themeService),
      ],
      child: Consumer2<LanguageService, ThemeService>(
        builder: (context, languageService, themeService, child) {
          return MaterialApp.router(
            title: 'MindSpace',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            locale: languageService.currentLocale,
            supportedLocales: languageService.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoadingScreen(child: HomeScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationWrapper(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/meditation',
          builder: (context, state) => const MeditationScreen(),
        ),
        GoRoute(
          path: '/journal',
          builder: (context, state) => const JournalScreen(),
        ),
        GoRoute(
          path: '/mood',
          builder: (context, state) => const MoodTrackingScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
    ),
  ],
);

class MainNavigationWrapper extends StatefulWidget {
  final Widget child;

  const MainNavigationWrapper({super.key, required this.child});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                switch (index) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/meditation');
                    break;
                  case 2:
                    context.go('/journal');
                    break;
                  case 3:
                    context.go('/mood');
                    break;
                  case 4:
                    context.go('/profile');
                    break;
                }
              },
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: languageService.getLocalizedText('navigation_home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.self_improvement_outlined),
                  activeIcon: const Icon(Icons.self_improvement),
                  label: languageService.getLocalizedText(
                    'navigation_meditation',
                  ),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.book_outlined),
                  activeIcon: const Icon(Icons.book),
                  label: languageService.getLocalizedText('navigation_journal'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.mood_outlined),
                  activeIcon: const Icon(Icons.mood),
                  label: languageService.getLocalizedText('navigation_mood'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: languageService.getLocalizedText('navigation_profile'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
