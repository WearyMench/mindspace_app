import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';

enum AppThemeMode {
  light('Claro'),
  dark('Oscuro'),
  system('Sistema');

  const AppThemeMode(this.label);
  final String label;
}

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  AppThemeMode _currentThemeMode = AppThemeMode.system;
  bool _isDarkMode = false;
  late Brightness _systemBrightness;

  AppThemeMode get currentThemeMode => _currentThemeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme {
    return _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  ThemeMode get themeMode {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> initialize() async {
    // Inicializar el brillo del sistema
    _systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    // Escuchar cambios en el brillo del sistema
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
          _systemBrightness =
              WidgetsBinding.instance.platformDispatcher.platformBrightness;
          if (_currentThemeMode == AppThemeMode.system) {
            _updateThemeMode();
            notifyListeners();
          }
        };

    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeKey);

    if (themeModeString != null) {
      _currentThemeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == themeModeString,
        orElse: () => AppThemeMode.system,
      );
    }

    _updateThemeMode();
    notifyListeners();
  }

  Future<void> changeThemeMode(AppThemeMode themeMode) async {
    _currentThemeMode = themeMode;
    _updateThemeMode();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.name);
  }

  void _updateThemeMode() {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        _isDarkMode = false;
        break;
      case AppThemeMode.dark:
        _isDarkMode = true;
        break;
      case AppThemeMode.system:
        // Usar el brillo del sistema almacenado
        _isDarkMode = _systemBrightness == Brightness.dark;
        break;
    }
  }

  String get themeModeLabel {
    return _currentThemeMode.label;
  }

  List<AppThemeMode> get availableThemes => AppThemeMode.values;
}
