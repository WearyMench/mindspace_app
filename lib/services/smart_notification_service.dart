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
        AndroidInitializationSettings('@mipmap/launcher_icon');

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
    print('Notification tapped: $type');

    // Guardar información de navegación pendiente
    _saveNavigationAction(type);
  }

  // Guardar acción de navegación para procesar cuando la app esté activa
  static Future<void> _saveNavigationAction(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_navigation', type);
    await prefs.setString(
      'pending_navigation_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  // Obtener y procesar acciones de navegación pendientes
  static Future<String?> getPendingNavigationAction() async {
    final prefs = await SharedPreferences.getInstance();
    final action = prefs.getString('pending_navigation');
    final timestamp = prefs.getString('pending_navigation_timestamp');

    if (action != null && timestamp != null) {
      final actionTime = DateTime.parse(timestamp);
      // Solo procesar si es reciente (menos de 5 minutos)
      if (DateTime.now().difference(actionTime).inMinutes < 5) {
        // Limpiar la acción pendiente
        await prefs.remove('pending_navigation');
        await prefs.remove('pending_navigation_timestamp');
        return action;
      }
    }

    return null;
  }

  // Programar notificaciones inteligentes basadas en patrones del usuario
  static Future<void> scheduleSmartNotifications() async {
    try {
      print('=== INICIANDO PROGRAMACIÓN DE NOTIFICACIONES ===');

      // Verificar si el servicio está inicializado
      if (!_initialized) {
        print('❌ SmartNotificationService no está inicializado');
        return;
      }

      // Obtener preferencias del usuario
      final userPreferences = await UserPreferencesService.getUserPreferences();
      print(
        '📱 Notificaciones habilitadas: ${userPreferences.notificationsEnabled}',
      );
      print(
        '⏰ Hora del recordatorio: ${userPreferences.reminderHour}:${userPreferences.reminderMinute}',
      );

      if (!userPreferences.notificationsEnabled) {
        print('❌ Notificaciones deshabilitadas por el usuario');
        return;
      }

      // Verificar permisos de notificaciones
      final notificationsEnabled = await areNotificationsEnabled();
      if (!notificationsEnabled) {
        print('❌ Notificaciones no están habilitadas en el sistema');
        return;
      }

      // Verificar permisos de alarmas exactas
      final canScheduleExact = await canScheduleExactAlarms();
      if (!canScheduleExact) {
        print(
          '⚠️ No se pueden programar alarmas exactas, intentando solicitar permiso...',
        );
        await requestExactAlarmPermission();
        return;
      }

      // Cancelar notificaciones existentes
      print('🗑️ Cancelando notificaciones existentes...');
      await _notifications.cancelAll();

      // Programar recordatorios basados en horario preferido
      print('⏰ Programando recordatorios basados en horario...');
      await _scheduleTimeBasedNotifications(userPreferences);

      // Verificar notificaciones pendientes
      final pending = await getPendingNotifications();
      print('✅ Notificaciones programadas: ${pending.length}');
      for (var notification in pending) {
        print('  - ID: ${notification.id}, Título: ${notification.title}');
      }

      print('=== PROGRAMACIÓN COMPLETADA ===');
    } catch (e) {
      print('❌ Error programando notificaciones inteligentes: $e');
    }
  }

  static Future<void> _scheduleTimeBasedNotifications(
    UserPreferences preferences,
  ) async {
    try {
      TimeOfDay reminderTime;

      // Usar la hora específica del recordatorio si está configurada
      if (preferences.reminderHour != null &&
          preferences.reminderMinute != null) {
        reminderTime = TimeOfDay(
          hour: preferences.reminderHour!,
          minute: preferences.reminderMinute!,
        );
        print(
          'Usando hora específica del recordatorio: ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}',
        );
      } else {
        // Fallback a los valores predefinidos
        final preferredTime = preferences.preferredTime;
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
        print(
          'Usando hora predefinida: ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}',
        );
      }

      // Solo programar si las notificaciones están habilitadas
      if (!preferences.notificationsEnabled) {
        print('Notificaciones deshabilitadas, no se programarán');
        return;
      }

      // Recordatorio de estado de ánimo
      final moodScheduledTime = _getNextScheduledTime(reminderTime);
      print(
        'Programando recordatorio de estado de ánimo para: $moodScheduledTime',
      );

      await _scheduleNotification(
        id: 1,
        title: '¿Cómo te sientes hoy?',
        body:
            'Registra tu estado de ánimo para mantener el seguimiento de tu bienestar',
        scheduledTime: moodScheduledTime,
        type: _moodReminderType,
      );

      // Recordatorio de meditación (2 horas después)
      final meditationTime = TimeOfDay(
        hour: (reminderTime.hour + 2) % 24,
        minute: reminderTime.minute,
      );
      final meditationScheduledTime = _getNextScheduledTime(meditationTime);
      print(
        'Programando recordatorio de meditación para: $meditationScheduledTime',
      );

      await _scheduleNotification(
        id: 2,
        title: 'Momento de meditar',
        body:
            'Dedica unos minutos a la meditación para cuidar tu bienestar mental',
        scheduledTime: meditationScheduledTime,
        type: _meditationReminderType,
      );
    } catch (e) {
      print('Error programando notificaciones basadas en tiempo: $e');
    }
  }

  static Future<void> _scheduleContextualNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastNotificationDate = prefs.getString(_lastNotificationDateKey);
      final today = DateTime.now();

      // Solo enviar notificaciones contextuales una vez al día
      if (lastNotificationDate != null) {
        final lastDate = DateTime.parse(lastNotificationDate);
        if (today.difference(lastDate).inDays < 1) return;
      }

      // Verificar patrones del usuario (simplificado para evitar crashes)
      // final moodEntries = await _getRecentMoodEntries(7);
      // final meditationSessions = await _getRecentMeditationSessions(7);
      // final journalEntries = await _getRecentJournalEntries(7);

      // Notificaciones contextuales temporalmente deshabilitadas para evitar crashes
      // TODO: Re-habilitar cuando se resuelvan los problemas de datos

      // Guardar fecha de última notificación
      await prefs.setString(_lastNotificationDateKey, today.toIso8601String());
    } catch (e) {
      print('Error programando notificaciones contextuales: $e');
    }
  }

  static Future<void> _scheduleMotivationalNotifications() async {
    try {
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
            body:
                'Has estado usando MindSpace por 3 días. ¡Excelente comienzo!',
            scheduledTime: tz.TZDateTime.now(
              tz.local,
            ).add(const Duration(hours: 1)),
            type: _streakMotivationType,
          );
        }
      }
    } catch (e) {
      print('Error programando notificaciones motivacionales: $e');
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
          icon: '@mipmap/launcher_icon',
          enableVibration: true,
          playSound: true,
          showWhen: true,
          when: null, // Se establecerá automáticamente
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

    print('Hora actual: $now');
    print('Hora programada inicial: $scheduled');

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
      print('Hora programada ajustada al día siguiente: $scheduled');
    }

    print('Hora final programada: $scheduled');
    return scheduled;
  }

  // Obtener datos recientes
  static Future<List<MoodEntry>> _getRecentMoodEntries(int days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('mood_entries') ?? [];
      final entries = entriesJson
          .map((json) => MoodEntry.fromJson(jsonDecode(json)))
          .toList();

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return entries.where((entry) => entry.date.isAfter(cutoffDate)).toList();
    } catch (e) {
      print('Error obteniendo entradas de mood: $e');
      return [];
    }
  }

  static Future<List<MeditationSession>> _getRecentMeditationSessions(
    int days,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('meditation_sessions') ?? [];
      final sessions = sessionsJson
          .map((json) => MeditationSession.fromJson(jsonDecode(json)))
          .toList();

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return sessions
          .where((session) => session.completedAt.isAfter(cutoffDate))
          .toList();
    } catch (e) {
      print('Error obteniendo sesiones de meditación: $e');
      return [];
    }
  }

  static Future<List<JournalEntry>> _getRecentJournalEntries(int days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('journal_entries') ?? [];
      final entries = entriesJson
          .map((json) => JournalEntry.fromJson(jsonDecode(json)))
          .toList();

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return entries
          .where((entry) => entry.createdAt.isAfter(cutoffDate))
          .toList();
    } catch (e) {
      print('Error obteniendo entradas de journal: $e');
      return [];
    }
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

  // Programar notificación de prueba para un tiempo específico
  static Future<void> scheduleTestNotification({
    required String title,
    required String body,
    required Duration delay,
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    await _scheduleNotification(
      id: 999,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      type: 'test_notification',
    );

    print('Notificación de prueba programada para: $scheduledTime');
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

  // Verificar si se pueden programar alarmas exactas
  static Future<bool> canScheduleExactAlarms() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.canScheduleExactNotifications() ??
          false;
    }

    return true; // iOS no tiene restricciones
  }

  // Solicitar permisos de alarmas exactas
  static Future<bool> requestExactAlarmPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.requestExactAlarmsPermission() ??
          false;
    }

    return true; // iOS no requiere este permiso
  }

  // Diagnóstico completo del sistema de notificaciones
  static Future<Map<String, dynamic>> getNotificationDiagnostics() async {
    final diagnostics = <String, dynamic>{};

    try {
      // Estado de inicialización
      diagnostics['initialized'] = _initialized;

      // Permisos de notificaciones
      diagnostics['notificationsEnabled'] = await areNotificationsEnabled();

      // Permisos de alarmas exactas
      diagnostics['canScheduleExactAlarms'] = await canScheduleExactAlarms();

      // Notificaciones pendientes
      final pending = await getPendingNotifications();
      diagnostics['pendingNotifications'] = pending.length;

      // Preferencias del usuario
      try {
        final userPreferences =
            await UserPreferencesService.getUserPreferences();
        diagnostics['userNotificationsEnabled'] =
            userPreferences.notificationsEnabled;
        diagnostics['preferredTime'] = userPreferences.preferredTime;
      } catch (e) {
        diagnostics['userPreferencesError'] = e.toString();
      }

      // Información de las notificaciones pendientes
      diagnostics['pendingDetails'] = pending
          .map(
            (notification) => {
              'id': notification.id,
              'title': notification.title,
              'body': notification.body,
              'payload': notification.payload,
            },
          )
          .toList();
    } catch (e) {
      diagnostics['error'] = e.toString();
    }

    return diagnostics;
  }
}
