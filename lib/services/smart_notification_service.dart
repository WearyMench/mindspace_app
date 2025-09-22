import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/mood_entry.dart';
import '../models/meditation_session.dart';
import '../models/journal_entry.dart';
import '../services/user_preferences_service.dart';

class SmartNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static const String _lastNotificationDateKey = 'last_notification_date';

  // Tipos de notificaciones inteligentes
  static const String _moodReminderType = 'mood_reminder';
  static const String _meditationReminderType = 'meditation_reminder';
  static const String _journalReminderType = 'journal_reminder';
  static const String _wellnessInsightType = 'wellness_insight';
  static const String _streakMotivationType = 'streak_motivation';
  static const String _goalReminderType = 'goal_reminder';

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = jsonDecode(payload);
      _handleNotificationAction(data);
    }
  }

  static void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String;
    // Implementar navegación basada en el tipo de notificación
    switch (type) {
      case _moodReminderType:
        // Navegar a mood tracking
        break;
      case _meditationReminderType:
        // Navegar a meditación
        break;
      case _journalReminderType:
        // Navegar a diario
        break;
      case _wellnessInsightType:
        // Navegar a insights
        break;
      case _streakMotivationType:
        // Navegar a estadísticas
        break;
      case _goalReminderType:
        // Navegar a perfil/objetivos
        break;
    }
  }

  // Programar notificaciones inteligentes basadas en patrones del usuario
  static Future<void> scheduleSmartNotifications() async {
    final userPreferences = await UserPreferencesService.getUserPreferences();
    if (!userPreferences.notificationsEnabled) return;

    // Cancelar notificaciones existentes
    await _notifications.cancelAll();

    // Programar recordatorios basados en horario preferido
    await _scheduleTimeBasedNotifications(userPreferences);

    // Programar notificaciones contextuales
    await _scheduleContextualNotifications();

    // Programar notificaciones de motivación
    await _scheduleMotivationalNotifications();
  }

  static Future<void> _scheduleTimeBasedNotifications(
    UserPreferences preferences,
  ) async {
    final preferredTime = preferences.preferredTime;
    TimeOfDay reminderTime;

    switch (preferredTime) {
      case 'morning':
        reminderTime = const TimeOfDay(hour: 8, minute: 0);
        break;
      case 'afternoon':
        reminderTime = const TimeOfDay(hour: 14, minute: 0);
        break;
      case 'evening':
        reminderTime = const TimeOfDay(hour: 20, minute: 0);
        break;
      default:
        reminderTime = const TimeOfDay(hour: 9, minute: 0);
    }

    // Recordatorio de estado de ánimo
    await _scheduleNotification(
      id: 1,
      title: '¿Cómo te sientes hoy?',
      body:
          'Registra tu estado de ánimo para mantener el seguimiento de tu bienestar',
      scheduledTime: _getNextScheduledTime(reminderTime),
      type: _moodReminderType,
    );

    // Recordatorio de meditación (2 horas después)
    final meditationTime = TimeOfDay(
      hour: (reminderTime.hour + 2) % 24,
      minute: reminderTime.minute,
    );
    await _scheduleNotification(
      id: 2,
      title: 'Momento de meditar',
      body:
          'Dedica unos minutos a la meditación para cuidar tu bienestar mental',
      scheduledTime: _getNextScheduledTime(meditationTime),
      type: _meditationReminderType,
    );
  }

  static Future<void> _scheduleContextualNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotificationDate = prefs.getString(_lastNotificationDateKey);
    final today = DateTime.now();

    // Solo enviar notificaciones contextuales una vez al día
    if (lastNotificationDate != null) {
      final lastDate = DateTime.parse(lastNotificationDate);
      if (today.difference(lastDate).inDays < 1) return;
    }

    // Verificar patrones del usuario
    final moodEntries = await _getRecentMoodEntries(7);
    final meditationSessions = await _getRecentMeditationSessions(7);
    final journalEntries = await _getRecentJournalEntries(7);

    // Notificación basada en estado de ánimo
    if (moodEntries.isNotEmpty) {
      final lastMood = moodEntries.first.overallMood;
      if (lastMood.value <= 2) {
        await _scheduleNotification(
          id: 10,
          title: 'Te estamos pensando',
          body:
              'Notamos que te has sentido un poco bajo. ¿Te gustaría probar una meditación relajante?',
          scheduledTime: tz.TZDateTime.now(
            tz.local,
          ).add(const Duration(hours: 1)),
          type: _wellnessInsightType,
        );
      }
    }

    // Notificación de racha de meditación
    if (meditationSessions.length >= 3) {
      await _scheduleNotification(
        id: 11,
        title: '¡Excelente racha!',
        body:
            'Has meditado ${meditationSessions.length} días esta semana. ¡Sigue así!',
        scheduledTime: tz.TZDateTime.now(
          tz.local,
        ).add(const Duration(hours: 2)),
        type: _streakMotivationType,
      );
    }

    // Notificación de diario
    if (journalEntries.isEmpty) {
      await _scheduleNotification(
        id: 12,
        title: 'Reflexiona sobre tu día',
        body:
            'Escribir en tu diario puede ayudarte a procesar tus pensamientos y emociones',
        scheduledTime: tz.TZDateTime.now(
          tz.local,
        ).add(const Duration(hours: 3)),
        type: _journalReminderType,
      );
    }

    // Guardar fecha de última notificación
    await prefs.setString(_lastNotificationDateKey, today.toIso8601String());
  }

  static Future<void> _scheduleMotivationalNotifications() async {
    final userPreferences = await UserPreferencesService.getUserPreferences();

    // Notificación de objetivo
    if (userPreferences.userGoal.isNotEmpty) {
      await _scheduleNotification(
        id: 20,
        title: 'Tu objetivo te espera',
        body:
            'Recuerda: ${userPreferences.userGoal}. ¿Cómo vas progresando hoy?',
        scheduledTime: tz.TZDateTime.now(
          tz.local,
        ).add(const Duration(days: 1, hours: 10)),
        type: _goalReminderType,
      );
    }

    // Notificación de bienvenida para nuevos usuarios
    if (userPreferences.firstLaunchDate != null) {
      final daysSinceLaunch = DateTime.now()
          .difference(userPreferences.firstLaunchDate!)
          .inDays;
      if (daysSinceLaunch == 3) {
        await _scheduleNotification(
          id: 21,
          title: '¡Sigue así!',
          body: 'Has estado usando MindSpace por 3 días. ¡Excelente comienzo!',
          scheduledTime: tz.TZDateTime.now(
            tz.local,
          ).add(const Duration(hours: 1)),
          type: _streakMotivationType,
        );
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    required String type,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mindspace_notifications',
          'MindSpace Notifications',
          channelDescription: 'Notificaciones inteligentes de MindSpace',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = jsonEncode({
      'type': type,
      'id': id,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _getNextScheduledTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // Obtener datos recientes (simulado - en implementación real usar providers)
  static Future<List<MoodEntry>> _getRecentMoodEntries(int days) async {
    // Implementar obtención de datos reales
    return [];
  }

  static Future<List<MeditationSession>> _getRecentMeditationSessions(
    int days,
  ) async {
    // Implementar obtención de datos reales
    return [];
  }

  static Future<List<JournalEntry>> _getRecentJournalEntries(int days) async {
    // Implementar obtención de datos reales
    return [];
  }

  // Notificaciones inmediatas para eventos importantes
  static Future<void> sendImmediateNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mindspace_immediate',
          'MindSpace Immediate',
          channelDescription: 'Notificaciones inmediatas de MindSpace',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = jsonEncode({
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Obtener notificaciones pendientes
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Verificar si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.areNotificationsEnabled();
    return result ?? false;
  }

  // Solicitar permisos de notificación
  static Future<bool> requestNotificationPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final granted = await androidImplementation
          .requestNotificationsPermission();
      return granted ?? false;
    }

    return true; // iOS no requiere solicitud explícita
  }
}
