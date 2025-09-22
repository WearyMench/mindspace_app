import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserPreferencesService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _userGoalKey = 'user_goal';
  static const String _userInterestsKey = 'user_interests';
  static const String _preferredTimeKey = 'preferred_time';
  static const String _experienceLevelKey = 'experience_level';
  static const String _firstLaunchDateKey = 'first_launch_date';
  static const String _dailyReminderTimeKey = 'daily_reminder_time';
  static const String _weeklyGoalKey = 'weekly_goal';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Verificar si el onboarding está completo
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Marcar onboarding como completado
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  // Obtener objetivo del usuario
  static Future<String> getUserGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userGoalKey) ?? '';
  }

  // Establecer objetivo del usuario
  static Future<void> setUserGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userGoalKey, goal);
  }

  // Obtener intereses del usuario
  static Future<List<String>> getUserInterests() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userInterestsKey) ?? [];
  }

  // Establecer intereses del usuario
  static Future<void> setUserInterests(List<String> interests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userInterestsKey, interests);
  }

  // Obtener horario preferido
  static Future<String> getPreferredTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredTimeKey) ?? 'morning';
  }

  // Establecer horario preferido
  static Future<void> setPreferredTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredTimeKey, time);
  }

  // Obtener nivel de experiencia
  static Future<int> getExperienceLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_experienceLevelKey) ?? 0;
  }

  // Establecer nivel de experiencia
  static Future<void> setExperienceLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_experienceLevelKey, level);
  }

  // Obtener fecha de primer lanzamiento
  static Future<DateTime?> getFirstLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_firstLaunchDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  // Establecer fecha de primer lanzamiento
  static Future<void> setFirstLaunchDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstLaunchDateKey, date.toIso8601String());
  }

  // Obtener hora de recordatorio diario
  static Future<TimeOfDay?> getDailyReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('${_dailyReminderTimeKey}_hour');
    final minute = prefs.getInt('${_dailyReminderTimeKey}_minute');
    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  // Establecer hora de recordatorio diario
  static Future<void> setDailyReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_dailyReminderTimeKey}_hour', time.hour);
    await prefs.setInt('${_dailyReminderTimeKey}_minute', time.minute);
  }

  // Obtener meta semanal
  static Future<int> getWeeklyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_weeklyGoalKey) ?? 5; // 5 sesiones por defecto
  }

  // Establecer meta semanal
  static Future<void> setWeeklyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weeklyGoalKey, goal);
  }

  // Verificar si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  // Habilitar/deshabilitar notificaciones
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  // Obtener configuración completa del usuario
  static Future<UserPreferences> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferences(
      isOnboardingCompleted: prefs.getBool(_onboardingCompletedKey) ?? false,
      userGoal: prefs.getString(_userGoalKey) ?? '',
      userInterests: prefs.getStringList(_userInterestsKey) ?? [],
      preferredTime: prefs.getString(_preferredTimeKey) ?? 'morning',
      experienceLevel: prefs.getInt(_experienceLevelKey) ?? 0,
      firstLaunchDate: prefs.getString(_firstLaunchDateKey) != null
          ? DateTime.parse(prefs.getString(_firstLaunchDateKey)!)
          : null,
      dailyReminderTime:
          prefs.getInt('${_dailyReminderTimeKey}_hour') != null &&
              prefs.getInt('${_dailyReminderTimeKey}_minute') != null
          ? TimeOfDay(
              hour: prefs.getInt('${_dailyReminderTimeKey}_hour')!,
              minute: prefs.getInt('${_dailyReminderTimeKey}_minute')!,
            )
          : null,
      weeklyGoal: prefs.getInt(_weeklyGoalKey) ?? 5,
      notificationsEnabled: prefs.getBool(_notificationsEnabledKey) ?? true,
    );
  }

  // Guardar configuración completa del usuario
  static Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _onboardingCompletedKey,
      preferences.isOnboardingCompleted,
    );
    await prefs.setString(_userGoalKey, preferences.userGoal);
    await prefs.setStringList(_userInterestsKey, preferences.userInterests);
    await prefs.setString(_preferredTimeKey, preferences.preferredTime);
    await prefs.setInt(_experienceLevelKey, preferences.experienceLevel);
    if (preferences.firstLaunchDate != null) {
      await prefs.setString(
        _firstLaunchDateKey,
        preferences.firstLaunchDate!.toIso8601String(),
      );
    }
    if (preferences.dailyReminderTime != null) {
      await prefs.setInt(
        '${_dailyReminderTimeKey}_hour',
        preferences.dailyReminderTime!.hour,
      );
      await prefs.setInt(
        '${_dailyReminderTimeKey}_minute',
        preferences.dailyReminderTime!.minute,
      );
    }
    await prefs.setInt(_weeklyGoalKey, preferences.weeklyGoal);
    await prefs.setBool(
      _notificationsEnabledKey,
      preferences.notificationsEnabled,
    );
  }

  // Resetear configuración del usuario
  static Future<void> resetUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_userGoalKey);
    await prefs.remove(_userInterestsKey);
    await prefs.remove(_preferredTimeKey);
    await prefs.remove(_experienceLevelKey);
    await prefs.remove(_firstLaunchDateKey);
    await prefs.remove('${_dailyReminderTimeKey}_hour');
    await prefs.remove('${_dailyReminderTimeKey}_minute');
    await prefs.remove(_weeklyGoalKey);
    await prefs.remove(_notificationsEnabledKey);
  }
}

class UserPreferences {
  final bool isOnboardingCompleted;
  final String userGoal;
  final List<String> userInterests;
  final String preferredTime;
  final int experienceLevel;
  final DateTime? firstLaunchDate;
  final TimeOfDay? dailyReminderTime;
  final int weeklyGoal;
  final bool notificationsEnabled;

  UserPreferences({
    required this.isOnboardingCompleted,
    required this.userGoal,
    required this.userInterests,
    required this.preferredTime,
    required this.experienceLevel,
    this.firstLaunchDate,
    this.dailyReminderTime,
    required this.weeklyGoal,
    required this.notificationsEnabled,
  });

  UserPreferences copyWith({
    bool? isOnboardingCompleted,
    String? userGoal,
    List<String>? userInterests,
    String? preferredTime,
    int? experienceLevel,
    DateTime? firstLaunchDate,
    TimeOfDay? dailyReminderTime,
    int? weeklyGoal,
    bool? notificationsEnabled,
  }) {
    return UserPreferences(
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      userGoal: userGoal ?? this.userGoal,
      userInterests: userInterests ?? this.userInterests,
      preferredTime: preferredTime ?? this.preferredTime,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      firstLaunchDate: firstLaunchDate ?? this.firstLaunchDate,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
