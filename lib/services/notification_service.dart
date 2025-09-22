import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'smart_notification_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // Inicializar timezone
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Solicitar permisos para Android 13+
      await _requestPermissions();

      // Inicializar notificaciones inteligentes
      await SmartNotificationService.initialize();
    } catch (e) {
      print('Error al inicializar notificaciones: $e');
      // No lanzar el error, solo registrar y continuar
    }
  }

  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Manejar cuando el usuario toca una notificación
    print('Notificación tocada: ${response.payload}');
  }

  // Programar recordatorio diario de estado de ánimo
  static Future<void> scheduleMoodReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      0,
      '¿Cómo te sientes hoy?',
      'Tómate un momento para registrar tu estado de ánimo',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mood_reminder',
          'Recordatorios de estado de ánimo',
          channelDescription: 'Recordatorios para registrar tu estado de ánimo',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'mood_reminder',
    );
  }

  // Programar recordatorio de meditación
  static Future<void> scheduleMeditationReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      1,
      'Momento de meditar',
      'Dedica unos minutos a tu bienestar mental',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meditation_reminder',
          'Recordatorios de meditación',
          channelDescription: 'Recordatorios para meditar',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'meditation_reminder',
    );
  }

  // Programar recordatorio de diario
  static Future<void> scheduleJournalReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      2,
      'Reflexiona sobre tu día',
      'Escribe en tu diario y procesa tus pensamientos',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'journal_reminder',
          'Recordatorios de diario',
          channelDescription: 'Recordatorios para escribir en el diario',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'journal_reminder',
    );
  }

  // Notificación de logro
  static Future<void> showAchievementNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Logros',
          channelDescription: 'Notificaciones de logros y rachas',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      payload: 'achievement',
    );
  }

  // Notificación de reporte semanal
  static Future<void> showWeeklyReportNotification() async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Tu reporte semanal está listo',
      'Revisa tu progreso de esta semana en MindSpace',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_reports',
          'Reportes semanales',
          channelDescription: 'Reportes de progreso semanal',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      payload: 'weekly_report',
    );
  }

  // Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancelar notificación específica
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Obtener la próxima instancia de una hora específica
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Verificar si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.areNotificationsEnabled();
    return result ?? false;
  }

  // Abrir configuración de notificaciones
  static Future<void> openNotificationSettings() async {
    // Esta funcionalidad no está disponible en todas las versiones
    // Se puede implementar usando platform channels si es necesario
    print('Abrir configuración de notificaciones del sistema');
  }

  // Mostrar notificación inmediata
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'Notificaciones generales',
          channelDescription: 'Notificaciones generales de la aplicación',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      payload: payload,
    );
  }

  // Programar notificaciones inteligentes
  static Future<void> scheduleSmartNotifications() async {
    await SmartNotificationService.scheduleSmartNotifications();
  }

  // Enviar notificación inmediata inteligente
  static Future<void> sendSmartNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    await SmartNotificationService.sendImmediateNotification(
      title: title,
      body: body,
      type: type,
    );
  }

  // Cancelar notificaciones inteligentes
  static Future<void> cancelSmartNotifications() async {
    await SmartNotificationService.cancelAllNotifications();
  }

  // Obtener notificaciones pendientes
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await SmartNotificationService.getPendingNotifications();
  }
}
