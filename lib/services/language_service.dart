import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LanguageService extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');

  // Supported locales
  final List<Locale> supportedLocales = const [
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish
    Locale('fr', 'FR'), // French
    Locale('de', 'DE'), // German
    Locale('it', 'IT'), // Italian
    Locale('pt', 'PT'), // Portuguese
  ];

  Locale get currentLocale => _currentLocale;
  String get currentLanguageName => getLanguageName(_currentLocale);

  LanguageService() {
    _loadSavedLanguage();
  }

  Future<void> initialize() async {
    await _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('language_code');
    final savedCountryCode = prefs.getString('country_code');

    if (savedLanguageCode != null && savedCountryCode != null) {
      // Usar idioma guardado si existe
      _currentLocale = Locale(savedLanguageCode, savedCountryCode);
    } else {
      // Primera vez: detectar idioma del sistema
      _currentLocale = _detectSystemLanguage();
      // Guardar la detección automática
      await prefs.setString('language_code', _currentLocale.languageCode);
      await prefs.setString('country_code', _currentLocale.countryCode ?? '');
    }
    notifyListeners();
  }

  Future<void> changeLanguage(Locale locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    notifyListeners();
  }

  /// Detecta el idioma del sistema y retorna el más apropiado
  Locale _detectSystemLanguage() {
    // Obtener idiomas del sistema
    final systemLocales = ui.PlatformDispatcher.instance.locales;

    if (systemLocales.isNotEmpty) {
      final systemLocale = systemLocales.first;
      final systemLanguageCode = systemLocale.languageCode.toLowerCase();

      // Buscar si el idioma del sistema está soportado
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode.toLowerCase() == systemLanguageCode) {
          return supportedLocale;
        }
      }

      // Si no está soportado, buscar idiomas similares
      switch (systemLanguageCode) {
        case 'es':
        case 'es-':
          return const Locale('es', 'ES');
        case 'fr':
        case 'fr-':
          return const Locale('fr', 'FR');
        case 'de':
        case 'de-':
          return const Locale('de', 'DE');
        case 'it':
        case 'it-':
          return const Locale('it', 'IT');
        case 'pt':
        case 'pt-':
          return const Locale('pt', 'PT');
        default:
          // Fallback a inglés si no se encuentra coincidencia
          return const Locale('en', 'US');
      }
    }

    // Fallback a inglés si no se puede detectar
    return const Locale('en', 'US');
  }

  String getLocalizedText(String key) {
    switch (_currentLocale.languageCode) {
      case 'en':
        return _getEnglishText(key);
      case 'fr':
        return _getFrenchText(key);
      case 'de':
        return _getGermanText(key);
      case 'it':
        return _getItalianText(key);
      case 'pt':
        return _getPortugueseText(key);
      case 'es':
      default:
        return _getSpanishText(key);
    }
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      default:
        return locale.languageCode;
    }
  }

  String _getSpanishText(String key) {
    switch (key) {
      // App basics
      case 'app_title':
        return 'MindSpace';
      case 'good_morning':
        return 'Buenos días';
      case 'good_afternoon':
        return 'Buenas tardes';
      case 'good_evening':
        return 'Buenas tardes';
      case 'good_night':
        return 'Buenas noches';
      case 'home':
        return 'Inicio';
      case 'meditation':
        return 'Meditación';
      case 'journal':
        return 'Diario';
      case 'mood':
        return 'Estado de ánimo';
      case 'profile':
        return 'Perfil';
      case 'settings':
        return 'Configuración';
      case 'language':
        return 'Idioma';
      case 'theme':
        return 'Tema';
      case 'notifications':
        return 'Notificaciones';
      case 'backup':
        return 'Respaldo';
      case 'export':
        return 'Exportar';
      case 'achievements':
        return 'Logros';
      case 'search':
        return 'Buscar';
      case 'statistics':
        return 'Estadísticas';

      // Navigation
      case 'navigation_home':
        return 'Inicio';
      case 'navigation_meditation':
        return 'Meditación';
      case 'navigation_journal':
        return 'Diario';
      case 'navigation_mood':
        return 'Ánimo';
      case 'navigation_profile':
        return 'Perfil';

      // Common buttons
      case 'cancel':
        return 'Cancelar';
      case 'save':
        return 'Guardar';
      case 'delete':
        return 'Eliminar';
      case 'edit':
        return 'Editar';
      case 'ok':
        return 'OK';
      case 'close':
        return 'Cerrar';

      // Quick actions translations
      case 'mood_logged_today':
        return 'Estado registrado';
      case 'mood_today':
        return 'Estado de ánimo';
      case 'mood_logged_message':
        return '¡Bien hecho! Has registrado tu estado de hoy.';
      case 'mood_tap_to_log':
        return 'Toca para registrar cómo te sientes';
      case 'how_do_you_feel':
        return '¿Cómo te sientes hoy?';
      case 'how_are_you_feeling':
        return '¿Cómo te sientes?';
      case 'quick_actions':
        return 'Acciones Rápidas';
      case 'recent_activity':
        return 'Actividad Reciente';
      case 'mood_entry':
        return 'Entrada de Estado';
      case 'last_entry':
        return 'Última entrada';
      case 'meditation_session':
        return 'Sesión de Meditación';
      case 'last_session':
        return 'Última sesión';
      case 'journal_entry':
        return 'Entrada de Diario';
      case 'last_journal':
        return 'Último diario';
      case 'no_recent_activity':
        return 'Sin actividad reciente';
      case 'start_journey':
        return 'Comienza tu viaje de bienestar';
      case 'search_general_hint':
        return 'Buscar en estado de ánimo, meditaciones y diario...';
      case 'meditation_subtitle':
        return 'Encuentra tu momento de paz';
      case 'meditation_types':
        return 'Tipos de Meditación';
      case 'content_hint_mood':
        return '¿Cómo te sientes en este momento?';
      case 'mood_excellent':
        return 'Excelente';
      case 'mood_good':
        return 'Bien';
      case 'mood_neutral':
        return 'Neutral';
      case 'mood_bad':
        return 'Mal';
      case 'mood_terrible':
        return 'Terrible';
      case 'mood_energy':
        return 'Energía';
      case 'mood_stress':
        return 'Estrés';
      case 'mood_happiness':
        return 'Felicidad';
      case 'mood_anxiety':
        return 'Ansiedad';
      case 'mood_motivation':
        return 'Motivación';
      case 'mood_sleep':
        return 'Sueño';
      case 'mood_social':
        return 'Social';
      case 'mood_work':
        return 'Trabajo';
      case 'mood_happy':
        return 'Feliz';
      case 'mood_sad':
        return 'Triste';
      case 'mood_excited':
        return 'Emocionado';
      case 'mood_anxious':
        return 'Ansioso';
      case 'mood_calm':
        return 'Tranquilo';
      case 'mood_angry':
        return 'Enojado';
      case 'mood_grateful':
        return 'Agradecido';
      case 'mood_confused':
        return 'Confundido';
      case 'mood_hopeful':
        return 'Esperanzado';
      case 'mood_nostalgic':
        return 'Nostálgico';
      case 'content_hint_journal':
        return '¿Qué aprendiste de ti mismo hoy?';
      case 'prompt_how_do_you_feel':
        return '¿Cómo te sientes en este momento?';
      case 'prompt_best_thing_today':
        return '¿Qué fue lo mejor que te pasó hoy?';
      case 'prompt_challenge_today':
        return '¿Qué desafío enfrentaste hoy?';
      case 'prompt_grateful_today':
        return '¿Por qué estás agradecido hoy?';
      case 'prompt_learned_about_self':
        return '¿Qué aprendiste sobre ti mismo hoy?';
      case 'prompt_ideal_day':
        return '¿Cómo te gustaría que fuera tu día ideal?';
      case 'prompt_what_worries_you':
        return '¿Qué te preocupa en este momento?';
      case 'prompt_what_makes_proud':
        return '¿Qué te hace sentir orgulloso?';
      case 'prompt_dream_for_future':
        return '¿Qué sueño tienes para el futuro?';
      case 'prompt_person_inspired_you':
        return '¿Qué persona te inspiró hoy?';
      case 'theme_light':
        return 'Claro';
      case 'theme_dark':
        return 'Oscuro';
      case 'theme_system':
        return 'Sistema';
      case 'per_entry':
        return 'por entrada';
      case 'additional_details':
        return 'Detalles adicionales';
      case 'mood_saved_message':
        return 'Estado de ánimo registrado';

      case 'meditation_done_today':
        return 'Meditado hoy';
      case 'meditation_quick':
        return 'Meditar';
      case 'meditation_done_message':
        return '¡Excelente! Has meditado hoy.';
      case 'meditation_tap_to_start':
        return 'Toca para comenzar';
      case 'choose_meditation':
        return 'Elige tu meditación';
      case 'meditation_type':
        return 'Tipo de meditación';
      case 'duration':
        return 'Duración';
      case 'difficulty':
        return 'Dificultad';
      case 'start_meditation':
        return 'Comenzar';
      case 'meditation_starting_message':
        return 'Iniciando meditación';

      case 'journal_written_today':
        return 'Escrito hoy';
      case 'journal_write':
        return 'Escribir';
      case 'journal_written_message':
        return '¡Genial! Has escrito en tu diario hoy.';
      case 'journal_tap_to_write':
        return 'Toca para escribir una entrada';
      case 'new_entry':
        return 'Nueva entrada';
      case 'category':
        return 'Categoría';
      case 'title_optional':
        return 'Título (opcional)';
      case 'title_hint_journal':
        return 'Escribe un título para tu entrada...';
      case 'content':
        return 'Contenido';
      case 'mood_optional':
        return 'Estado de ánimo (opcional)';
      case 'entry_saved_message':
        return 'Entrada guardada en';

      // Progress section
      case 'progress_title':
        return 'Tu progreso';
      case 'days_streak':
        return 'días seguidos';
      case 'mood_stat':
        return 'Estado';
      case 'meditation_stat':
        return 'Meditación';
      case 'journal_stat':
        return 'Diario';

      // Meditation types
      case 'meditation_breathing':
        return 'Respiración';
      case 'meditation_mindfulness':
        return 'Mindfulness';
      case 'meditation_body_scan':
        return 'Escaneo corporal';
      case 'meditation_loving_kindness':
        return 'Bondad amorosa';
      case 'meditation_walking':
        return 'Caminar consciente';
      case 'meditation_gratitude':
        return 'Gratitud';
      case 'meditation_sleep':
        return 'Para dormir';
      case 'meditation_anxiety':
        return 'Anti-ansiedad';

      // Meditation descriptions
      case 'meditation_breathing_desc':
        return 'Técnicas de respiración consciente';
      case 'meditation_mindfulness_desc':
        return 'Atención plena al momento presente';
      case 'meditation_body_scan_desc':
        return 'Reconocimiento de sensaciones corporales';
      case 'meditation_loving_kindness_desc':
        return 'Cultivo de compasión y amor';
      case 'meditation_walking_desc':
        return 'Meditación en movimiento';
      case 'meditation_gratitude_desc':
        return 'Reflexión sobre lo que agradecemos';
      case 'meditation_sleep_desc':
        return 'Relajación profunda para el descanso';
      case 'meditation_anxiety_desc':
        return 'Técnicas para calmar la ansiedad';

      // Difficulty levels
      case 'difficulty_beginner':
        return 'Principiante';
      case 'difficulty_intermediate':
        return 'Intermedio';
      case 'difficulty_advanced':
        return 'Avanzado';

      // Meditation session
      case 'meditation_completed':
        return '¡Meditación completada!';
      case 'meditation_minutes':
        return 'minutos';
      case 'recent_sessions_title':
        return 'Sesiones recientes';
      case 'no_recent_sessions':
        return 'No hay sesiones recientes';
      case 'start_first_meditation':
        return 'Comienza tu primera meditación';
      case 'sessions':
        return 'Sesiones';
      case 'completed':
        return 'completadas';
      case 'time':
        return 'Tiempo';
      case 'minutes':
        return 'min';
      case 'total':
        return 'total';
      case 'streak':
        return 'Racha';
      case 'days':
        return 'días';
      case 'continue':
        return 'Continuar';
      case 'pause':
        return 'Pausar';
      case 'finish':
        return 'Finalizar';
      case 'instructions':
        return 'Instrucciones';

      // Meditation instructions
      case 'breathing_instructions':
        return 'Enfócate en tu respiración. Inhala lentamente por la nariz y exhala por la boca. Siente cómo el aire entra y sale de tu cuerpo.';
      case 'mindfulness_instructions':
        return 'Observa tus pensamientos sin juzgarlos. Cuando tu mente divague, gentilmente regresa tu atención al momento presente.';
      case 'body_scan_instructions':
        return 'Lleva tu atención a cada parte de tu cuerpo, desde los dedos de los pies hasta la cabeza. Observa las sensaciones sin juzgar.';
      case 'loving_kindness_instructions':
        return 'Envía pensamientos de amor y compasión a ti mismo, luego a tus seres queridos, y finalmente a todos los seres.';
      case 'gratitude_instructions':
        return 'Reflexiona sobre las cosas por las que estás agradecido. Permite que la gratitud llene tu corazón.';
      case 'sleep_instructions':
        return 'Relaja cada músculo de tu cuerpo. Imagina que estás en un lugar tranquilo y seguro. Deja que la calma te envuelva.';
      case 'anxiety_instructions':
        return 'Respira profundamente y exhala lentamente. Imagina que la ansiedad se disuelve con cada exhalación.';
      case 'default_meditation_instructions':
        return 'Encuentra una posición cómoda y cierra los ojos. Respira naturalmente y permite que tu mente se calme.';

      // Journal translations
      case 'journal_subtitle':
        return 'Reflexiona y escribe sobre tu día';
      case 'search_hint':
        return 'Buscar en entradas...';
      case 'all':
        return 'Todas';
      case 'no_entries_found':
        return 'No se encontraron entradas';
      case 'journal_empty':
        return 'Tu diario está vacío';
      case 'try_other_terms':
        return 'Intenta con otros términos de búsqueda';
      case 'start_writing':
        return 'Comienza a escribir tu primera entrada';
      case 'write_entry_button':
        return 'Escribir entrada';
      case 'edit_entry':
        return 'Editar entrada';
      case 'mood_tags':
        return 'Etiquetas de estado de ánimo';
      case 'private_entry':
        return 'Entrada privada';
      case 'content_required':
        return 'El contenido es requerido';
      case 'entry_updated':
        return 'Entrada actualizada';
      case 'entry_saved':
        return 'Entrada guardada';
      case 'information':
        return 'Información';
      case 'word_count':
        return 'Palabras';
      case 'reading_time':
        return 'Tiempo de lectura';
      case 'last_updated':
        return 'Última actualización';
      case 'words':
        return 'palabras';
      case 'delete_entry_title':
        return 'Eliminar entrada';
      case 'delete_entry_message':
        return '¿Estás seguro de que quieres eliminar esta entrada? Esta acción no se puede deshacer.';
      case 'delete_entry':
        return 'Eliminar entrada';
      case 'entry_default_title':
        return 'Entrada del';

      // Journal categories
      case 'category_daily':
        return 'Diario';
      case 'category_gratitude':
        return 'Gratitud';
      case 'category_reflection':
        return 'Reflexión';
      case 'category_goals':
        return 'Metas';
      case 'category_dreams':
        return 'Sueños';
      case 'category_challenges':
        return 'Desafíos';
      case 'category_memories':
        return 'Recuerdos';
      case 'category_ideas':
        return 'Ideas';

      // Profile section
      case 'user_profile':
        return 'Perfil de usuario';
      case 'member_since':
        return 'Miembro desde';
      case 'profile_subtitle':
        return 'Gestiona tu cuenta y configuración';

      // Settings
      case 'app_settings':
        return 'Configuración de la aplicación';
      case 'data_privacy':
        return 'Datos y Privacidad';
      case 'language_subtitle':
        return 'Selecciona tu idioma preferido';
      case 'select_theme':
        return 'Seleccionar tema';
      case 'select_theme_subtitle':
        return 'Elige la apariencia que prefieras';
      case 'light_theme':
        return 'Tema claro para uso diurno';
      case 'dark_theme':
        return 'Tema oscuro para uso nocturno';
      case 'system_theme':
        return 'Seguir configuración del sistema';

      // Search screen
      case 'search_title':
        return 'Búsqueda';
      case 'filters':
        return 'Filtros';
      case 'clear_filters':
        return 'Limpiar';
      case 'apply_filters':
        return 'Aplicar';
      case 'category_filter':
        return 'Categoría';
      case 'sort_by':
        return 'Ordenar por';
      case 'date_range':
        return 'Rango de fechas';
      case 'from_date':
        return 'Desde';
      case 'to_date':
        return 'Hasta';
      case 'recent_entries':
        return 'Entradas Recientes';
      case 'no_results':
        return 'Sin resultados';
      case 'recent_entries_subtitle':
        return 'Tus entradas más recientes aparecerán aquí';
      case 'no_results_subtitle':
        return 'Intenta con otros términos de búsqueda';
      case 'open_result':
        return 'Abrir';

      // Mood tracking
      case 'mood_subtitle':
        return 'Rastrea tu bienestar emocional';
      case 'mood_trend_chart':
        return 'Tendencia de estado de ánimo';
      case 'time_ranges':
        return 'Rangos de tiempo';
      case 'days_7':
        return '7 días';
      case 'days_30':
        return '30 días';
      case 'days_90':
        return '90 días';
      case 'insufficient_data':
        return 'Datos insuficientes';
      case 'register_mood_trends':
        return 'Registra tu estado de ánimo para ver tendencias';
      case 'recent_entries_title':
        return 'Entradas recientes';
      case 'no_recent_entries':
        return 'No hay entradas recientes';
      case 'start_tracking_mood':
        return 'Comienza a rastrear tu estado de ánimo';
      case 'average':
        return 'Promedio';
      case 'streak_days':
        return 'días seguidos';
      case 'records':
        return 'registros';

      // Profile translations
      case 'registros':
        return 'registros';
      case 'sesiones':
        return 'sesiones';
      case 'entradas':
        return 'entradas';
      case 'notifications_subtitle':
        return 'Gestiona tus notificaciones';
      case 'reminder_time':
        return 'Hora de recordatorio';
      case 'weekly_reports':
        return 'Reportes semanales';
      case 'weekly_reports_subtitle':
        return 'Recibe resúmenes semanales de tu progreso';
      case 'export_data':
        return 'Exportar datos';
      case 'export_data_subtitle':
        return 'Descarga tus datos personales';
      case 'backup_restore_subtitle':
        return 'Respalda y restaura tu información';
      case 'backup_info':
        return 'Mantén tus datos seguros y accesibles';
      case 'why_backup':
        return '¿Por qué hacer respaldo?';
      case 'backup_benefits':
        return 'Crear respaldos regulares te ayuda a:';
      case 'protect_data':
        return '• Proteger tu información personal';
      case 'recover_data':
        return '• Recuperar datos en caso de pérdida';
      case 'maintain_history':
        return '• Mantener tu historial completo';
      case 'transfer_data':
        return '• Transferir datos entre dispositivos';
      case 'backup_recommendation':
        return 'Se recomienda crear respaldos semanalmente para mantener tus datos actualizados.';
      case 'create_backup_title':
        return 'Crear Respaldo';
      case 'create_backup_description':
        return 'Genera un archivo de respaldo con todos tus datos de MindSpace.';
      case 'mood_data':
        return 'Estado de ánimo';
      case 'all_entries':
        return 'Todas las entradas';
      case 'all_sessions':
        return 'Todas las sesiones';
      case 'settings_data':
        return 'Configuraciones';
      case 'preferences_settings':
        return 'Preferencias y configuraciones';
      case 'creating_backup':
        return 'Creando respaldo...';
      case 'backup_created_successfully':
        return 'Respaldo creado exitosamente';
      case 'backup_error':
        return 'Error al crear respaldo';
      case 'restore_data_title':
        return 'Restaurar Datos';
      case 'restore_data_description':
        return 'Restaura tus datos desde un archivo de respaldo anterior.';
      case 'restore_warning':
        return 'ADVERTENCIA: Esta acción reemplazará todos tus datos actuales con los datos del respaldo.';
      case 'restoring':
        return 'Restaurando...';
      case 'restore_from_file':
        return 'Restaurar desde archivo';
      case 'confirm_restoration':
        return 'Confirmar restauración';
      case 'confirm_restoration_message':
        return '¿Estás seguro de que quieres restaurar los datos? Esta acción reemplazará todos tus datos actuales.';
      case 'restore':
        return 'Restaurar';
      case 'no_file_selected':
        return 'No se seleccionó ningún archivo';
      case 'invalid_backup_file':
        return 'Archivo de respaldo inválido';
      case 'backup_restored_successfully':
        return 'Datos restaurados exitosamente';
      case 'restore_error':
        return 'Error al restaurar datos';
      case 'delete_account_subtitle':
        return 'Elimina permanentemente tu cuenta';
      case 'achievements_subtitle':
        return 'Ve tus logros y medallas';
      case 'help_support_subtitle':
        return 'Obtén ayuda y soporte';
      case 'privacy_policy_subtitle':
        return 'Lee nuestra política de privacidad';
      case 'terms_of_service_subtitle':
        return 'Lee nuestros términos de servicio';
      case 'edit_profile':
        return 'Editar perfil';
      case 'edit_profile_message':
        return 'Esta función estará disponible pronto';
      case 'help_message':
        return 'Si necesitas ayuda, puedes contactarnos en support@mindspace.app';
      case 'privacy_message':
        return 'Respetamos tu privacidad. Tus datos están seguros con nosotros.';
      case 'spanish_default':
        return 'Idioma predeterminado';
      case 'english_default':
        return 'Default language';
      case 'french_default':
        return 'Langue par défaut';
      case 'german_default':
        return 'Standardsprache';
      case 'italian_default':
        return 'Lingua predefinita';
      case 'portuguese_default':
        return 'Idioma padrão';
      case 'selected_language':
        return 'Idioma seleccionado';

      // Notification settings
      case 'notification_settings_title':
        return 'Configuración de Notificaciones';
      case 'notification_settings_subtitle':
        return 'Personaliza cuándo y cómo recibir notificaciones';
      case 'general_settings':
        return 'Configuración General';
      case 'daily_notifications':
        return 'Notificaciones diarias';
      case 'daily_notifications_desc':
        return 'Recibe recordatorios diarios para usar la app';
      case 'weekly_reports_notifications':
        return 'Reportes semanales';
      case 'weekly_reports_notifications_desc':
        return 'Recibe un resumen de tu progreso cada semana';
      case 'reminder_schedules':
        return 'Horarios de Recordatorios';
      case 'daily_reminder_time':
        return 'Hora de recordatorio diario';
      case 'meditation_reminder':
        return 'Recordatorio de meditación';
      case 'mood_reminder':
        return 'Recordatorio de estado de ánimo';
      case 'notification_types':
        return 'Tipos de Notificaciones';
      case 'meditation_reminders':
        return 'Recordatorios de meditación';
      case 'meditation_reminders_desc':
        return 'Te recordamos cuando es hora de meditar';
      case 'mood_reminders':
        return 'Recordatorios de estado de ánimo';
      case 'mood_reminders_desc':
        return 'Te recordamos registrar cómo te sientes';
      case 'test_notifications':
        return 'Probar Notificaciones';
      case 'test_notifications_desc':
        return 'Envía una notificación de prueba para verificar que todo funciona correctamente.';
      case 'send_test_notification':
        return 'Enviar Notificación de Prueba';
      case 'test_notification_sent':
        return 'Notificación de prueba enviada';
      case 'test_notification_error':
        return 'Error al enviar notificación';

      // Theme preview
      case 'theme_preview':
        return 'Vista previa del tema';
      case 'primary_color':
        return 'Primario';
      case 'secondary_color':
        return 'Secundario';
      case 'surface_color':
        return 'Superficie';
      case 'sample_text':
        return 'Texto de ejemplo';
      case 'sample_text_description':
        return 'Este es un texto de ejemplo que muestra cómo se ve el tema actual.';
      case 'sample_button':
        return 'Botón de ejemplo';
      case 'mood_tab':
        return 'Estado';
      case 'meditation_tab':
        return 'Meditación';
      case 'journal_tab':
        return 'Diario';
      case 'mood_chart_title':
        return 'Tendencia del Estado de Ánimo';
      case 'meditation_chart_title':
        return 'Sesiones de Meditación';
      case 'journal_chart_title':
        return 'Entradas del Diario';
      case 'no_data_chart':
        return 'No hay suficientes datos para mostrar el gráfico';
      case 'trends':
        return 'Tendencias';
      case 'best_day_week':
        return 'Mejor día de la semana';
      case 'monday':
        return 'Lunes';
      case 'preferred_time':
        return 'Hora preferida';
      case 'morning':
        return 'Mañana';
      case 'most_common_state':
        return 'Estado más común';
      case 'good':
        return 'Bueno';
      case 'favorite_type':
        return 'Tipo favorito';
      case 'mindfulness':
        return 'Atención plena';
      case 'average_duration':
        return 'Duración promedio';
      case 'best_moment':
        return 'Mejor momento';
      case 'favorite_category':
        return 'Categoría favorita';
      case 'reflection':
        return 'Reflexión';
      case 'average_length':
        return 'Longitud promedio';
      case 'words_count':
        return '150 palabras';
      case 'most_active_day':
        return 'Día más activo';
      case 'sunday':
        return 'Domingo';
      case 'all_achievements':
        return 'Todos';
      case 'mood_achievements':
        return 'Estado';
      case 'meditation_achievements':
        return 'Meditación';
      case 'journal_achievements':
        return 'Diario';
      case 'your_progress':
        return 'Tu Progreso';
      case 'level':
        return 'Nivel';
      case 'points':
        return 'Puntos';
      case 'locked':
        return 'Bloqueado';
      case 'pts':
        return 'pts';
      case 'achievement_first_day':
        return 'Primer Día';
      case 'achievement_first_day_desc':
        return 'Registra tu primer estado de ánimo';
      case 'achievement_week':
        return 'Una Semana';
      case 'achievement_week_desc':
        return 'Registra tu estado de ánimo por 7 días seguidos';
      case 'achievement_month':
        return 'Un Mes';
      case 'achievement_month_desc':
        return 'Registra tu estado de ánimo por 30 días seguidos';
      case 'achievement_optimist':
        return 'Optimista';
      case 'achievement_optimist_desc':
        return 'Mantén un estado positivo por 5 días seguidos';
      case 'achievement_first_meditation':
        return 'Primera Meditación';
      case 'achievement_first_meditation_desc':
        return 'Completa tu primera sesión de meditación';
      case 'achievement_zen_week':
        return 'Semana Zen';
      case 'achievement_zen_week_desc':
        return 'Medita por 7 días seguidos';
      case 'achievement_hour_peace':
        return 'Hora de Paz';
      case 'achievement_hour_peace_desc':
        return 'Acumula 60 minutos de meditación';
      case 'achievement_zen_master':
        return 'Maestro Zen';
      case 'achievement_zen_master_desc':
        return 'Completa 100 sesiones de meditación';
      case 'achievement_first_entry':
        return 'Primera Entrada';
      case 'achievement_first_entry_desc':
        return 'Escribe tu primera entrada en el diario';
      case 'achievement_consistent_writer':
        return 'Escritor Consistente';
      case 'achievement_consistent_writer_desc':
        return 'Escribe en el diario por 7 días seguidos';
      case 'achievement_words_wisdom':
        return 'Palabras de Sabiduría';
      case 'achievement_words_wisdom_desc':
        return 'Escribe 1000 palabras en total';
      case 'achievement_deep_reflection':
        return 'Reflexión Profunda';
      case 'achievement_deep_reflection_desc':
        return 'Escribe 50 entradas de reflexión';
      case 'export_data_title':
        return 'Exportar Datos';
      case 'export_info_title':
        return 'Información sobre la exportación';
      case 'export_info_description':
        return 'Puedes exportar tus datos en formato JSON o CSV. Los datos incluyen:';
      case 'export_mood_entries':
        return '• Entradas de estado de ánimo';
      case 'export_meditation_sessions':
        return '• Sesiones de meditación';
      case 'export_journal_entries':
        return '• Entradas de diario personal';
      case 'export_settings_preferences':
        return '• Configuraciones y preferencias';
      case 'export_security_note':
        return 'Los datos se exportan de forma segura y solo se almacenan localmente en tu dispositivo.';
      case 'select_data_to_export':
        return 'Seleccionar datos a exportar';
      case 'mood_data_title':
        return 'Estado de ánimo';
      case 'mood_data_description':
        return 'Incluye todas tus entradas de estado de ánimo';
      case 'meditation_data_title':
        return 'Meditación';
      case 'meditation_data_description':
        return 'Incluye todas tus sesiones de meditación';
      case 'journal_data_title':
        return 'Diario personal';
      case 'journal_data_description':
        return 'Incluye todas tus entradas de diario';
      case 'export_options_title':
        return 'Opciones de exportación';
      case 'json_format_title':
        return 'Formato JSON';
      case 'json_format_description':
        return 'Formato estructurado, ideal para importar en otras aplicaciones';
      case 'csv_format_title':
        return 'Formato CSV';
      case 'csv_format_description':
        return 'Formato de hoja de cálculo, ideal para análisis de datos';
      case 'exporting':
        return 'Exportando...';
      case 'export_data_button':
        return 'Exportar Datos';
      case 'export_success':
        return 'Datos exportados exitosamente';
      case 'export_error':
        return 'Error al exportar datos';

      // Other common texts
      case 'statistics_title':
        return 'Estadísticas';
      case 'statistics_subtitle':
        return 'Tu progreso en detalle';
      case 'about':
        return 'Acerca de';
      case 'version':
        return 'Versión';
      case 'help_support':
        return 'Ayuda y soporte';
      case 'privacy_policy':
        return 'Política de privacidad';
      case 'terms_of_service':
        return 'Términos de servicio';
      case 'about_message':
        return 'MindSpace es tu compañero personal para el bienestar mental. Registra tu estado de ánimo, medita y escribe en tu diario para llevar un seguimiento de tu crecimiento personal.';
      case 'terms_of_service_message':
        return 'Al usar MindSpace, aceptas nuestros términos y condiciones de servicio.';
      case 'delete_account':
        return 'Eliminar cuenta';
      case 'delete_account_confirm':
        return 'Eliminar cuenta';
      case 'delete_account_message':
        return 'Esta acción eliminará permanentemente todos tus datos. Esta acción no se puede deshacer.';

      default:
        return key;
    }
  }

  String _getEnglishText(String key) {
    switch (key) {
      // App basics
      case 'app_title':
        return 'MindSpace';
      case 'good_morning':
        return 'Good morning';
      case 'good_afternoon':
        return 'Good afternoon';
      case 'good_evening':
        return 'Good evening';
      case 'good_night':
        return 'Good night';
      case 'home':
        return 'Home';
      case 'meditation':
        return 'Meditation';
      case 'journal':
        return 'Journal';
      case 'mood':
        return 'Mood';
      case 'profile':
        return 'Profile';
      case 'settings':
        return 'Settings';
      case 'language':
        return 'Language';
      case 'theme':
        return 'Theme';
      case 'notifications':
        return 'Notifications';
      case 'backup':
        return 'Backup';
      case 'export':
        return 'Export';
      case 'achievements':
        return 'Achievements';
      case 'search':
        return 'Search';
      case 'statistics':
        return 'Statistics';

      // Navigation
      case 'navigation_home':
        return 'Home';
      case 'navigation_meditation':
        return 'Meditation';
      case 'navigation_journal':
        return 'Journal';
      case 'navigation_mood':
        return 'Mood';
      case 'navigation_profile':
        return 'Profile';

      // Common buttons
      case 'cancel':
        return 'Cancel';
      case 'save':
        return 'Save';
      case 'delete':
        return 'Delete';
      case 'edit':
        return 'Edit';
      case 'ok':
        return 'OK';
      case 'close':
        return 'Close';

      // Quick actions translations
      case 'mood_logged_today':
        return 'Mood logged';
      case 'mood_today':
        return 'Mood';
      case 'mood_logged_message':
        return 'Great! You\'ve logged your mood today.';
      case 'mood_tap_to_log':
        return 'Tap to log how you feel';
      case 'how_do_you_feel':
        return 'How do you feel today?';
      case 'how_are_you_feeling':
        return 'How are you feeling?';
      case 'quick_actions':
        return 'Quick Actions';
      case 'recent_activity':
        return 'Recent Activity';
      case 'mood_entry':
        return 'Mood Entry';
      case 'last_entry':
        return 'Last entry';
      case 'meditation_session':
        return 'Meditation Session';
      case 'last_session':
        return 'Last session';
      case 'journal_entry':
        return 'Journal Entry';
      case 'last_journal':
        return 'Last journal';
      case 'no_recent_activity':
        return 'No recent activity';
      case 'start_journey':
        return 'Start your wellness journey';
      case 'search_general_hint':
        return 'Search in mood, meditations and journal...';
      case 'meditation_subtitle':
        return 'Find your moment of peace';
      case 'meditation_types':
        return 'Meditation Types';
      case 'content_hint_mood':
        return 'How are you feeling right now?';
      case 'mood_excellent':
        return 'Excellent';
      case 'mood_good':
        return 'Good';
      case 'mood_neutral':
        return 'Neutral';
      case 'mood_bad':
        return 'Bad';
      case 'mood_terrible':
        return 'Terrible';
      case 'mood_energy':
        return 'Energy';
      case 'mood_stress':
        return 'Stress';
      case 'mood_happiness':
        return 'Happiness';
      case 'mood_anxiety':
        return 'Anxiety';
      case 'mood_motivation':
        return 'Motivation';
      case 'mood_sleep':
        return 'Sleep';
      case 'mood_social':
        return 'Social';
      case 'mood_work':
        return 'Work';
      case 'mood_happy':
        return 'Happy';
      case 'mood_sad':
        return 'Sad';
      case 'mood_excited':
        return 'Excited';
      case 'mood_anxious':
        return 'Anxious';
      case 'mood_calm':
        return 'Calm';
      case 'mood_angry':
        return 'Angry';
      case 'mood_grateful':
        return 'Grateful';
      case 'mood_confused':
        return 'Confused';
      case 'mood_hopeful':
        return 'Hopeful';
      case 'mood_nostalgic':
        return 'Nostalgic';
      case 'content_hint_journal':
        return 'What did you learn about yourself today?';
      case 'prompt_how_do_you_feel':
        return 'How do you feel right now?';
      case 'prompt_best_thing_today':
        return 'What was the best thing that happened to you today?';
      case 'prompt_challenge_today':
        return 'What challenge did you face today?';
      case 'prompt_grateful_today':
        return 'What are you grateful for today?';
      case 'prompt_learned_about_self':
        return 'What did you learn about yourself today?';
      case 'prompt_ideal_day':
        return 'How would you like your ideal day to be?';
      case 'prompt_what_worries_you':
        return 'What worries you right now?';
      case 'prompt_what_makes_proud':
        return 'What makes you feel proud?';
      case 'prompt_dream_for_future':
        return 'What dream do you have for the future?';
      case 'prompt_person_inspired_you':
        return 'What person inspired you today?';
      case 'theme_light':
        return 'Light';
      case 'theme_dark':
        return 'Dark';
      case 'theme_system':
        return 'System';
      case 'per_entry':
        return 'per entry';
      case 'additional_details':
        return 'Additional details';
      case 'mood_saved_message':
        return 'Mood logged';

      case 'meditation_done_today':
        return 'Meditated today';
      case 'meditation_quick':
        return 'Meditate';
      case 'meditation_done_message':
        return 'Excellent! You\'ve meditated today.';
      case 'meditation_tap_to_start':
        return 'Tap to start';
      case 'choose_meditation':
        return 'Choose your meditation';
      case 'meditation_type':
        return 'Meditation type';
      case 'duration':
        return 'Duration';
      case 'difficulty':
        return 'Difficulty';
      case 'start_meditation':
        return 'Start';
      case 'meditation_starting_message':
        return 'Starting meditation';

      case 'journal_written_today':
        return 'Written today';
      case 'journal_write':
        return 'Write';
      case 'journal_written_message':
        return 'Great! You\'ve written in your journal today.';
      case 'journal_tap_to_write':
        return 'Tap to write an entry';
      case 'new_entry':
        return 'New entry';
      case 'category':
        return 'Category';
      case 'title_optional':
        return 'Title (optional)';
      case 'title_hint_journal':
        return 'Write a title for your entry...';
      case 'content':
        return 'Content';
      case 'mood_optional':
        return 'Mood (optional)';
      case 'entry_saved_message':
        return 'Entry saved in';

      // Progress section
      case 'progress_title':
        return 'Your progress';
      case 'days_streak':
        return 'days streak';
      case 'mood_stat':
        return 'Mood';
      case 'meditation_stat':
        return 'Meditation';
      case 'journal_stat':
        return 'Journal';

      // Meditation types
      case 'meditation_breathing':
        return 'Breathing';
      case 'meditation_mindfulness':
        return 'Mindfulness';
      case 'meditation_body_scan':
        return 'Body Scan';
      case 'meditation_loving_kindness':
        return 'Loving Kindness';
      case 'meditation_walking':
        return 'Walking';
      case 'meditation_gratitude':
        return 'Gratitude';
      case 'meditation_sleep':
        return 'Sleep';
      case 'meditation_anxiety':
        return 'Anti-Anxiety';

      // Meditation descriptions
      case 'meditation_breathing_desc':
        return 'Conscious breathing techniques';
      case 'meditation_mindfulness_desc':
        return 'Present moment awareness';
      case 'meditation_body_scan_desc':
        return 'Body sensation recognition';
      case 'meditation_loving_kindness_desc':
        return 'Cultivating compassion and love';
      case 'meditation_walking_desc':
        return 'Meditation in motion';
      case 'meditation_gratitude_desc':
        return 'Reflection on what we\'re grateful for';
      case 'meditation_sleep_desc':
        return 'Deep relaxation for rest';
      case 'meditation_anxiety_desc':
        return 'Techniques to calm anxiety';

      // Difficulty levels
      case 'difficulty_beginner':
        return 'Beginner';
      case 'difficulty_intermediate':
        return 'Intermediate';
      case 'difficulty_advanced':
        return 'Advanced';

      // Meditation session
      case 'meditation_completed':
        return 'Meditation completed!';
      case 'meditation_minutes':
        return 'minutes';
      case 'recent_sessions_title':
        return 'Recent Sessions';
      case 'no_recent_sessions':
        return 'No recent sessions';
      case 'start_first_meditation':
        return 'Start your first meditation';
      case 'sessions':
        return 'Sessions';
      case 'completed':
        return 'completed';
      case 'time':
        return 'Time';
      case 'minutes':
        return 'min';
      case 'total':
        return 'total';
      case 'streak':
        return 'Streak';
      case 'days':
        return 'days';
      case 'continue':
        return 'Continue';
      case 'pause':
        return 'Pause';
      case 'finish':
        return 'Finish';
      case 'instructions':
        return 'Instructions';

      // Meditation instructions
      case 'breathing_instructions':
        return 'Focus on your breathing. Inhale slowly through your nose and exhale through your mouth. Feel how the air enters and leaves your body.';
      case 'mindfulness_instructions':
        return 'Observe your thoughts without judging them. When your mind wanders, gently return your attention to the present moment.';
      case 'body_scan_instructions':
        return 'Bring your attention to each part of your body, from your toes to your head. Observe sensations without judgment.';
      case 'loving_kindness_instructions':
        return 'Send thoughts of love and compassion to yourself, then to your loved ones, and finally to all beings.';
      case 'gratitude_instructions':
        return 'Reflect on the things you are grateful for. Allow gratitude to fill your heart.';
      case 'sleep_instructions':
        return 'Relax every muscle in your body. Imagine you are in a peaceful and safe place. Let calmness envelop you.';
      case 'anxiety_instructions':
        return 'Breathe deeply and exhale slowly. Imagine anxiety dissolving with each exhalation.';
      case 'default_meditation_instructions':
        return 'Find a comfortable position and close your eyes. Breathe naturally and allow your mind to calm down.';

      // Journal translations
      case 'journal_subtitle':
        return 'Reflect and write about your day';
      case 'search_hint':
        return 'Search entries...';
      case 'all':
        return 'All';
      case 'no_entries_found':
        return 'No entries found';
      case 'journal_empty':
        return 'Your journal is empty';
      case 'try_other_terms':
        return 'Try other search terms';
      case 'start_writing':
        return 'Start writing your first entry';
      case 'write_entry_button':
        return 'Write Entry';
      case 'edit_entry':
        return 'Edit Entry';
      case 'mood_tags':
        return 'Mood Tags';
      case 'private_entry':
        return 'Private Entry';
      case 'content_required':
        return 'Content is required';
      case 'entry_updated':
        return 'Entry updated';
      case 'entry_saved':
        return 'Entry saved';
      case 'information':
        return 'Information';
      case 'word_count':
        return 'Words';
      case 'reading_time':
        return 'Reading Time';
      case 'last_updated':
        return 'Last Updated';
      case 'words':
        return 'words';
      case 'delete_entry_title':
        return 'Delete Entry';
      case 'delete_entry_message':
        return 'Are you sure you want to delete this entry? This action cannot be undone.';
      case 'delete_entry':
        return 'Delete Entry';
      case 'entry_default_title':
        return 'Entry from';

      // Journal categories
      case 'category_daily':
        return 'Daily';
      case 'category_gratitude':
        return 'Gratitude';
      case 'category_reflection':
        return 'Reflection';
      case 'category_goals':
        return 'Goals';
      case 'category_dreams':
        return 'Dreams';
      case 'category_challenges':
        return 'Challenges';
      case 'category_memories':
        return 'Memories';
      case 'category_ideas':
        return 'Ideas';

      // Profile section
      case 'user_profile':
        return 'User Profile';
      case 'member_since':
        return 'Member since';
      case 'profile_subtitle':
        return 'Manage your account and settings';

      // Settings
      case 'app_settings':
        return 'App Settings';
      case 'data_privacy':
        return 'Data & Privacy';
      case 'language_subtitle':
        return 'Select your preferred language';
      case 'select_theme':
        return 'Select Theme';
      case 'select_theme_subtitle':
        return 'Choose your preferred appearance';
      case 'light_theme':
        return 'Light theme for daytime use';
      case 'dark_theme':
        return 'Dark theme for nighttime use';
      case 'system_theme':
        return 'Follow system settings';

      // Search screen
      case 'search_title':
        return 'Search';
      case 'filters':
        return 'Filters';
      case 'clear_filters':
        return 'Clear';
      case 'apply_filters':
        return 'Apply';
      case 'category_filter':
        return 'Category';
      case 'sort_by':
        return 'Sort by';
      case 'date_range':
        return 'Date range';
      case 'from_date':
        return 'From';
      case 'to_date':
        return 'To';
      case 'recent_entries':
        return 'Recent Entries';
      case 'no_results':
        return 'No results';
      case 'recent_entries_subtitle':
        return 'Your most recent entries will appear here';
      case 'no_results_subtitle':
        return 'Try with other search terms';
      case 'open_result':
        return 'Open';

      // Mood tracking
      case 'mood_subtitle':
        return 'Track your emotional well-being';
      case 'mood_trend_chart':
        return 'Mood trend chart';
      case 'time_ranges':
        return 'Time ranges';
      case 'days_7':
        return '7 days';
      case 'days_30':
        return '30 days';
      case 'days_90':
        return '90 days';
      case 'insufficient_data':
        return 'Insufficient data';
      case 'register_mood_trends':
        return 'Log your mood to see trends';
      case 'recent_entries_title':
        return 'Recent entries';
      case 'no_recent_entries':
        return 'No recent entries';
      case 'start_tracking_mood':
        return 'Start tracking your mood';
      case 'average':
        return 'Average';
      case 'streak_days':
        return 'days streak';
      case 'records':
        return 'records';

      // Profile translations
      case 'registros':
        return 'records';
      case 'sesiones':
        return 'sessions';
      case 'entradas':
        return 'entries';
      case 'notifications_subtitle':
        return 'Manage your notifications';
      case 'reminder_time':
        return 'Reminder time';
      case 'weekly_reports':
        return 'Weekly reports';
      case 'weekly_reports_subtitle':
        return 'Receive weekly summaries of your progress';
      case 'export_data':
        return 'Export data';
      case 'export_data_subtitle':
        return 'Download your personal data';
      case 'backup_restore_subtitle':
        return 'Backup and restore your information';
      case 'backup_info':
        return 'Keep your data safe and accessible';
      case 'why_backup':
        return 'Why backup?';
      case 'backup_benefits':
        return 'Creating regular backups helps you to:';
      case 'protect_data':
        return '• Protect your personal information';
      case 'recover_data':
        return '• Recover data in case of loss';
      case 'maintain_history':
        return '• Maintain your complete history';
      case 'transfer_data':
        return '• Transfer data between devices';
      case 'backup_recommendation':
        return 'It is recommended to create backups weekly to keep your data up to date.';
      case 'create_backup_title':
        return 'Create Backup';
      case 'create_backup_description':
        return 'Generate a backup file with all your MindSpace data.';
      case 'mood_data':
        return 'Mood';
      case 'all_entries':
        return 'All entries';
      case 'all_sessions':
        return 'All sessions';
      case 'settings_data':
        return 'Settings';
      case 'preferences_settings':
        return 'Preferences and settings';
      case 'creating_backup':
        return 'Creating backup...';
      case 'backup_created_successfully':
        return 'Backup created successfully';
      case 'backup_error':
        return 'Error creating backup';
      case 'restore_data_title':
        return 'Restore Data';
      case 'restore_data_description':
        return 'Restore your data from a previous backup file.';
      case 'restore_warning':
        return 'WARNING: This action will replace all your current data with the backup data.';
      case 'restoring':
        return 'Restoring...';
      case 'restore_from_file':
        return 'Restore from file';
      case 'confirm_restoration':
        return 'Confirm restoration';
      case 'confirm_restoration_message':
        return 'Are you sure you want to restore the data? This action will replace all your current data.';
      case 'restore':
        return 'Restore';
      case 'no_file_selected':
        return 'No file selected';
      case 'invalid_backup_file':
        return 'Invalid backup file';
      case 'backup_restored_successfully':
        return 'Data restored successfully';
      case 'restore_error':
        return 'Error restoring data';
      case 'delete_account_subtitle':
        return 'Permanently delete your account';
      case 'achievements_subtitle':
        return 'View your achievements and badges';
      case 'help_support_subtitle':
        return 'Get help and support';
      case 'privacy_policy_subtitle':
        return 'Read our privacy policy';
      case 'terms_of_service_subtitle':
        return 'Read our terms of service';
      case 'edit_profile':
        return 'Edit profile';
      case 'edit_profile_message':
        return 'This feature will be available soon';
      case 'help_message':
        return 'If you need help, you can contact us at support@mindspace.app';
      case 'privacy_message':
        return 'We respect your privacy. Your data is safe with us.';
      case 'spanish_default':
        return 'Default language';
      case 'english_default':
        return 'Default language';
      case 'french_default':
        return 'Langue par défaut';
      case 'german_default':
        return 'Standardsprache';
      case 'italian_default':
        return 'Lingua predefinita';
      case 'portuguese_default':
        return 'Idioma padrão';
      case 'selected_language':
        return 'Selected language';

      // Notification settings
      case 'notification_settings_title':
        return 'Notification Settings';
      case 'notification_settings_subtitle':
        return 'Customize when and how to receive notifications';
      case 'general_settings':
        return 'General Settings';
      case 'daily_notifications':
        return 'Daily notifications';
      case 'daily_notifications_desc':
        return 'Receive daily reminders to use the app';
      case 'weekly_reports_notifications':
        return 'Weekly reports';
      case 'weekly_reports_notifications_desc':
        return 'Receive a summary of your progress each week';
      case 'reminder_schedules':
        return 'Reminder Schedules';
      case 'daily_reminder_time':
        return 'Daily reminder time';
      case 'meditation_reminder':
        return 'Meditation reminder';
      case 'mood_reminder':
        return 'Mood reminder';
      case 'notification_types':
        return 'Notification Types';
      case 'meditation_reminders':
        return 'Meditation reminders';
      case 'meditation_reminders_desc':
        return 'We remind you when it\'s time to meditate';
      case 'mood_reminders':
        return 'Mood reminders';
      case 'mood_reminders_desc':
        return 'We remind you to log how you feel';
      case 'test_notifications':
        return 'Test Notifications';
      case 'test_notifications_desc':
        return 'Send a test notification to verify everything is working correctly.';
      case 'send_test_notification':
        return 'Send Test Notification';
      case 'test_notification_sent':
        return 'Test notification sent';
      case 'test_notification_error':
        return 'Error sending notification';

      // Theme preview
      case 'theme_preview':
        return 'Theme preview';
      case 'primary_color':
        return 'Primary';
      case 'secondary_color':
        return 'Secondary';
      case 'surface_color':
        return 'Surface';
      case 'sample_text':
        return 'Sample text';
      case 'sample_text_description':
        return 'This is sample text that shows how the current theme looks.';
      case 'sample_button':
        return 'Sample button';
      case 'mood_tab':
        return 'Mood';
      case 'meditation_tab':
        return 'Meditation';
      case 'journal_tab':
        return 'Journal';
      case 'mood_chart_title':
        return 'Mood Trend';
      case 'meditation_chart_title':
        return 'Meditation Sessions';
      case 'journal_chart_title':
        return 'Journal Entries';
      case 'no_data_chart':
        return 'Not enough data to show chart';
      case 'trends':
        return 'Trends';
      case 'best_day_week':
        return 'Best day of the week';
      case 'monday':
        return 'Monday';
      case 'preferred_time':
        return 'Preferred time';
      case 'morning':
        return 'Morning';
      case 'most_common_state':
        return 'Most common state';
      case 'good':
        return 'Good';
      case 'favorite_type':
        return 'Favorite type';
      case 'mindfulness':
        return 'Mindfulness';
      case 'average_duration':
        return 'Average duration';
      case 'best_moment':
        return 'Best moment';
      case 'favorite_category':
        return 'Favorite category';
      case 'reflection':
        return 'Reflection';
      case 'average_length':
        return 'Average length';
      case 'words_count':
        return '150 words';
      case 'most_active_day':
        return 'Most active day';
      case 'sunday':
        return 'Sunday';
      case 'all_achievements':
        return 'All';
      case 'mood_achievements':
        return 'Mood';
      case 'meditation_achievements':
        return 'Meditation';
      case 'journal_achievements':
        return 'Journal';
      case 'your_progress':
        return 'Your Progress';
      case 'level':
        return 'Level';
      case 'points':
        return 'Points';
      case 'locked':
        return 'Locked';
      case 'pts':
        return 'pts';
      case 'achievement_first_day':
        return 'First Day';
      case 'achievement_first_day_desc':
        return 'Log your first mood';
      case 'achievement_week':
        return 'One Week';
      case 'achievement_week_desc':
        return 'Log your mood for 7 consecutive days';
      case 'achievement_month':
        return 'One Month';
      case 'achievement_month_desc':
        return 'Log your mood for 30 consecutive days';
      case 'achievement_optimist':
        return 'Optimist';
      case 'achievement_optimist_desc':
        return 'Maintain a positive mood for 5 consecutive days';
      case 'achievement_first_meditation':
        return 'First Meditation';
      case 'achievement_first_meditation_desc':
        return 'Complete your first meditation session';
      case 'achievement_zen_week':
        return 'Zen Week';
      case 'achievement_zen_week_desc':
        return 'Meditate for 7 consecutive days';
      case 'achievement_hour_peace':
        return 'Hour of Peace';
      case 'achievement_hour_peace_desc':
        return 'Accumulate 60 minutes of meditation';
      case 'achievement_zen_master':
        return 'Zen Master';
      case 'achievement_zen_master_desc':
        return 'Complete 100 meditation sessions';
      case 'achievement_first_entry':
        return 'First Entry';
      case 'achievement_first_entry_desc':
        return 'Write your first journal entry';
      case 'achievement_consistent_writer':
        return 'Consistent Writer';
      case 'achievement_consistent_writer_desc':
        return 'Write in your journal for 7 consecutive days';
      case 'achievement_words_wisdom':
        return 'Words of Wisdom';
      case 'achievement_words_wisdom_desc':
        return 'Write 1000 words in total';
      case 'achievement_deep_reflection':
        return 'Deep Reflection';
      case 'achievement_deep_reflection_desc':
        return 'Write 50 reflection entries';
      case 'export_data_title':
        return 'Export Data';
      case 'export_info_title':
        return 'Export Information';
      case 'export_info_description':
        return 'You can export your data in JSON or CSV format. The data includes:';
      case 'export_mood_entries':
        return '• Mood entries';
      case 'export_meditation_sessions':
        return '• Meditation sessions';
      case 'export_journal_entries':
        return '• Personal journal entries';
      case 'export_settings_preferences':
        return '• Settings and preferences';
      case 'export_security_note':
        return 'Data is exported securely and only stored locally on your device.';
      case 'select_data_to_export':
        return 'Select data to export';
      case 'mood_data_title':
        return 'Mood';
      case 'mood_data_description':
        return 'Includes all your mood entries';
      case 'meditation_data_title':
        return 'Meditation';
      case 'meditation_data_description':
        return 'Includes all your meditation sessions';
      case 'journal_data_title':
        return 'Personal Journal';
      case 'journal_data_description':
        return 'Includes all your journal entries';
      case 'export_options_title':
        return 'Export Options';
      case 'json_format_title':
        return 'JSON Format';
      case 'json_format_description':
        return 'Structured format, ideal for importing into other applications';
      case 'csv_format_title':
        return 'CSV Format';
      case 'csv_format_description':
        return 'Spreadsheet format, ideal for data analysis';
      case 'exporting':
        return 'Exporting...';
      case 'export_data_button':
        return 'Export Data';
      case 'export_success':
        return 'Data exported successfully';
      case 'export_error':
        return 'Error exporting data';

      // Other common texts
      case 'statistics_title':
        return 'Statistics';
      case 'statistics_subtitle':
        return 'Your progress in detail';
      case 'about':
        return 'About';
      case 'version':
        return 'Version';
      case 'help_support':
        return 'Help & Support';
      case 'privacy_policy':
        return 'Privacy Policy';
      case 'terms_of_service':
        return 'Terms of Service';
      case 'about_message':
        return 'MindSpace is your personal companion for mental wellness. Track your mood, meditate, and journal to monitor your personal growth.';
      case 'terms_of_service_message':
        return 'By using MindSpace, you agree to our terms and conditions of service.';
      case 'delete_account':
        return 'Delete Account';
      case 'delete_account_confirm':
        return 'Delete Account';
      case 'delete_account_message':
        return 'This action will permanently delete all your data. This action cannot be undone.';

      default:
        return key;
    }
  }

  String _getFrenchText(String key) {
    switch (key) {
      // App basics
      case 'app_title':
        return 'MindSpace';
      case 'good_morning':
        return 'Bonjour';
      case 'good_afternoon':
        return 'Bon après-midi';
      case 'good_evening':
        return 'Bonsoir';
      case 'good_night':
        return 'Bonne nuit';
      case 'home':
        return 'Accueil';
      case 'meditation':
        return 'Méditation';
      case 'journal':
        return 'Journal';
      case 'mood':
        return 'Humeur';
      case 'profile':
        return 'Profil';
      case 'settings':
        return 'Paramètres';
      case 'language':
        return 'Langue';
      case 'theme':
        return 'Thème';
      case 'notifications':
        return 'Notifications';
      case 'backup':
        return 'Sauvegarde';
      case 'export':
        return 'Exporter';
      case 'achievements':
        return 'Réalisations';
      case 'search':
        return 'Rechercher';
      case 'statistics':
        return 'Statistiques';

      // Navigation
      case 'navigation_home':
        return 'Accueil';
      case 'navigation_meditation':
        return 'Méditation';
      case 'navigation_journal':
        return 'Journal';
      case 'navigation_mood':
        return 'Humeur';
      case 'navigation_profile':
        return 'Profil';

      // Common buttons
      case 'cancel':
        return 'Annuler';
      case 'save':
        return 'Sauvegarder';
      case 'delete':
        return 'Supprimer';
      case 'edit':
        return 'Modifier';
      case 'ok':
        return 'OK';
      case 'close':
        return 'Fermer';

      // Quick actions translations
      case 'mood_logged_today':
        return 'Humeur enregistrée';
      case 'mood_today':
        return 'Humeur';
      case 'mood_logged_message':
        return 'Parfait ! Vous avez enregistré votre humeur aujourd\'hui.';
      case 'mood_tap_to_log':
        return 'Appuyez pour enregistrer comment vous vous sentez';
      case 'how_do_you_feel':
        return 'Comment vous sentez-vous aujourd\'hui ?';
      case 'how_are_you_feeling':
        return 'Comment vous sentez-vous ?';
      case 'quick_actions':
        return 'Actions Rapides';
      case 'recent_activity':
        return 'Activité Récente';
      case 'mood_entry':
        return 'Entrée d\'Humeur';
      case 'last_entry':
        return 'Dernière entrée';
      case 'meditation_session':
        return 'Séance de Méditation';
      case 'last_session':
        return 'Dernière séance';
      case 'journal_entry':
        return 'Entrée de Journal';
      case 'last_journal':
        return 'Dernier journal';
      case 'no_recent_activity':
        return 'Aucune activité récente';
      case 'start_journey':
        return 'Commencez votre voyage de bien-être';
      case 'search_general_hint':
        return 'Rechercher dans l\'humeur, les méditations et le journal...';
      case 'meditation_subtitle':
        return 'Trouvez votre moment de paix';
      case 'meditation_types':
        return 'Types de Méditation';
      case 'content_hint_mood':
        return 'Comment vous sentez-vous en ce moment ?';
      case 'mood_excellent':
        return 'Excellent';
      case 'mood_good':
        return 'Bien';
      case 'mood_neutral':
        return 'Neutre';
      case 'mood_bad':
        return 'Mal';
      case 'mood_terrible':
        return 'Terrible';
      case 'mood_energy':
        return 'Énergie';
      case 'mood_stress':
        return 'Stress';
      case 'mood_happiness':
        return 'Bonheur';
      case 'mood_anxiety':
        return 'Anxiété';
      case 'mood_motivation':
        return 'Motivation';
      case 'mood_sleep':
        return 'Sommeil';
      case 'mood_social':
        return 'Social';
      case 'mood_work':
        return 'Travail';
      case 'mood_happy':
        return 'Heureux';
      case 'mood_sad':
        return 'Triste';
      case 'mood_excited':
        return 'Excité';
      case 'mood_anxious':
        return 'Anxieux';
      case 'mood_calm':
        return 'Calme';
      case 'mood_angry':
        return 'En colère';
      case 'mood_grateful':
        return 'Reconnaissant';
      case 'mood_confused':
        return 'Confus';
      case 'mood_hopeful':
        return 'Plein d\'espoir';
      case 'mood_nostalgic':
        return 'Nostalgique';
      case 'content_hint_journal':
        return 'Qu\'avez-vous appris sur vous-même aujourd\'hui ?';
      case 'prompt_how_do_you_feel':
        return 'Comment vous sentez-vous en ce moment ?';
      case 'prompt_best_thing_today':
        return 'Quelle a été la meilleure chose qui vous est arrivée aujourd\'hui ?';
      case 'prompt_challenge_today':
        return 'Quel défi avez-vous relevé aujourd\'hui ?';
      case 'prompt_grateful_today':
        return 'Pourquoi êtes-vous reconnaissant aujourd\'hui ?';
      case 'prompt_learned_about_self':
        return 'Qu\'avez-vous appris sur vous-même aujourd\'hui ?';
      case 'prompt_ideal_day':
        return 'Comment aimeriez-vous que soit votre journée idéale ?';
      case 'prompt_what_worries_you':
        return 'Qu\'est-ce qui vous préoccupe en ce moment ?';
      case 'prompt_what_makes_proud':
        return 'Qu\'est-ce qui vous rend fier ?';
      case 'prompt_dream_for_future':
        return 'Quel rêve avez-vous pour l\'avenir ?';
      case 'prompt_person_inspired_you':
        return 'Quelle personne vous a inspiré aujourd\'hui ?';
      case 'theme_light':
        return 'Clair';
      case 'theme_dark':
        return 'Sombre';
      case 'theme_system':
        return 'Système';
      case 'per_entry':
        return 'par entrée';
      case 'additional_details':
        return 'Détails supplémentaires';
      case 'mood_saved_message':
        return 'Humeur enregistrée';

      case 'meditation_done_today':
        return 'Médité aujourd\'hui';
      case 'meditation_quick':
        return 'Méditer';
      case 'meditation_done_message':
        return 'Excellent ! Vous avez médité aujourd\'hui.';
      case 'meditation_tap_to_start':
        return 'Appuyez pour commencer';
      case 'choose_meditation':
        return 'Choisissez votre méditation';
      case 'meditation_type':
        return 'Type de méditation';
      case 'duration':
        return 'Durée';
      case 'difficulty':
        return 'Difficulté';
      case 'start_meditation':
        return 'Commencer';
      case 'meditation_starting_message':
        return 'Démarrage de la méditation';

      case 'journal_written_today':
        return 'Écrit aujourd\'hui';
      case 'journal_write':
        return 'Écrire';
      case 'journal_written_message':
        return 'Parfait ! Vous avez écrit dans votre journal aujourd\'hui.';
      case 'journal_tap_to_write':
        return 'Appuyez pour écrire une entrée';
      case 'new_entry':
        return 'Nouvelle entrée';
      case 'category':
        return 'Catégorie';
      case 'title_optional':
        return 'Titre (optionnel)';
      case 'title_hint_journal':
        return 'Écrivez un titre pour votre entrée...';
      case 'content':
        return 'Contenu';
      case 'mood_optional':
        return 'Humeur (optionnel)';
      case 'entry_saved_message':
        return 'Entrée sauvegardée dans';

      // Progress section
      case 'progress_title':
        return 'Votre progression';
      case 'days_streak':
        return 'jours consécutifs';
      case 'mood_stat':
        return 'Humeur';
      case 'meditation_stat':
        return 'Méditation';
      case 'journal_stat':
        return 'Journal';

      // Meditation types
      case 'meditation_breathing':
        return 'Respiration';
      case 'meditation_mindfulness':
        return 'Pleine conscience';
      case 'meditation_body_scan':
        return 'Balayage corporel';
      case 'meditation_loving_kindness':
        return 'Bienveillance';
      case 'meditation_walking':
        return 'Marche consciente';
      case 'meditation_gratitude':
        return 'Gratitude';
      case 'meditation_sleep':
        return 'Pour dormir';
      case 'meditation_anxiety':
        return 'Anti-anxiété';

      // Meditation descriptions
      case 'meditation_breathing_desc':
        return 'Techniques de respiration consciente';
      case 'meditation_mindfulness_desc':
        return 'Pleine conscience du moment présent';
      case 'meditation_body_scan_desc':
        return 'Reconnaissance des sensations corporelles';
      case 'meditation_loving_kindness_desc':
        return 'Cultiver la compassion et l\'amour';
      case 'meditation_walking_desc':
        return 'Méditation en mouvement';
      case 'meditation_gratitude_desc':
        return 'Réflexion sur ce dont nous sommes reconnaissants';
      case 'meditation_sleep_desc':
        return 'Relaxation profonde pour le repos';
      case 'meditation_anxiety_desc':
        return 'Techniques pour calmer l\'anxiété';

      // Difficulty levels
      case 'difficulty_beginner':
        return 'Débutant';
      case 'difficulty_intermediate':
        return 'Intermédiaire';
      case 'difficulty_advanced':
        return 'Avancé';

      // Meditation session
      case 'meditation_completed':
        return 'Méditation terminée !';
      case 'meditation_minutes':
        return 'minutes';
      case 'recent_sessions_title':
        return 'Sessions récentes';
      case 'no_recent_sessions':
        return 'Aucune session récente';
      case 'start_first_meditation':
        return 'Commencez votre première méditation';
      case 'sessions':
        return 'Sessions';
      case 'completed':
        return 'terminées';
      case 'time':
        return 'Temps';
      case 'minutes':
        return 'min';
      case 'total':
        return 'total';
      case 'streak':
        return 'Série';
      case 'days':
        return 'jours';
      case 'continue':
        return 'Continuer';
      case 'pause':
        return 'Pause';
      case 'finish':
        return 'Terminer';
      case 'instructions':
        return 'Instructions';

      // Meditation instructions
      case 'breathing_instructions':
        return 'Concentrez-vous sur votre respiration. Inspirez lentement par le nez et expirez par la bouche. Ressentez comment l\'air entre et sort de votre corps.';
      case 'mindfulness_instructions':
        return 'Observez vos pensées sans les juger. Quand votre esprit vagabonde, ramenez doucement votre attention au moment présent.';
      case 'body_scan_instructions':
        return 'Portez votre attention sur chaque partie de votre corps, des orteils à la tête. Observez les sensations sans jugement.';
      case 'loving_kindness_instructions':
        return 'Envoyez des pensées d\'amour et de compassion à vous-même, puis à vos proches, et enfin à tous les êtres.';
      case 'gratitude_instructions':
        return 'Réfléchissez aux choses dont vous êtes reconnaissant. Permettez à la gratitude de remplir votre cœur.';
      case 'sleep_instructions':
        return 'Détendez chaque muscle de votre corps. Imaginez que vous êtes dans un endroit paisible et sûr. Laissez le calme vous envelopper.';
      case 'anxiety_instructions':
        return 'Respirez profondément et expirez lentement. Imaginez que l\'anxiété se dissout à chaque expiration.';
      case 'default_meditation_instructions':
        return 'Trouvez une position confortable et fermez les yeux. Respirez naturellement et permettez à votre esprit de se calmer.';

      // Journal translations
      case 'journal_subtitle':
        return 'Réfléchissez et écrivez sur votre journée';
      case 'search_hint':
        return 'Rechercher dans les entrées...';
      case 'all':
        return 'Toutes';
      case 'no_entries_found':
        return 'Aucune entrée trouvée';
      case 'journal_empty':
        return 'Votre journal est vide';
      case 'try_other_terms':
        return 'Essayez d\'autres termes de recherche';
      case 'start_writing':
        return 'Commencez à écrire votre première entrée';
      case 'write_entry_button':
        return 'Écrire une entrée';
      case 'edit_entry':
        return 'Modifier l\'entrée';
      case 'mood_tags':
        return 'Étiquettes d\'humeur';
      case 'private_entry':
        return 'Entrée privée';
      case 'content_required':
        return 'Le contenu est requis';
      case 'entry_updated':
        return 'Entrée mise à jour';
      case 'entry_saved':
        return 'Entrée sauvegardée';
      case 'information':
        return 'Informations';
      case 'word_count':
        return 'Mots';
      case 'reading_time':
        return 'Temps de lecture';
      case 'last_updated':
        return 'Dernière mise à jour';
      case 'words':
        return 'mots';
      case 'delete_entry_title':
        return 'Supprimer l\'entrée';
      case 'delete_entry_message':
        return 'Êtes-vous sûr de vouloir supprimer cette entrée ? Cette action ne peut pas être annulée.';
      case 'delete_entry':
        return 'Supprimer l\'entrée';
      case 'entry_default_title':
        return 'Entrée du';

      // Journal categories
      case 'category_daily':
        return 'Quotidien';
      case 'category_gratitude':
        return 'Gratitude';
      case 'category_reflection':
        return 'Réflexion';
      case 'category_goals':
        return 'Objectifs';
      case 'category_dreams':
        return 'Rêves';
      case 'category_challenges':
        return 'Défis';
      case 'category_memories':
        return 'Souvenirs';
      case 'category_ideas':
        return 'Idées';

      // Profile section
      case 'user_profile':
        return 'Profil utilisateur';
      case 'member_since':
        return 'Membre depuis';
      case 'profile_subtitle':
        return 'Gérez votre compte et vos paramètres';

      // Settings
      case 'app_settings':
        return 'Paramètres de l\'application';
      case 'data_privacy':
        return 'Données et confidentialité';
      case 'language_subtitle':
        return 'Sélectionnez votre langue préférée';
      case 'select_theme':
        return 'Sélectionner le thème';
      case 'select_theme_subtitle':
        return 'Choisissez l\'apparence que vous préférez';
      case 'light_theme':
        return 'Thème clair pour utilisation diurne';
      case 'dark_theme':
        return 'Thème sombre pour utilisation nocturne';
      case 'system_theme':
        return 'Suivre les paramètres du système';

      // Mood tracking
      case 'mood_subtitle':
        return 'Suivez votre bien-être émotionnel';
      case 'mood_trend_chart':
        return 'Graphique de tendance d\'humeur';
      case 'time_ranges':
        return 'Plages de temps';
      case 'days_7':
        return '7 jours';
      case 'days_30':
        return '30 jours';
      case 'days_90':
        return '90 jours';
      case 'insufficient_data':
        return 'Données insuffisantes';
      case 'register_mood_trends':
        return 'Enregistrez votre humeur pour voir les tendances';
      case 'recent_entries_title':
        return 'Entrées récentes';
      case 'no_recent_entries':
        return 'Aucune entrée récente';
      case 'start_tracking_mood':
        return 'Commencez à suivre votre humeur';
      case 'average':
        return 'Moyenne';
      case 'streak_days':
        return 'jours consécutifs';
      case 'records':
        return 'enregistrements';

      // Profile translations
      case 'registros':
        return 'enregistrements';
      case 'sesiones':
        return 'sessions';
      case 'entradas':
        return 'entrées';
      case 'notifications_subtitle':
        return 'Gérez vos notifications';
      case 'reminder_time':
        return 'Heure de rappel';
      case 'weekly_reports':
        return 'Rapports hebdomadaires';
      case 'weekly_reports_subtitle':
        return 'Recevez des résumés hebdomadaires de votre progression';
      case 'export_data':
        return 'Exporter les données';
      case 'export_data_subtitle':
        return 'Téléchargez vos données personnelles';
      case 'backup_restore':
        return 'Sauvegarde et restauration';
      case 'backup_restore_subtitle':
        return 'Sauvegardez et restaurez vos informations';
      case 'backup_info':
        return 'Gardez vos données sûres et accessibles';
      case 'why_backup':
        return 'Pourquoi sauvegarder ?';
      case 'backup_benefits':
        return 'Créer des sauvegardes régulières vous aide à :';
      case 'protect_data':
        return '• Protéger vos informations personnelles';
      case 'recover_data':
        return '• Récupérer les données en cas de perte';
      case 'maintain_history':
        return '• Maintenir votre historique complet';
      case 'transfer_data':
        return '• Transférer les données entre appareils';
      case 'backup_recommendation':
        return 'Il est recommandé de créer des sauvegardes hebdomadaires pour maintenir vos données à jour.';
      case 'create_backup_title':
        return 'Créer une sauvegarde';
      case 'create_backup_description':
        return 'Générer un fichier de sauvegarde avec toutes vos données MindSpace.';
      case 'mood_data':
        return 'Humeur';
      case 'all_entries':
        return 'Toutes les entrées';
      case 'all_sessions':
        return 'Toutes les sessions';
      case 'settings_data':
        return 'Paramètres';
      case 'preferences_settings':
        return 'Préférences et paramètres';
      case 'creating_backup':
        return 'Création de la sauvegarde...';
      case 'backup_created_successfully':
        return 'Sauvegarde créée avec succès';
      case 'backup_error':
        return 'Erreur lors de la création de la sauvegarde';
      case 'restore_data_title':
        return 'Restaurer les données';
      case 'restore_data_description':
        return 'Restaurer vos données à partir d\'un fichier de sauvegarde précédent.';
      case 'restore_warning':
        return 'ATTENTION : Cette action remplacera toutes vos données actuelles par les données de sauvegarde.';
      case 'restoring':
        return 'Restauration...';
      case 'restore_from_file':
        return 'Restaurer depuis un fichier';
      case 'confirm_restoration':
        return 'Confirmer la restauration';
      case 'confirm_restoration_message':
        return 'Êtes-vous sûr de vouloir restaurer les données ? Cette action remplacera toutes vos données actuelles.';
      case 'restore':
        return 'Restaurer';
      case 'no_file_selected':
        return 'Aucun fichier sélectionné';
      case 'invalid_backup_file':
        return 'Fichier de sauvegarde invalide';
      case 'backup_restored_successfully':
        return 'Données restaurées avec succès';
      case 'restore_error':
        return 'Erreur lors de la restauration des données';
      case 'delete_account':
        return 'Supprimer le compte';
      case 'delete_account_confirm':
        return 'Supprimer le compte';
      case 'delete_account_message':
        return 'Cette action supprimera définitivement toutes vos données. Cette action ne peut pas être annulée.';
      case 'delete_account_subtitle':
        return 'Supprimer définitivement votre compte';
      case 'achievements_subtitle':
        return 'Voir vos réalisations et badges';
      case 'help_support':
        return 'Aide et support';
      case 'help_support_subtitle':
        return 'Obtenez de l\'aide et du support';
      case 'privacy_policy':
        return 'Politique de confidentialité';
      case 'privacy_policy_subtitle':
        return 'Lisez notre politique de confidentialité';
      case 'terms_of_service':
        return 'Conditions d\'utilisation';
      case 'terms_of_service_subtitle':
        return 'Lisez nos conditions d\'utilisation';
      case 'about_message':
        return 'MindSpace est votre compagnon personnel pour le bien-être mental. Enregistrez votre humeur, méditez et écrivez dans votre journal pour suivre votre croissance personnelle.';
      case 'terms_of_service_message':
        return 'En utilisant MindSpace, vous acceptez nos termes et conditions de service.';
      case 'edit_profile':
        return 'Modifier le profil';
      case 'edit_profile_message':
        return 'Cette fonctionnalité sera bientôt disponible';
      case 'help_message':
        return 'Si vous avez besoin d\'aide, vous pouvez nous contacter à support@mindspace.app';
      case 'privacy_message':
        return 'Nous respectons votre vie privée. Vos données sont en sécurité avec nous.';
      case 'spanish_default':
        return 'Langue par défaut';
      case 'english_default':
        return 'Default language';
      case 'french_default':
        return 'Langue par défaut';
      case 'german_default':
        return 'Standardsprache';
      case 'italian_default':
        return 'Lingua predefinita';
      case 'portuguese_default':
        return 'Idioma padrão';
      case 'selected_language':
        return 'Langue sélectionnée';

      // Notification settings
      case 'notification_settings_title':
        return 'Paramètres de Notifications';
      case 'notification_settings_subtitle':
        return 'Personnalisez quand et comment recevoir des notifications';
      case 'general_settings':
        return 'Paramètres Généraux';
      case 'daily_notifications':
        return 'Notifications quotidiennes';
      case 'daily_notifications_desc':
        return 'Recevez des rappels quotidiens pour utiliser l\'app';
      case 'weekly_reports_notifications':
        return 'Rapports hebdomadaires';
      case 'weekly_reports_notifications_desc':
        return 'Recevez un résumé de votre progression chaque semaine';
      case 'reminder_schedules':
        return 'Horaires de Rappels';
      case 'daily_reminder_time':
        return 'Heure de rappel quotidien';
      case 'meditation_reminder':
        return 'Rappel de méditation';
      case 'mood_reminder':
        return 'Rappel d\'humeur';
      case 'notification_types':
        return 'Types de Notifications';
      case 'meditation_reminders':
        return 'Rappels de méditation';
      case 'meditation_reminders_desc':
        return 'Nous vous rappelons quand il est temps de méditer';
      case 'mood_reminders':
        return 'Rappels d\'humeur';
      case 'mood_reminders_desc':
        return 'Nous vous rappelons d\'enregistrer comment vous vous sentez';
      case 'test_notifications':
        return 'Tester les Notifications';
      case 'test_notifications_desc':
        return 'Envoyez une notification de test pour vérifier que tout fonctionne correctement.';
      case 'send_test_notification':
        return 'Envoyer Notification de Test';
      case 'test_notification_sent':
        return 'Notification de test envoyée';
      case 'test_notification_error':
        return 'Erreur lors de l\'envoi de la notification';

      // Theme preview
      case 'theme_preview':
        return 'Aperçu du thème';
      case 'primary_color':
        return 'Primaire';
      case 'secondary_color':
        return 'Secondaire';
      case 'surface_color':
        return 'Surface';
      case 'sample_text':
        return 'Texte d\'exemple';
      case 'sample_text_description':
        return 'Ceci est un texte d\'exemple qui montre à quoi ressemble le thème actuel.';
      case 'sample_button':
        return 'Bouton d\'exemple';
      case 'mood_tab':
        return 'Humeur';
      case 'meditation_tab':
        return 'Méditation';
      case 'journal_tab':
        return 'Journal';
      case 'mood_chart_title':
        return 'Tendance de l\'Humeur';
      case 'meditation_chart_title':
        return 'Séances de Méditation';
      case 'journal_chart_title':
        return 'Entrées du Journal';
      case 'no_data_chart':
        return 'Pas assez de données pour afficher le graphique';
      case 'trends':
        return 'Tendances';
      case 'best_day_week':
        return 'Meilleur jour de la semaine';
      case 'monday':
        return 'Lundi';
      case 'preferred_time':
        return 'Heure préférée';
      case 'morning':
        return 'Matin';
      case 'most_common_state':
        return 'État le plus courant';
      case 'good':
        return 'Bien';
      case 'favorite_type':
        return 'Type préféré';
      case 'mindfulness':
        return 'Pleine conscience';
      case 'average_duration':
        return 'Durée moyenne';
      case 'best_moment':
        return 'Meilleur moment';
      case 'favorite_category':
        return 'Catégorie préférée';
      case 'reflection':
        return 'Réflexion';
      case 'average_length':
        return 'Longueur moyenne';
      case 'words_count':
        return '150 mots';
      case 'most_active_day':
        return 'Jour le plus actif';
      case 'sunday':
        return 'Dimanche';
      case 'all_achievements':
        return 'Tous';
      case 'mood_achievements':
        return 'Humeur';
      case 'meditation_achievements':
        return 'Méditation';
      case 'journal_achievements':
        return 'Journal';
      case 'your_progress':
        return 'Votre Progrès';
      case 'level':
        return 'Niveau';
      case 'points':
        return 'Points';
      case 'locked':
        return 'Bloqué';
      case 'pts':
        return 'pts';
      case 'achievement_first_day':
        return 'Premier Jour';
      case 'achievement_first_day_desc':
        return 'Enregistrez votre première humeur';
      case 'achievement_week':
        return 'Une Semaine';
      case 'achievement_week_desc':
        return 'Enregistrez votre humeur pendant 7 jours consécutifs';
      case 'achievement_month':
        return 'Un Mois';
      case 'achievement_month_desc':
        return 'Enregistrez votre humeur pendant 30 jours consécutifs';
      case 'achievement_optimist':
        return 'Optimiste';
      case 'achievement_optimist_desc':
        return 'Maintenez une humeur positive pendant 5 jours consécutifs';
      case 'achievement_first_meditation':
        return 'Première Méditation';
      case 'achievement_first_meditation_desc':
        return 'Complétez votre première session de méditation';
      case 'achievement_zen_week':
        return 'Semaine Zen';
      case 'achievement_zen_week_desc':
        return 'Méditez pendant 7 jours consécutifs';
      case 'achievement_hour_peace':
        return 'Heure de Paix';
      case 'achievement_hour_peace_desc':
        return 'Accumulez 60 minutes de méditation';
      case 'achievement_zen_master':
        return 'Maître Zen';
      case 'achievement_zen_master_desc':
        return 'Complétez 100 sessions de méditation';
      case 'achievement_first_entry':
        return 'Première Entrée';
      case 'achievement_first_entry_desc':
        return 'Écrivez votre première entrée de journal';
      case 'achievement_consistent_writer':
        return 'Écrivain Constant';
      case 'achievement_consistent_writer_desc':
        return 'Écrivez dans votre journal pendant 7 jours consécutifs';
      case 'achievement_words_wisdom':
        return 'Mots de Sagesse';
      case 'achievement_words_wisdom_desc':
        return 'Écrivez 1000 mots au total';
      case 'achievement_deep_reflection':
        return 'Réflexion Profonde';
      case 'achievement_deep_reflection_desc':
        return 'Écrivez 50 entrées de réflexion';
      case 'export_data_title':
        return 'Exporter les Données';
      case 'export_info_title':
        return 'Informations sur l\'exportation';
      case 'export_info_description':
        return 'Vous pouvez exporter vos données au format JSON ou CSV. Les données incluent:';
      case 'export_mood_entries':
        return '• Entrées d\'humeur';
      case 'export_meditation_sessions':
        return '• Sessions de méditation';
      case 'export_journal_entries':
        return '• Entrées de journal personnel';
      case 'export_settings_preferences':
        return '• Paramètres et préférences';
      case 'export_security_note':
        return 'Les données sont exportées de manière sécurisée et stockées uniquement localement sur votre appareil.';
      case 'select_data_to_export':
        return 'Sélectionner les données à exporter';
      case 'mood_data_title':
        return 'Humeur';
      case 'mood_data_description':
        return 'Inclut toutes vos entrées d\'humeur';
      case 'meditation_data_title':
        return 'Méditation';
      case 'meditation_data_description':
        return 'Inclut toutes vos sessions de méditation';
      case 'journal_data_title':
        return 'Journal Personnel';
      case 'journal_data_description':
        return 'Inclut toutes vos entrées de journal';
      case 'export_options_title':
        return 'Options d\'Exportation';
      case 'json_format_title':
        return 'Format JSON';
      case 'json_format_description':
        return 'Format structuré, idéal pour importer dans d\'autres applications';
      case 'csv_format_title':
        return 'Format CSV';
      case 'csv_format_description':
        return 'Format de feuille de calcul, idéal pour l\'analyse de données';
      case 'exporting':
        return 'Exportation...';
      case 'export_data_button':
        return 'Exporter les Données';
      case 'export_success':
        return 'Données exportées avec succès';
      case 'export_error':
        return 'Erreur lors de l\'exportation des données';

      // Statistics
      case 'statistics_title':
        return 'Statistiques';
      case 'statistics_subtitle':
        return 'Votre progression en détail';

      default:
        return key;
    }
  }

  String _getGermanText(String key) {
    switch (key) {
      // App basics
      case 'app_title':
        return 'MindSpace';
      case 'good_morning':
        return 'Guten Morgen';
      case 'good_afternoon':
        return 'Guten Tag';
      case 'good_evening':
        return 'Guten Abend';
      case 'good_night':
        return 'Gute Nacht';
      case 'home':
        return 'Startseite';
      case 'meditation':
        return 'Meditation';
      case 'journal':
        return 'Tagebuch';
      case 'mood':
        return 'Stimmung';
      case 'profile':
        return 'Profil';
      case 'settings':
        return 'Einstellungen';
      case 'language':
        return 'Sprache';
      case 'theme':
        return 'Design';
      case 'notifications':
        return 'Benachrichtigungen';
      case 'backup':
        return 'Sicherung';
      case 'export':
        return 'Exportieren';
      case 'achievements':
        return 'Erfolge';
      case 'search':
        return 'Suchen';
      case 'statistics':
        return 'Statistiken';

      // Navigation
      case 'navigation_home':
        return 'Startseite';
      case 'navigation_meditation':
        return 'Meditation';
      case 'navigation_journal':
        return 'Tagebuch';
      case 'navigation_mood':
        return 'Stimmung';
      case 'navigation_profile':
        return 'Profil';

      // Common buttons
      case 'cancel':
        return 'Abbrechen';
      case 'save':
        return 'Speichern';
      case 'delete':
        return 'Löschen';
      case 'edit':
        return 'Bearbeiten';
      case 'ok':
        return 'OK';
      case 'close':
        return 'Schließen';

      // Quick actions translations
      case 'mood_logged_today':
        return 'Stimmung protokolliert';
      case 'mood_today':
        return 'Stimmung';
      case 'mood_logged_message':
        return 'Großartig! Sie haben heute Ihre Stimmung protokolliert.';
      case 'mood_tap_to_log':
        return 'Tippen Sie, um zu protokollieren, wie Sie sich fühlen';
      case 'how_do_you_feel':
        return 'Wie fühlen Sie sich heute?';
      case 'how_are_you_feeling':
        return 'Wie fühlen Sie sich?';
      case 'quick_actions':
        return 'Schnellaktionen';
      case 'recent_activity':
        return 'Letzte Aktivität';
      case 'mood_entry':
        return 'Stimmungseintrag';
      case 'last_entry':
        return 'Letzter Eintrag';
      case 'meditation_session':
        return 'Meditationssitzung';
      case 'last_session':
        return 'Letzte Sitzung';
      case 'journal_entry':
        return 'Tagebucheintrag';
      case 'last_journal':
        return 'Letztes Tagebuch';
      case 'no_recent_activity':
        return 'Keine letzte Aktivität';
      case 'start_journey':
        return 'Beginnen Sie Ihre Wellness-Reise';
      case 'search_general_hint':
        return 'Suchen Sie in Stimmung, Meditationen und Tagebuch...';
      case 'meditation_subtitle':
        return 'Finden Sie Ihren Moment der Ruhe';
      case 'meditation_types':
        return 'Meditationstypen';
      case 'content_hint_mood':
        return 'Wie fühlen Sie sich gerade?';
      case 'mood_excellent':
        return 'Ausgezeichnet';
      case 'mood_good':
        return 'Gut';
      case 'mood_neutral':
        return 'Neutral';
      case 'mood_bad':
        return 'Schlecht';
      case 'mood_terrible':
        return 'Schrecklich';
      case 'mood_energy':
        return 'Energie';
      case 'mood_stress':
        return 'Stress';
      case 'mood_happiness':
        return 'Glück';
      case 'mood_anxiety':
        return 'Angst';
      case 'mood_motivation':
        return 'Motivation';
      case 'mood_sleep':
        return 'Schlaf';
      case 'mood_social':
        return 'Sozial';
      case 'mood_work':
        return 'Arbeit';
      case 'mood_happy':
        return 'Glücklich';
      case 'mood_sad':
        return 'Traurig';
      case 'mood_excited':
        return 'Aufgeregt';
      case 'mood_anxious':
        return 'Ängstlich';
      case 'mood_calm':
        return 'Ruhig';
      case 'mood_angry':
        return 'Wütend';
      case 'mood_grateful':
        return 'Dankbar';
      case 'mood_confused':
        return 'Verwirrt';
      case 'mood_hopeful':
        return 'Hoffnungsvoll';
      case 'mood_nostalgic':
        return 'Nostalgisch';
      case 'content_hint_journal':
        return 'Was hast du heute über dich selbst gelernt?';
      case 'prompt_how_do_you_feel':
        return 'Wie fühlst du dich gerade?';
      case 'prompt_best_thing_today':
        return 'Was war das Beste, was dir heute passiert ist?';
      case 'prompt_challenge_today':
        return 'Welche Herausforderung hast du heute gemeistert?';
      case 'prompt_grateful_today':
        return 'Wofür bist du heute dankbar?';
      case 'prompt_learned_about_self':
        return 'Was hast du heute über dich selbst gelernt?';
      case 'prompt_ideal_day':
        return 'Wie würde dein idealer Tag aussehen?';
      case 'prompt_what_worries_you':
        return 'Was beschäftigt dich gerade?';
      case 'prompt_what_makes_proud':
        return 'Worauf bist du stolz?';
      case 'prompt_dream_for_future':
        return 'Welchen Traum hast du für die Zukunft?';
      case 'prompt_person_inspired_you':
        return 'Welche Person hat dich heute inspiriert?';
      case 'theme_light':
        return 'Hell';
      case 'theme_dark':
        return 'Dunkel';
      case 'theme_system':
        return 'System';
      case 'per_entry':
        return 'pro Eintrag';
      case 'additional_details':
        return 'Zusätzliche Details';
      case 'mood_saved_message':
        return 'Stimmung protokolliert';

      case 'meditation_done_today':
        return 'Heute meditiert';
      case 'meditation_quick':
        return 'Meditieren';
      case 'meditation_done_message':
        return 'Ausgezeichnet! Sie haben heute meditiert.';
      case 'meditation_tap_to_start':
        return 'Tippen Sie, um zu beginnen';
      case 'choose_meditation':
        return 'Wählen Sie Ihre Meditation';
      case 'meditation_type':
        return 'Meditationstyp';
      case 'duration':
        return 'Dauer';
      case 'difficulty':
        return 'Schwierigkeit';
      case 'start_meditation':
        return 'Starten';
      case 'meditation_starting_message':
        return 'Meditation wird gestartet';

      case 'journal_written_today':
        return 'Heute geschrieben';
      case 'journal_write':
        return 'Schreiben';
      case 'journal_written_message':
        return 'Großartig! Sie haben heute in Ihr Tagebuch geschrieben.';
      case 'journal_tap_to_write':
        return 'Tippen Sie, um einen Eintrag zu schreiben';
      case 'new_entry':
        return 'Neuer Eintrag';
      case 'category':
        return 'Kategorie';
      case 'title_optional':
        return 'Titel (optional)';
      case 'title_hint_journal':
        return 'Schreiben Sie einen Titel für Ihren Eintrag...';
      case 'content':
        return 'Inhalt';
      case 'mood_optional':
        return 'Stimmung (optional)';
      case 'entry_saved_message':
        return 'Eintrag gespeichert in';

      // Progress section
      case 'progress_title':
        return 'Ihr Fortschritt';
      case 'days_streak':
        return 'Tage in Folge';
      case 'mood_stat':
        return 'Stimmung';
      case 'meditation_stat':
        return 'Meditation';
      case 'journal_stat':
        return 'Tagebuch';

      // Meditation types
      case 'meditation_breathing':
        return 'Atmung';
      case 'meditation_mindfulness':
        return 'Achtsamkeit';
      case 'meditation_body_scan':
        return 'Körperscan';
      case 'meditation_loving_kindness':
        return 'Liebende Güte';
      case 'meditation_walking':
        return 'Gehmeditation';
      case 'meditation_gratitude':
        return 'Dankbarkeit';
      case 'meditation_sleep':
        return 'Zum Schlafen';
      case 'meditation_anxiety':
        return 'Anti-Angst';

      // Meditation descriptions
      case 'meditation_breathing_desc':
        return 'Bewusste Atemtechniken';
      case 'meditation_mindfulness_desc':
        return 'Achtsamkeit für den gegenwärtigen Moment';
      case 'meditation_body_scan_desc':
        return 'Erkennung von Körperempfindungen';
      case 'meditation_loving_kindness_desc':
        return 'Kultivierung von Mitgefühl und Liebe';
      case 'meditation_walking_desc':
        return 'Meditation in Bewegung';
      case 'meditation_gratitude_desc':
        return 'Reflexion über das, wofür wir dankbar sind';
      case 'meditation_sleep_desc':
        return 'Tiefe Entspannung für die Ruhe';
      case 'meditation_anxiety_desc':
        return 'Techniken zur Beruhigung von Angst';

      // Difficulty levels
      case 'difficulty_beginner':
        return 'Anfänger';
      case 'difficulty_intermediate':
        return 'Mittelstufe';
      case 'difficulty_advanced':
        return 'Fortgeschritten';

      // Meditation session
      case 'meditation_completed':
        return 'Meditation abgeschlossen!';
      case 'meditation_minutes':
        return 'Minuten';
      case 'recent_sessions_title':
        return 'Aktuelle Sitzungen';
      case 'no_recent_sessions':
        return 'Keine aktuellen Sitzungen';
      case 'start_first_meditation':
        return 'Beginnen Sie Ihre erste Meditation';
      case 'sessions':
        return 'Sitzungen';
      case 'completed':
        return 'abgeschlossen';
      case 'time':
        return 'Zeit';
      case 'minutes':
        return 'Min';
      case 'total':
        return 'gesamt';
      case 'streak':
        return 'Serie';
      case 'days':
        return 'Tage';
      case 'continue':
        return 'Fortsetzen';
      case 'pause':
        return 'Pause';
      case 'finish':
        return 'Beenden';
      case 'instructions':
        return 'Anweisungen';

      // Meditation instructions
      case 'breathing_instructions':
        return 'Konzentrieren Sie sich auf Ihre Atmung. Atmen Sie langsam durch die Nase ein und durch den Mund aus. Spüren Sie, wie die Luft in Ihren Körper ein- und ausströmt.';
      case 'mindfulness_instructions':
        return 'Beobachten Sie Ihre Gedanken ohne sie zu beurteilen. Wenn Ihr Geist wandert, kehren Sie sanft Ihre Aufmerksamkeit zum gegenwärtigen Moment zurück.';
      case 'body_scan_instructions':
        return 'Richten Sie Ihre Aufmerksamkeit auf jeden Teil Ihres Körpers, von den Zehen bis zum Kopf. Beobachten Sie Empfindungen ohne Urteil.';
      case 'loving_kindness_instructions':
        return 'Senden Sie Gedanken der Liebe und des Mitgefühls an sich selbst, dann an Ihre Liebsten und schließlich an alle Wesen.';
      case 'gratitude_instructions':
        return 'Denken Sie über die Dinge nach, für die Sie dankbar sind. Lassen Sie Dankbarkeit Ihr Herz erfüllen.';
      case 'sleep_instructions':
        return 'Entspannen Sie jeden Muskel in Ihrem Körper. Stellen Sie sich vor, Sie sind an einem friedlichen und sicheren Ort. Lassen Sie Ruhe Sie umhüllen.';
      case 'anxiety_instructions':
        return 'Atmen Sie tief ein und aus. Stellen Sie sich vor, dass sich die Angst mit jedem Ausatmen auflöst.';
      case 'default_meditation_instructions':
        return 'Finden Sie eine bequeme Position und schließen Sie die Augen. Atmen Sie natürlich und lassen Sie Ihren Geist zur Ruhe kommen.';

      // Journal translations
      case 'journal_subtitle':
        return 'Reflektieren und schreiben Sie über Ihren Tag';
      case 'search_hint':
        return 'Einträge durchsuchen...';
      case 'all':
        return 'Alle';
      case 'no_entries_found':
        return 'Keine Einträge gefunden';
      case 'journal_empty':
        return 'Ihr Tagebuch ist leer';
      case 'try_other_terms':
        return 'Versuchen Sie andere Suchbegriffe';
      case 'start_writing':
        return 'Beginnen Sie mit dem Schreiben Ihres ersten Eintrags';
      case 'write_entry_button':
        return 'Eintrag schreiben';
      case 'edit_entry':
        return 'Eintrag bearbeiten';
      case 'mood_tags':
        return 'Stimmungs-Tags';
      case 'private_entry':
        return 'Privater Eintrag';
      case 'content_required':
        return 'Inhalt ist erforderlich';
      case 'entry_updated':
        return 'Eintrag aktualisiert';
      case 'entry_saved':
        return 'Eintrag gespeichert';
      case 'information':
        return 'Informationen';
      case 'word_count':
        return 'Wörter';
      case 'reading_time':
        return 'Lesezeit';
      case 'last_updated':
        return 'Zuletzt aktualisiert';
      case 'words':
        return 'Wörter';
      case 'delete_entry_title':
        return 'Eintrag löschen';
      case 'delete_entry_message':
        return 'Sind Sie sicher, dass Sie diesen Eintrag löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';
      case 'delete_entry':
        return 'Eintrag löschen';
      case 'entry_default_title':
        return 'Eintrag vom';

      // Journal categories
      case 'category_daily':
        return 'Täglich';
      case 'category_gratitude':
        return 'Dankbarkeit';
      case 'category_reflection':
        return 'Reflexion';
      case 'category_goals':
        return 'Ziele';
      case 'category_dreams':
        return 'Träume';
      case 'category_challenges':
        return 'Herausforderungen';
      case 'category_memories':
        return 'Erinnerungen';
      case 'category_ideas':
        return 'Ideen';

      // Profile section
      case 'user_profile':
        return 'Benutzerprofil';
      case 'member_since':
        return 'Mitglied seit';
      case 'profile_subtitle':
        return 'Verwalten Sie Ihr Konto und Ihre Einstellungen';

      // Settings
      case 'app_settings':
        return 'App-Einstellungen';
      case 'data_privacy':
        return 'Daten und Datenschutz';
      case 'language_subtitle':
        return 'Wählen Sie Ihre bevorzugte Sprache';
      case 'select_theme':
        return 'Thema auswählen';
      case 'select_theme_subtitle':
        return 'Wählen Sie Ihr bevorzugtes Aussehen';
      case 'light_theme':
        return 'Helles Thema für Tagesnutzung';
      case 'dark_theme':
        return 'Dunkles Thema für Nachtnutzung';
      case 'system_theme':
        return 'Systemeinstellungen folgen';

      // Mood tracking
      case 'mood_subtitle':
        return 'Verfolgen Sie Ihr emotionales Wohlbefinden';
      case 'mood_trend_chart':
        return 'Stimmungstrend-Diagramm';
      case 'time_ranges':
        return 'Zeitbereiche';
      case 'days_7':
        return '7 Tage';
      case 'days_30':
        return '30 Tage';
      case 'days_90':
        return '90 Tage';
      case 'insufficient_data':
        return 'Unzureichende Daten';
      case 'register_mood_trends':
        return 'Protokollieren Sie Ihre Stimmung, um Trends zu sehen';
      case 'recent_entries_title':
        return 'Aktuelle Einträge';
      case 'no_recent_entries':
        return 'Keine aktuellen Einträge';
      case 'start_tracking_mood':
        return 'Beginnen Sie mit der Stimmungsverfolgung';
      case 'average':
        return 'Durchschnitt';
      case 'streak_days':
        return 'Tage in Folge';
      case 'records':
        return 'Aufzeichnungen';

      // Profile translations
      case 'registros':
        return 'Aufzeichnungen';
      case 'sesiones':
        return 'Sitzungen';
      case 'entradas':
        return 'Einträge';
      case 'notifications_subtitle':
        return 'Verwalten Sie Ihre Benachrichtigungen';
      case 'reminder_time':
        return 'Erinnerungszeit';
      case 'weekly_reports':
        return 'Wöchentliche Berichte';
      case 'weekly_reports_subtitle':
        return 'Erhalten Sie wöchentliche Zusammenfassungen Ihres Fortschritts';
      case 'export_data':
        return 'Daten exportieren';
      case 'export_data_subtitle':
        return 'Laden Sie Ihre persönlichen Daten herunter';
      case 'backup_restore':
        return 'Backup und Wiederherstellung';
      case 'backup_restore_subtitle':
        return 'Sichern und wiederherstellen Sie Ihre Informationen';
      case 'backup_info':
        return 'Halten Sie Ihre Daten sicher und zugänglich';
      case 'why_backup':
        return 'Warum sichern?';
      case 'backup_benefits':
        return 'Regelmäßige Backups helfen Ihnen dabei:';
      case 'protect_data':
        return '• Ihre persönlichen Informationen zu schützen';
      case 'recover_data':
        return '• Daten im Verlustfall wiederherzustellen';
      case 'maintain_history':
        return '• Ihre vollständige Historie zu erhalten';
      case 'transfer_data':
        return '• Daten zwischen Geräten zu übertragen';
      case 'backup_recommendation':
        return 'Es wird empfohlen, wöchentlich Backups zu erstellen, um Ihre Daten aktuell zu halten.';
      case 'create_backup_title':
        return 'Backup erstellen';
      case 'create_backup_description':
        return 'Generieren Sie eine Backup-Datei mit all Ihren MindSpace-Daten.';
      case 'mood_data':
        return 'Stimmung';
      case 'all_entries':
        return 'Alle Einträge';
      case 'all_sessions':
        return 'Alle Sitzungen';
      case 'settings_data':
        return 'Einstellungen';
      case 'preferences_settings':
        return 'Präferenzen und Einstellungen';
      case 'creating_backup':
        return 'Backup wird erstellt...';
      case 'backup_created_successfully':
        return 'Backup erfolgreich erstellt';
      case 'backup_error':
        return 'Fehler beim Erstellen des Backups';
      case 'restore_data_title':
        return 'Daten wiederherstellen';
      case 'restore_data_description':
        return 'Stellen Sie Ihre Daten aus einer vorherigen Backup-Datei wieder her.';
      case 'restore_warning':
        return 'WARNUNG: Diese Aktion ersetzt alle Ihre aktuellen Daten durch die Backup-Daten.';
      case 'restoring':
        return 'Wiederherstellen...';
      case 'restore_from_file':
        return 'Aus Datei wiederherstellen';
      case 'confirm_restoration':
        return 'Wiederherstellung bestätigen';
      case 'confirm_restoration_message':
        return 'Sind Sie sicher, dass Sie die Daten wiederherstellen möchten? Diese Aktion ersetzt alle Ihre aktuellen Daten.';
      case 'restore':
        return 'Wiederherstellen';
      case 'no_file_selected':
        return 'Keine Datei ausgewählt';
      case 'invalid_backup_file':
        return 'Ungültige Backup-Datei';
      case 'backup_restored_successfully':
        return 'Daten erfolgreich wiederhergestellt';
      case 'restore_error':
        return 'Fehler beim Wiederherstellen der Daten';
      case 'delete_account':
        return 'Konto löschen';
      case 'delete_account_confirm':
        return 'Konto löschen';
      case 'delete_account_message':
        return 'Diese Aktion wird alle Ihre Daten dauerhaft löschen. Diese Aktion kann nicht rückgängig gemacht werden.';
      case 'delete_account_subtitle':
        return 'Ihr Konto dauerhaft löschen';
      case 'achievements_subtitle':
        return 'Sehen Sie Ihre Erfolge und Abzeichen';
      case 'help_support':
        return 'Hilfe und Support';
      case 'help_support_subtitle':
        return 'Hilfe und Support erhalten';
      case 'privacy_policy':
        return 'Datenschutzrichtlinie';
      case 'privacy_policy_subtitle':
        return 'Lesen Sie unsere Datenschutzrichtlinie';
      case 'terms_of_service':
        return 'Nutzungsbedingungen';
      case 'terms_of_service_subtitle':
        return 'Lesen Sie unsere Nutzungsbedingungen';
      case 'about_message':
        return 'MindSpace ist Ihr persönlicher Begleiter für mentales Wohlbefinden. Verfolgen Sie Ihre Stimmung, meditieren Sie und führen Sie Tagebuch, um Ihr persönliches Wachstum zu überwachen.';
      case 'terms_of_service_message':
        return 'Durch die Nutzung von MindSpace stimmen Sie unseren Nutzungsbedingungen zu.';
      case 'edit_profile':
        return 'Profil bearbeiten';
      case 'edit_profile_message':
        return 'Diese Funktion wird bald verfügbar sein';
      case 'help_message':
        return 'Wenn Sie Hilfe benötigen, können Sie uns unter support@mindspace.app kontaktieren';
      case 'privacy_message':
        return 'Wir respektieren Ihre Privatsphäre. Ihre Daten sind bei uns sicher.';
      case 'spanish_default':
        return 'Standardsprache';
      case 'english_default':
        return 'Default language';
      case 'french_default':
        return 'Langue par défaut';
      case 'german_default':
        return 'Standardsprache';
      case 'italian_default':
        return 'Lingua predefinita';
      case 'portuguese_default':
        return 'Idioma padrão';
      case 'selected_language':
        return 'Ausgewählte Sprache';

      // Notification settings
      case 'notification_settings_title':
        return 'Benachrichtigungseinstellungen';
      case 'notification_settings_subtitle':
        return 'Passen Sie an, wann und wie Sie Benachrichtigungen erhalten';
      case 'general_settings':
        return 'Allgemeine Einstellungen';
      case 'daily_notifications':
        return 'Tägliche Benachrichtigungen';
      case 'daily_notifications_desc':
        return 'Erhalten Sie tägliche Erinnerungen zur App-Nutzung';
      case 'weekly_reports_notifications':
        return 'Wöchentliche Berichte';
      case 'weekly_reports_notifications_desc':
        return 'Erhalten Sie wöchentliche Zusammenfassungen Ihres Fortschritts';
      case 'reminder_schedules':
        return 'Erinnerungszeiten';
      case 'daily_reminder_time':
        return 'Tägliche Erinnerungszeit';
      case 'meditation_reminder':
        return 'Meditationserinnerung';
      case 'mood_reminder':
        return 'Stimmungserinnerung';
      case 'notification_types':
        return 'Benachrichtigungstypen';
      case 'meditation_reminders':
        return 'Meditationserinnerungen';
      case 'meditation_reminders_desc':
        return 'Wir erinnern Sie daran, wann es Zeit zum Meditieren ist';
      case 'mood_reminders':
        return 'Stimmungserinnerungen';
      case 'mood_reminders_desc':
        return 'Wir erinnern Sie daran, aufzuzeichnen, wie Sie sich fühlen';
      case 'test_notifications':
        return 'Benachrichtigungen testen';
      case 'test_notifications_desc':
        return 'Senden Sie eine Testbenachrichtigung, um zu überprüfen, ob alles korrekt funktioniert.';
      case 'send_test_notification':
        return 'Testbenachrichtigung senden';
      case 'test_notification_sent':
        return 'Testbenachrichtigung gesendet';
      case 'test_notification_error':
        return 'Fehler beim Senden der Benachrichtigung';

      // Theme preview
      case 'theme_preview':
        return 'Design-Vorschau';
      case 'primary_color':
        return 'Primär';
      case 'secondary_color':
        return 'Sekundär';
      case 'surface_color':
        return 'Oberfläche';
      case 'sample_text':
        return 'Beispieltext';
      case 'sample_text_description':
        return 'Dies ist ein Beispieltext, der zeigt, wie das aktuelle Design aussieht.';
      case 'sample_button':
        return 'Beispiel-Button';
      case 'mood_tab':
        return 'Stimmung';
      case 'meditation_tab':
        return 'Meditation';
      case 'journal_tab':
        return 'Tagebuch';
      case 'mood_chart_title':
        return 'Stimmungstrend';
      case 'meditation_chart_title':
        return 'Meditationssitzungen';
      case 'journal_chart_title':
        return 'Tagebucheinträge';
      case 'no_data_chart':
        return 'Nicht genügend Daten für die Anzeige des Diagramms';
      case 'trends':
        return 'Trends';
      case 'best_day_week':
        return 'Bester Tag der Woche';
      case 'monday':
        return 'Montag';
      case 'preferred_time':
        return 'Bevorzugte Zeit';
      case 'morning':
        return 'Morgen';
      case 'most_common_state':
        return 'Häufigster Zustand';
      case 'good':
        return 'Gut';
      case 'favorite_type':
        return 'Lieblingstyp';
      case 'mindfulness':
        return 'Achtsamkeit';
      case 'average_duration':
        return 'Durchschnittliche Dauer';
      case 'best_moment':
        return 'Bester Moment';
      case 'favorite_category':
        return 'Lieblingskategorie';
      case 'reflection':
        return 'Reflexion';
      case 'average_length':
        return 'Durchschnittliche Länge';
      case 'words_count':
        return '150 Wörter';
      case 'most_active_day':
        return 'Aktivster Tag';
      case 'sunday':
        return 'Sonntag';
      case 'all_achievements':
        return 'Alle';
      case 'mood_achievements':
        return 'Stimmung';
      case 'meditation_achievements':
        return 'Meditation';
      case 'journal_achievements':
        return 'Tagebuch';
      case 'your_progress':
        return 'Ihr Fortschritt';
      case 'level':
        return 'Level';
      case 'points':
        return 'Punkte';
      case 'locked':
        return 'Gesperrt';
      case 'pts':
        return 'Pkt';
      case 'achievement_first_day':
        return 'Erster Tag';
      case 'achievement_first_day_desc':
        return 'Protokollieren Sie Ihre erste Stimmung';
      case 'achievement_week':
        return 'Eine Woche';
      case 'achievement_week_desc':
        return 'Protokollieren Sie Ihre Stimmung 7 Tage hintereinander';
      case 'achievement_month':
        return 'Ein Monat';
      case 'achievement_month_desc':
        return 'Protokollieren Sie Ihre Stimmung 30 Tage hintereinander';
      case 'achievement_optimist':
        return 'Optimist';
      case 'achievement_optimist_desc':
        return 'Behalten Sie 5 Tage hintereinander eine positive Stimmung bei';
      case 'achievement_first_meditation':
        return 'Erste Meditation';
      case 'achievement_first_meditation_desc':
        return 'Vervollständigen Sie Ihre erste Meditationssitzung';
      case 'achievement_zen_week':
        return 'Zen-Woche';
      case 'achievement_zen_week_desc':
        return 'Meditieren Sie 7 Tage hintereinander';
      case 'achievement_hour_peace':
        return 'Stunde des Friedens';
      case 'achievement_hour_peace_desc':
        return 'Sammeln Sie 60 Minuten Meditation';
      case 'achievement_zen_master':
        return 'Zen-Meister';
      case 'achievement_zen_master_desc':
        return 'Vervollständigen Sie 100 Meditationssitzungen';
      case 'achievement_first_entry':
        return 'Erster Eintrag';
      case 'achievement_first_entry_desc':
        return 'Schreiben Sie Ihren ersten Tagebucheintrag';
      case 'achievement_consistent_writer':
        return 'Konsequenter Schreiber';
      case 'achievement_consistent_writer_desc':
        return 'Schreiben Sie 7 Tage hintereinander in Ihr Tagebuch';
      case 'achievement_words_wisdom':
        return 'Worte der Weisheit';
      case 'achievement_words_wisdom_desc':
        return 'Schreiben Sie insgesamt 1000 Wörter';
      case 'achievement_deep_reflection':
        return 'Tiefe Reflexion';
      case 'achievement_deep_reflection_desc':
        return 'Schreiben Sie 50 Reflexionseinträge';
      case 'export_data_title':
        return 'Daten Exportieren';
      case 'export_info_title':
        return 'Export-Informationen';
      case 'export_info_description':
        return 'Sie können Ihre Daten im JSON- oder CSV-Format exportieren. Die Daten umfassen:';
      case 'export_mood_entries':
        return '• Stimmungseinträge';
      case 'export_meditation_sessions':
        return '• Meditationssitzungen';
      case 'export_journal_entries':
        return '• Persönliche Tagebucheinträge';
      case 'export_settings_preferences':
        return '• Einstellungen und Präferenzen';
      case 'export_security_note':
        return 'Daten werden sicher exportiert und nur lokal auf Ihrem Gerät gespeichert.';
      case 'select_data_to_export':
        return 'Zu exportierende Daten auswählen';
      case 'mood_data_title':
        return 'Stimmung';
      case 'mood_data_description':
        return 'Enthält alle Ihre Stimmungseinträge';
      case 'meditation_data_title':
        return 'Meditation';
      case 'meditation_data_description':
        return 'Enthält alle Ihre Meditationssitzungen';
      case 'journal_data_title':
        return 'Persönliches Tagebuch';
      case 'journal_data_description':
        return 'Enthält alle Ihre Tagebucheinträge';
      case 'export_options_title':
        return 'Export-Optionen';
      case 'json_format_title':
        return 'JSON-Format';
      case 'json_format_description':
        return 'Strukturiertes Format, ideal zum Importieren in andere Anwendungen';
      case 'csv_format_title':
        return 'CSV-Format';
      case 'csv_format_description':
        return 'Tabellenkalkulationsformat, ideal für Datenanalyse';
      case 'exporting':
        return 'Exportiere...';
      case 'export_data_button':
        return 'Daten Exportieren';
      case 'export_success':
        return 'Daten erfolgreich exportiert';
      case 'export_error':
        return 'Fehler beim Exportieren der Daten';

      // Statistics
      case 'statistics_title':
        return 'Statistiken';
      case 'statistics_subtitle':
        return 'Ihr Fortschritt im Detail';

      default:
        return key;
    }
  }

  String _getItalianText(String key) {
    switch (key) {
      // App basics
      case 'app_title':
        return 'MindSpace';
      case 'good_morning':
        return 'Buongiorno';
      case 'good_afternoon':
        return 'Buon pomeriggio';
      case 'good_evening':
        return 'Buonasera';
      case 'good_night':
        return 'Buonanotte';
      case 'home':
        return 'Home';
      case 'meditation':
        return 'Meditazione';
      case 'journal':
        return 'Diario';
      case 'mood':
        return 'Umore';
      case 'profile':
        return 'Profilo';
      case 'settings':
        return 'Impostazioni';
      case 'language':
        return 'Lingua';
      case 'theme':
        return 'Tema';
      case 'notifications':
        return 'Notifiche';
      case 'backup':
        return 'Backup';
      case 'export':
        return 'Esporta';
      case 'achievements':
        return 'Risultati';
      case 'search':
        return 'Cerca';
      case 'statistics':
        return 'Statistiche';

      // Navigation
      case 'navigation_home':
        return 'Home';
      case 'navigation_meditation':
        return 'Meditazione';
      case 'navigation_journal':
        return 'Diario';
      case 'navigation_mood':
        return 'Umore';
      case 'navigation_profile':
        return 'Profilo';

      // Common buttons
      case 'cancel':
        return 'Annulla';
      case 'save':
        return 'Salva';
      case 'delete':
        return 'Elimina';
      case 'edit':
        return 'Modifica';
      case 'ok':
        return 'OK';
      case 'close':
        return 'Chiudi';

      // Quick actions translations
      case 'mood_logged_today':
        return 'Umore registrato';
      case 'mood_today':
        return 'Umore';
      case 'mood_logged_message':
        return 'Perfetto! Hai registrato il tuo umore oggi.';
      case 'mood_tap_to_log':
        return 'Tocca per registrare come ti senti';
      case 'how_do_you_feel':
        return 'Come ti senti oggi?';
      case 'how_are_you_feeling':
        return 'Come ti senti?';
      case 'quick_actions':
        return 'Azioni Rapide';
      case 'recent_activity':
        return 'Attività Recente';
      case 'mood_entry':
        return 'Entrata dell\'Umore';
      case 'last_entry':
        return 'Ultima entrata';
      case 'meditation_session':
        return 'Sessione di Meditazione';
      case 'last_session':
        return 'Ultima sessione';
      case 'journal_entry':
        return 'Entrata del Diario';
      case 'last_journal':
        return 'Ultimo diario';
      case 'no_recent_activity':
        return 'Nessuna attività recente';
      case 'start_journey':
        return 'Inizia il tuo viaggio di benessere';
      case 'search_general_hint':
        return 'Cerca in umore, meditazioni e diario...';
      case 'meditation_subtitle':
        return 'Trova il tuo momento di pace';
      case 'meditation_types':
        return 'Tipi di Meditazione';
      case 'content_hint_mood':
        return 'Come ti senti in questo momento?';
      case 'mood_excellent':
        return 'Eccellente';
      case 'mood_good':
        return 'Bene';
      case 'mood_neutral':
        return 'Neutrale';
      case 'mood_bad':
        return 'Male';
      case 'mood_terrible':
        return 'Terribile';
      case 'mood_energy':
        return 'Energia';
      case 'mood_stress':
        return 'Stress';
      case 'mood_happiness':
        return 'Felicità';
      case 'mood_anxiety':
        return 'Ansia';
      case 'mood_motivation':
        return 'Motivazione';
      case 'mood_sleep':
        return 'Sonno';
      case 'mood_social':
        return 'Sociale';
      case 'mood_work':
        return 'Lavoro';
      case 'mood_happy':
        return 'Felice';
      case 'mood_sad':
        return 'Triste';
      case 'mood_excited':
        return 'Eccitato';
      case 'mood_anxious':
        return 'Ansioso';
      case 'mood_calm':
        return 'Calmo';
      case 'mood_angry':
        return 'Arrabbiato';
      case 'mood_grateful':
        return 'Grato';
      case 'mood_confused':
        return 'Confuso';
      case 'mood_hopeful':
        return 'Speranzoso';
      case 'mood_nostalgic':
        return 'Nostalgico';
      case 'content_hint_journal':
        return 'Cosa hai imparato su te stesso oggi?';
      case 'prompt_how_do_you_feel':
        return 'Come ti senti in questo momento?';
      case 'prompt_best_thing_today':
        return 'Qual è stata la cosa migliore che ti è successa oggi?';
      case 'prompt_challenge_today':
        return 'Quale sfida hai affrontato oggi?';
      case 'prompt_grateful_today':
        return 'Per cosa sei grato oggi?';
      case 'prompt_learned_about_self':
        return 'Cosa hai imparato su te stesso oggi?';
      case 'prompt_ideal_day':
        return 'Come vorresti che fosse la tua giornata ideale?';
      case 'prompt_what_worries_you':
        return 'Cosa ti preoccupa in questo momento?';
      case 'prompt_what_makes_proud':
        return 'Cosa ti fa sentire orgoglioso?';
      case 'prompt_dream_for_future':
        return 'Che sogno hai per il futuro?';
      case 'prompt_person_inspired_you':
        return 'Quale persona ti ha ispirato oggi?';
      case 'theme_light':
        return 'Chiaro';
      case 'theme_dark':
        return 'Scuro';
      case 'theme_system':
        return 'Sistema';
      case 'per_entry':
        return 'per voce';
      case 'additional_details':
        return 'Dettagli aggiuntivi';
      case 'mood_saved_message':
        return 'Umore registrato';

      case 'meditation_done_today':
        return 'Meditato oggi';
      case 'meditation_quick':
        return 'Medita';
      case 'meditation_done_message':
        return 'Eccellente! Hai meditato oggi.';
      case 'meditation_tap_to_start':
        return 'Tocca per iniziare';
      case 'choose_meditation':
        return 'Scegli la tua meditazione';
      case 'meditation_type':
        return 'Tipo di meditazione';
      case 'duration':
        return 'Durata';
      case 'difficulty':
        return 'Difficoltà';
      case 'start_meditation':
        return 'Inizia';
      case 'meditation_starting_message':
        return 'Avvio meditazione';

      case 'journal_written_today':
        return 'Scritto oggi';
      case 'journal_write':
        return 'Scrivi';
      case 'journal_written_message':
        return 'Perfetto! Hai scritto nel tuo diario oggi.';
      case 'journal_tap_to_write':
        return 'Tocca per scrivere un\'entrata';
      case 'new_entry':
        return 'Nuova entrata';
      case 'category':
        return 'Categoria';
      case 'title_optional':
        return 'Titolo (opzionale)';
      case 'title_hint_journal':
        return 'Scrivi un titolo per la tua entrata...';
      case 'content':
        return 'Contenuto';
      case 'mood_optional':
        return 'Umore (opzionale)';
      case 'entry_saved_message':
        return 'Entrata salvata in';

      // Progress section
      case 'progress_title':
        return 'Il tuo progresso';
      case 'days_streak':
        return 'giorni consecutivi';
      case 'mood_stat':
        return 'Umore';
      case 'meditation_stat':
        return 'Meditazione';
      case 'journal_stat':
        return 'Diario';

      // Meditation types
      case 'meditation_breathing':
        return 'Respirazione';
      case 'meditation_mindfulness':
        return 'Mindfulness';
      case 'meditation_body_scan':
        return 'Scansione corporea';
      case 'meditation_loving_kindness':
        return 'Gentilezza amorevole';
      case 'meditation_walking':
        return 'Camminata consapevole';
      case 'meditation_gratitude':
        return 'Gratitudine';
      case 'meditation_sleep':
        return 'Per dormire';
      case 'meditation_anxiety':
        return 'Anti-ansia';

      // Meditation descriptions
      case 'meditation_breathing_desc':
        return 'Tecniche di respirazione consapevole';
      case 'meditation_mindfulness_desc':
        return 'Consapevolezza del momento presente';
      case 'meditation_body_scan_desc':
        return 'Riconoscimento delle sensazioni corporee';
      case 'meditation_loving_kindness_desc':
        return 'Coltivazione di compassione e amore';
      case 'meditation_walking_desc':
        return 'Meditazione in movimento';
      case 'meditation_gratitude_desc':
        return 'Riflessione su ciò di cui siamo grati';
      case 'meditation_sleep_desc':
        return 'Rilassamento profondo per il riposo';
      case 'meditation_anxiety_desc':
        return 'Tecniche per calmare l\'ansia';

      // Difficulty levels
      case 'difficulty_beginner':
        return 'Principiante';
      case 'difficulty_intermediate':
        return 'Intermedio';
      case 'difficulty_advanced':
        return 'Avanzato';

      // Meditation session
      case 'meditation_completed':
        return 'Meditazione completata!';
      case 'meditation_minutes':
        return 'minuti';
      case 'recent_sessions_title':
        return 'Sessioni recenti';
      case 'no_recent_sessions':
        return 'Nessuna sessione recente';
      case 'start_first_meditation':
        return 'Inizia la tua prima meditazione';
      case 'sessions':
        return 'Sessioni';
      case 'completed':
        return 'completate';
      case 'time':
        return 'Tempo';
      case 'minutes':
        return 'min';
      case 'total':
        return 'totale';
      case 'streak':
        return 'Serie';
      case 'days':
        return 'giorni';
      case 'continue':
        return 'Continua';
      case 'pause':
        return 'Pausa';
      case 'finish':
        return 'Termina';
      case 'instructions':
        return 'Istruzioni';

      // Meditation instructions
      case 'breathing_instructions':
        return 'Concentrati sulla tua respirazione. Inspira lentamente dal naso ed espira dalla bocca. Senti come l\'aria entra ed esce dal tuo corpo.';
      case 'mindfulness_instructions':
        return 'Osserva i tuoi pensieri senza giudicarli. Quando la tua mente vaga, riporta gentilmente la tua attenzione al momento presente.';
      case 'body_scan_instructions':
        return 'Porta la tua attenzione su ogni parte del tuo corpo, dalle dita dei piedi alla testa. Osserva le sensazioni senza giudizio.';
      case 'loving_kindness_instructions':
        return 'Invia pensieri di amore e compassione a te stesso, poi ai tuoi cari, e infine a tutti gli esseri.';
      case 'gratitude_instructions':
        return 'Rifletti sulle cose per cui sei grato. Permetti alla gratitudine di riempire il tuo cuore.';
      case 'sleep_instructions':
        return 'Rilassa ogni muscolo del tuo corpo. Immagina di essere in un luogo tranquillo e sicuro. Lascia che la calma ti avvolga.';
      case 'anxiety_instructions':
        return 'Respira profondamente ed espira lentamente. Immagina che l\'ansia si dissolva ad ogni espirazione.';
      case 'default_meditation_instructions':
        return 'Trova una posizione comoda e chiudi gli occhi. Respira naturalmente e permetti alla tua mente di calmarsi.';

      // Journal translations
      case 'journal_subtitle':
        return 'Rifletti e scrivi sulla tua giornata';
      case 'search_hint':
        return 'Cerca nelle entrate...';
      case 'all':
        return 'Tutte';
      case 'no_entries_found':
        return 'Nessuna entrata trovata';
      case 'journal_empty':
        return 'Il tuo diario è vuoto';
      case 'try_other_terms':
        return 'Prova altri termini di ricerca';
      case 'start_writing':
        return 'Inizia a scrivere la tua prima entrata';
      case 'write_entry_button':
        return 'Scrivi entrata';
      case 'edit_entry':
        return 'Modifica entrata';
      case 'mood_tags':
        return 'Tag dell\'umore';
      case 'private_entry':
        return 'Entrata privata';
      case 'content_required':
        return 'Il contenuto è richiesto';
      case 'entry_updated':
        return 'Entrata aggiornata';
      case 'entry_saved':
        return 'Entrata salvata';
      case 'information':
        return 'Informazioni';
      case 'word_count':
        return 'Parole';
      case 'reading_time':
        return 'Tempo di lettura';
      case 'last_updated':
        return 'Ultimo aggiornamento';
      case 'words':
        return 'parole';
      case 'delete_entry_title':
        return 'Elimina entrata';
      case 'delete_entry_message':
        return 'Sei sicuro di voler eliminare questa entrata? Questa azione non può essere annullata.';
      case 'delete_entry':
        return 'Elimina entrata';
      case 'entry_default_title':
        return 'Entrata del';

      // Journal categories
      case 'category_daily':
        return 'Quotidiano';
      case 'category_gratitude':
        return 'Gratitudine';
      case 'category_reflection':
        return 'Riflessione';
      case 'category_goals':
        return 'Obiettivi';
      case 'category_dreams':
        return 'Sogni';
      case 'category_challenges':
        return 'Sfide';
      case 'category_memories':
        return 'Ricordi';
      case 'category_ideas':
        return 'Idee';

      // Profile section
      case 'user_profile':
        return 'Profilo utente';
      case 'member_since':
        return 'Membro dal';
      case 'profile_subtitle':
        return 'Gestisci il tuo account e le impostazioni';

      // Settings
      case 'app_settings':
        return 'Impostazioni dell\'app';
      case 'data_privacy':
        return 'Dati e privacy';
      case 'language_subtitle':
        return 'Seleziona la tua lingua preferita';
      case 'select_theme':
        return 'Seleziona tema';
      case 'select_theme_subtitle':
        return 'Scegli l\'aspetto che preferisci';
      case 'light_theme':
        return 'Tema chiaro per uso diurno';
      case 'dark_theme':
        return 'Tema scuro per uso notturno';
      case 'system_theme':
        return 'Segui le impostazioni di sistema';

      // Mood tracking
      case 'mood_subtitle':
        return 'Segui il tuo benessere emotivo';
      case 'mood_trend_chart':
        return 'Grafico di tendenza dell\'umore';
      case 'time_ranges':
        return 'Intervalli di tempo';
      case 'days_7':
        return '7 giorni';
      case 'days_30':
        return '30 giorni';
      case 'days_90':
        return '90 giorni';
      case 'insufficient_data':
        return 'Dati insufficienti';
      case 'register_mood_trends':
        return 'Registra il tuo umore per vedere le tendenze';
      case 'recent_entries_title':
        return 'Entrate recenti';
      case 'no_recent_entries':
        return 'Nessuna entrata recente';
      case 'start_tracking_mood':
        return 'Inizia a tracciare il tuo umore';
      case 'average':
        return 'Media';
      case 'streak_days':
        return 'giorni consecutivi';
      case 'records':
        return 'registrazioni';

      // Profile translations
      case 'registros':
        return 'registrazioni';
      case 'sesiones':
        return 'sessioni';
      case 'entradas':
        return 'entrate';
      case 'notifications_subtitle':
        return 'Gestisci le tue notifiche';
      case 'reminder_time':
        return 'Ora del promemoria';
      case 'weekly_reports':
        return 'Rapporti settimanali';
      case 'weekly_reports_subtitle':
        return 'Ricevi riassunti settimanali del tuo progresso';
      case 'export_data':
        return 'Esporta dati';
      case 'export_data_subtitle':
        return 'Scarica i tuoi dati personali';
      case 'backup_restore':
        return 'Backup e ripristino';
      case 'backup_restore_subtitle':
        return 'Backup e ripristina le tue informazioni';
      case 'backup_info':
        return 'Mantieni i tuoi dati al sicuro e accessibili';
      case 'why_backup':
        return 'Perché fare backup?';
      case 'backup_benefits':
        return 'Creare backup regolari ti aiuta a:';
      case 'protect_data':
        return '• Proteggere le tue informazioni personali';
      case 'recover_data':
        return '• Recuperare i dati in caso di perdita';
      case 'maintain_history':
        return '• Mantenere la tua cronologia completa';
      case 'transfer_data':
        return '• Trasferire i dati tra dispositivi';
      case 'backup_recommendation':
        return 'Si raccomanda di creare backup settimanali per mantenere i tuoi dati aggiornati.';
      case 'create_backup_title':
        return 'Crea Backup';
      case 'create_backup_description':
        return 'Genera un file di backup con tutti i tuoi dati MindSpace.';
      case 'mood_data':
        return 'Umore';
      case 'all_entries':
        return 'Tutte le voci';
      case 'all_sessions':
        return 'Tutte le sessioni';
      case 'settings_data':
        return 'Impostazioni';
      case 'preferences_settings':
        return 'Preferenze e impostazioni';
      case 'creating_backup':
        return 'Creazione backup...';
      case 'backup_created_successfully':
        return 'Backup creato con successo';
      case 'backup_error':
        return 'Errore nella creazione del backup';
      case 'restore_data_title':
        return 'Ripristina Dati';
      case 'restore_data_description':
        return 'Ripristina i tuoi dati da un file di backup precedente.';
      case 'restore_warning':
        return 'ATTENZIONE: Questa azione sostituirà tutti i tuoi dati attuali con i dati del backup.';
      case 'restoring':
        return 'Ripristino...';
      case 'restore_from_file':
        return 'Ripristina da file';
      case 'confirm_restoration':
        return 'Conferma ripristino';
      case 'confirm_restoration_message':
        return 'Sei sicuro di voler ripristinare i dati? Questa azione sostituirà tutti i tuoi dati attuali.';
      case 'restore':
        return 'Ripristina';
      case 'no_file_selected':
        return 'Nessun file selezionato';
      case 'invalid_backup_file':
        return 'File di backup non valido';
      case 'backup_restored_successfully':
        return 'Dati ripristinati con successo';
      case 'restore_error':
        return 'Errore nel ripristino dei dati';
      case 'delete_account':
        return 'Elimina account';
      case 'delete_account_confirm':
        return 'Elimina account';
      case 'delete_account_message':
        return 'Questa azione eliminerà permanentemente tutti i tuoi dati. Questa azione non può essere annullata.';
      case 'delete_account_subtitle':
        return 'Elimina permanentemente il tuo account';
      case 'achievements_subtitle':
        return 'Visualizza i tuoi risultati e badge';
      case 'help_support':
        return 'Aiuto e supporto';
      case 'help_support_subtitle':
        return 'Ottieni aiuto e supporto';
      case 'privacy_policy':
        return 'Politica sulla privacy';
      case 'privacy_policy_subtitle':
        return 'Leggi la nostra politica sulla privacy';
      case 'terms_of_service':
        return 'Termini di servizio';
      case 'terms_of_service_subtitle':
        return 'Leggi i nostri termini di servizio';
      case 'about_message':
        return 'MindSpace è il tuo compagno personale per il benessere mentale. Traccia il tuo umore, medita e scrivi nel tuo diario per monitorare la tua crescita personale.';
      case 'terms_of_service_message':
        return 'Utilizzando MindSpace, accetti i nostri termini e condizioni di servizio.';
      case 'edit_profile':
        return 'Modifica profilo';
      case 'edit_profile_message':
        return 'Questa funzione sarà disponibile presto';
      case 'help_message':
        return 'Se hai bisogno di aiuto, puoi contattarci a support@mindspace.app';
      case 'privacy_message':
        return 'Rispettiamo la tua privacy. I tuoi dati sono al sicuro con noi.';
      case 'spanish_default':
        return 'Lingua predefinita';
      case 'english_default':
        return 'Default language';
      case 'french_default':
        return 'Langue par défaut';
      case 'german_default':
        return 'Standardsprache';
      case 'italian_default':
        return 'Lingua predefinita';
      case 'portuguese_default':
        return 'Idioma padrão';
      case 'selected_language':
        return 'Lingua selezionata';

      // Notification settings
      case 'notification_settings_title':
        return 'Impostazioni Notifiche';
      case 'notification_settings_subtitle':
        return 'Personalizza quando e come ricevere le notifiche';
      case 'general_settings':
        return 'Impostazioni Generali';
      case 'daily_notifications':
        return 'Notifiche giornaliere';
      case 'daily_notifications_desc':
        return 'Ricevi promemoria giornalieri per usare l\'app';
      case 'weekly_reports_notifications':
        return 'Rapporti settimanali';
      case 'weekly_reports_notifications_desc':
        return 'Ricevi un riassunto del tuo progresso ogni settimana';
      case 'reminder_schedules':
        return 'Orari dei Promemoria';
      case 'daily_reminder_time':
        return 'Ora del promemoria giornaliero';
      case 'meditation_reminder':
        return 'Promemoria meditazione';
      case 'mood_reminder':
        return 'Promemoria umore';
      case 'notification_types':
        return 'Tipi di Notifiche';
      case 'meditation_reminders':
        return 'Promemoria meditazione';
      case 'meditation_reminders_desc':
        return 'Ti ricordiamo quando è il momento di meditare';
      case 'mood_reminders':
        return 'Promemoria umore';
      case 'mood_reminders_desc':
        return 'Ti ricordiamo di registrare come ti senti';
      case 'test_notifications':
        return 'Prova Notifiche';
      case 'test_notifications_desc':
        return 'Invia una notifica di prova per verificare che tutto funzioni correttamente.';
      case 'send_test_notification':
        return 'Invia Notifica di Prova';
      case 'test_notification_sent':
        return 'Notifica di prova inviata';
      case 'test_notification_error':
        return 'Errore nell\'invio della notifica';

      // Theme preview
      case 'theme_preview':
        return 'Anteprima del tema';
      case 'primary_color':
        return 'Primario';
      case 'secondary_color':
        return 'Secondario';
      case 'surface_color':
        return 'Superficie';
      case 'sample_text':
        return 'Testo di esempio';
      case 'sample_text_description':
        return 'Questo è un testo di esempio che mostra come appare il tema attuale.';
      case 'sample_button':
        return 'Pulsante di esempio';
      case 'mood_tab':
        return 'Umore';
      case 'meditation_tab':
        return 'Meditazione';
      case 'journal_tab':
        return 'Diario';
      case 'mood_chart_title':
        return 'Tendenza dell\'Umore';
      case 'meditation_chart_title':
        return 'Sessioni di Meditazione';
      case 'journal_chart_title':
        return 'Voci del Diario';
      case 'no_data_chart':
        return 'Non ci sono abbastanza dati per mostrare il grafico';
      case 'trends':
        return 'Tendenze';
      case 'best_day_week':
        return 'Miglior giorno della settimana';
      case 'monday':
        return 'Lunedì';
      case 'preferred_time':
        return 'Ora preferita';
      case 'morning':
        return 'Mattina';
      case 'most_common_state':
        return 'Stato più comune';
      case 'good':
        return 'Bene';
      case 'favorite_type':
        return 'Tipo preferito';
      case 'mindfulness':
        return 'Consapevolezza';
      case 'average_duration':
        return 'Durata media';
      case 'best_moment':
        return 'Miglior momento';
      case 'favorite_category':
        return 'Categoria preferita';
      case 'reflection':
        return 'Riflessione';
      case 'average_length':
        return 'Lunghezza media';
      case 'words_count':
        return '150 parole';
      case 'most_active_day':
        return 'Giorno più attivo';
      case 'sunday':
        return 'Domenica';
      case 'all_achievements':
        return 'Tutti';
      case 'mood_achievements':
        return 'Umore';
      case 'meditation_achievements':
        return 'Meditazione';
      case 'journal_achievements':
        return 'Diario';
      case 'your_progress':
        return 'Il Tuo Progresso';
      case 'level':
        return 'Livello';
      case 'points':
        return 'Punti';
      case 'locked':
        return 'Bloccato';
      case 'pts':
        return 'pt';
      case 'achievement_first_day':
        return 'Primo Giorno';
      case 'achievement_first_day_desc':
        return 'Registra il tuo primo umore';
      case 'achievement_week':
        return 'Una Settimana';
      case 'achievement_week_desc':
        return 'Registra il tuo umore per 7 giorni consecutivi';
      case 'achievement_month':
        return 'Un Mese';
      case 'achievement_month_desc':
        return 'Registra il tuo umore per 30 giorni consecutivi';
      case 'achievement_optimist':
        return 'Ottimista';
      case 'achievement_optimist_desc':
        return 'Mantieni un umore positivo per 5 giorni consecutivi';
      case 'achievement_first_meditation':
        return 'Prima Meditazione';
      case 'achievement_first_meditation_desc':
        return 'Completa la tua prima sessione di meditazione';
      case 'achievement_zen_week':
        return 'Settimana Zen';
      case 'achievement_zen_week_desc':
        return 'Medita per 7 giorni consecutivi';
      case 'achievement_hour_peace':
        return 'Ora di Pace';
      case 'achievement_hour_peace_desc':
        return 'Accumula 60 minuti di meditazione';
      case 'achievement_zen_master':
        return 'Maestro Zen';
      case 'achievement_zen_master_desc':
        return 'Completa 100 sessioni di meditazione';
      case 'achievement_first_entry':
        return 'Prima Voce';
      case 'achievement_first_entry_desc':
        return 'Scrivi la tua prima voce nel diario';
      case 'achievement_consistent_writer':
        return 'Scrittore Costante';
      case 'achievement_consistent_writer_desc':
        return 'Scrivi nel diario per 7 giorni consecutivi';
      case 'achievement_words_wisdom':
        return 'Parole di Saggezza';
      case 'achievement_words_wisdom_desc':
        return 'Scrivi 1000 parole in totale';
      case 'achievement_deep_reflection':
        return 'Riflessione Profonda';
      case 'achievement_deep_reflection_desc':
        return 'Scrivi 50 voci di riflessione';
      case 'export_data_title':
        return 'Esporta Dati';
      case 'export_info_title':
        return 'Informazioni sull\'Esportazione';
      case 'export_info_description':
        return 'Puoi esportare i tuoi dati in formato JSON o CSV. I dati includono:';
      case 'export_mood_entries':
        return '• Voci di umore';
      case 'export_meditation_sessions':
        return '• Sessioni di meditazione';
      case 'export_journal_entries':
        return '• Voci di diario personale';
      case 'export_settings_preferences':
        return '• Impostazioni e preferenze';
      case 'export_security_note':
        return 'I dati vengono esportati in modo sicuro e memorizzati solo localmente sul tuo dispositivo.';
      case 'select_data_to_export':
        return 'Seleziona i dati da esportare';
      case 'mood_data_title':
        return 'Umore';
      case 'mood_data_description':
        return 'Include tutte le tue voci di umore';
      case 'meditation_data_title':
        return 'Meditazione';
      case 'meditation_data_description':
        return 'Include tutte le tue sessioni di meditazione';
      case 'journal_data_title':
        return 'Diario Personale';
      case 'journal_data_description':
        return 'Include tutte le tue voci di diario';
      case 'export_options_title':
        return 'Opzioni di Esportazione';
      case 'json_format_title':
        return 'Formato JSON';
      case 'json_format_description':
        return 'Formato strutturato, ideale per importare in altre applicazioni';
      case 'csv_format_title':
        return 'Formato CSV';
      case 'csv_format_description':
        return 'Formato foglio di calcolo, ideale per l\'analisi dei dati';
      case 'exporting':
        return 'Esportazione...';
      case 'export_data_button':
        return 'Esporta Dati';
      case 'export_success':
        return 'Dati esportati con successo';
      case 'export_error':
        return 'Errore durante l\'esportazione dei dati';

      // Statistics
      case 'statistics_title':
        return 'Statistiche';
      case 'statistics_subtitle':
        return 'Il tuo progresso in dettaglio';

      default:
        return key;
    }
  }

  String _getPortugueseText(String key) {
    switch (key) {
      // App basics
      case 'app_title':
        return 'MindSpace';
      case 'good_morning':
        return 'Bom dia';
      case 'good_afternoon':
        return 'Boa tarde';
      case 'good_evening':
        return 'Boa noite';
      case 'good_night':
        return 'Boa noite';
      case 'home':
        return 'Início';
      case 'meditation':
        return 'Meditação';
      case 'journal':
        return 'Diário';
      case 'mood':
        return 'Humor';
      case 'profile':
        return 'Perfil';
      case 'settings':
        return 'Configurações';
      case 'language':
        return 'Idioma';
      case 'theme':
        return 'Tema';
      case 'notifications':
        return 'Notificações';
      case 'backup':
        return 'Backup';
      case 'export':
        return 'Exportar';
      case 'achievements':
        return 'Conquistas';
      case 'search':
        return 'Pesquisar';
      case 'statistics':
        return 'Estatísticas';

      // Navigation
      case 'navigation_home':
        return 'Início';
      case 'navigation_meditation':
        return 'Meditação';
      case 'navigation_journal':
        return 'Diário';
      case 'navigation_mood':
        return 'Humor';
      case 'navigation_profile':
        return 'Perfil';

      // Common buttons
      case 'cancel':
        return 'Cancelar';
      case 'save':
        return 'Salvar';
      case 'delete':
        return 'Excluir';
      case 'edit':
        return 'Editar';
      case 'ok':
        return 'OK';
      case 'close':
        return 'Fechar';

      // Quick actions translations
      case 'mood_logged_today':
        return 'Humor registrado';
      case 'mood_today':
        return 'Humor';
      case 'mood_logged_message':
        return 'Ótimo! Você registrou seu humor hoje.';
      case 'mood_tap_to_log':
        return 'Toque para registrar como você se sente';
      case 'how_do_you_feel':
        return 'Como você se sente hoje?';
      case 'how_are_you_feeling':
        return 'Como você se sente?';
      case 'quick_actions':
        return 'Ações Rápidas';
      case 'recent_activity':
        return 'Atividade Recente';
      case 'mood_entry':
        return 'Entrada de Humor';
      case 'last_entry':
        return 'Última entrada';
      case 'meditation_session':
        return 'Sessão de Meditação';
      case 'last_session':
        return 'Última sessão';
      case 'journal_entry':
        return 'Entrada do Diário';
      case 'last_journal':
        return 'Último diário';
      case 'no_recent_activity':
        return 'Nenhuma atividade recente';
      case 'start_journey':
        return 'Comece sua jornada de bem-estar';
      case 'search_general_hint':
        return 'Pesquisar em humor, meditações e diário...';
      case 'meditation_subtitle':
        return 'Encontre seu momento de paz';
      case 'meditation_types':
        return 'Tipos de Meditação';
      case 'content_hint_mood':
        return 'Como você se sente neste momento?';
      case 'mood_excellent':
        return 'Excelente';
      case 'mood_good':
        return 'Bom';
      case 'mood_neutral':
        return 'Neutro';
      case 'mood_bad':
        return 'Ruim';
      case 'mood_terrible':
        return 'Terrível';
      case 'mood_energy':
        return 'Energia';
      case 'mood_stress':
        return 'Estresse';
      case 'mood_happiness':
        return 'Felicidade';
      case 'mood_anxiety':
        return 'Ansiedade';
      case 'mood_motivation':
        return 'Motivação';
      case 'mood_sleep':
        return 'Sono';
      case 'mood_social':
        return 'Social';
      case 'mood_work':
        return 'Trabalho';
      case 'mood_happy':
        return 'Feliz';
      case 'mood_sad':
        return 'Triste';
      case 'mood_excited':
        return 'Animado';
      case 'mood_anxious':
        return 'Ansioso';
      case 'mood_calm':
        return 'Calmo';
      case 'mood_angry':
        return 'Bravo';
      case 'mood_grateful':
        return 'Grato';
      case 'mood_confused':
        return 'Confuso';
      case 'mood_hopeful':
        return 'Esperançoso';
      case 'mood_nostalgic':
        return 'Nostálgico';
      case 'content_hint_journal':
        return 'O que você aprendeu sobre si mesmo hoje?';
      case 'prompt_how_do_you_feel':
        return 'Como você se sente neste momento?';
      case 'prompt_best_thing_today':
        return 'Qual foi a melhor coisa que aconteceu com você hoje?';
      case 'prompt_challenge_today':
        return 'Que desafio você enfrentou hoje?';
      case 'prompt_grateful_today':
        return 'Pelo que você está grato hoje?';
      case 'prompt_learned_about_self':
        return 'O que você aprendeu sobre si mesmo hoje?';
      case 'prompt_ideal_day':
        return 'Como você gostaria que fosse seu dia ideal?';
      case 'prompt_what_worries_you':
        return 'O que te preocupa neste momento?';
      case 'prompt_what_makes_proud':
        return 'O que te faz sentir orgulhoso?';
      case 'prompt_dream_for_future':
        return 'Que sonho você tem para o futuro?';
      case 'prompt_person_inspired_you':
        return 'Que pessoa te inspirou hoje?';
      case 'theme_light':
        return 'Claro';
      case 'theme_dark':
        return 'Escuro';
      case 'theme_system':
        return 'Sistema';
      case 'per_entry':
        return 'por entrada';
      case 'additional_details':
        return 'Detalhes adicionais';
      case 'mood_saved_message':
        return 'Humor registrado';

      case 'meditation_done_today':
        return 'Meditado hoje';
      case 'meditation_quick':
        return 'Meditar';
      case 'meditation_done_message':
        return 'Excelente! Você meditou hoje.';
      case 'meditation_tap_to_start':
        return 'Toque para começar';
      case 'choose_meditation':
        return 'Escolha sua meditação';
      case 'meditation_type':
        return 'Tipo de meditação';
      case 'duration':
        return 'Duração';
      case 'difficulty':
        return 'Dificuldade';
      case 'start_meditation':
        return 'Começar';
      case 'meditation_starting_message':
        return 'Iniciando meditação';

      case 'journal_written_today':
        return 'Escrito hoje';
      case 'journal_write':
        return 'Escrever';
      case 'journal_written_message':
        return 'Ótimo! Você escreveu em seu diário hoje.';
      case 'journal_tap_to_write':
        return 'Toque para escrever uma entrada';
      case 'new_entry':
        return 'Nova entrada';
      case 'category':
        return 'Categoria';
      case 'title_optional':
        return 'Título (opcional)';
      case 'title_hint_journal':
        return 'Escreva um título para sua entrada...';
      case 'content':
        return 'Conteúdo';
      case 'mood_optional':
        return 'Humor (opcional)';
      case 'entry_saved_message':
        return 'Entrada salva em';

      // Progress section
      case 'progress_title':
        return 'Seu progresso';
      case 'days_streak':
        return 'dias consecutivos';
      case 'mood_stat':
        return 'Humor';
      case 'meditation_stat':
        return 'Meditação';
      case 'journal_stat':
        return 'Diário';

      // Meditation types
      case 'meditation_breathing':
        return 'Respiração';
      case 'meditation_mindfulness':
        return 'Mindfulness';
      case 'meditation_body_scan':
        return 'Varredura corporal';
      case 'meditation_loving_kindness':
        return 'Bondade amorosa';
      case 'meditation_walking':
        return 'Caminhada consciente';
      case 'meditation_gratitude':
        return 'Gratidão';
      case 'meditation_sleep':
        return 'Para dormir';
      case 'meditation_anxiety':
        return 'Anti-ansiedade';

      // Meditation descriptions
      case 'meditation_breathing_desc':
        return 'Técnicas de respiração consciente';
      case 'meditation_mindfulness_desc':
        return 'Consciência do momento presente';
      case 'meditation_body_scan_desc':
        return 'Reconhecimento de sensações corporais';
      case 'meditation_loving_kindness_desc':
        return 'Cultivo de compaixão e amor';
      case 'meditation_walking_desc':
        return 'Meditação em movimento';
      case 'meditation_gratitude_desc':
        return 'Reflexão sobre o que somos gratos';
      case 'meditation_sleep_desc':
        return 'Relaxamento profundo para descanso';
      case 'meditation_anxiety_desc':
        return 'Técnicas para acalmar a ansiedade';

      // Difficulty levels
      case 'difficulty_beginner':
        return 'Iniciante';
      case 'difficulty_intermediate':
        return 'Intermediário';
      case 'difficulty_advanced':
        return 'Avançado';

      // Meditation session
      case 'meditation_completed':
        return 'Meditação concluída!';
      case 'meditation_minutes':
        return 'minutos';
      case 'recent_sessions_title':
        return 'Sessões recentes';
      case 'no_recent_sessions':
        return 'Nenhuma sessão recente';
      case 'start_first_meditation':
        return 'Comece sua primeira meditação';
      case 'sessions':
        return 'Sessões';
      case 'completed':
        return 'concluídas';
      case 'time':
        return 'Tempo';
      case 'minutes':
        return 'min';
      case 'total':
        return 'total';
      case 'streak':
        return 'Sequência';
      case 'days':
        return 'dias';
      case 'continue':
        return 'Continuar';
      case 'pause':
        return 'Pausar';
      case 'finish':
        return 'Finalizar';
      case 'instructions':
        return 'Instruções';

      // Meditation instructions
      case 'breathing_instructions':
        return 'Foque na sua respiração. Inspire lentamente pelo nariz e expire pela boca. Sinta como o ar entra e sai do seu corpo.';
      case 'mindfulness_instructions':
        return 'Observe seus pensamentos sem julgá-los. Quando sua mente divagar, gentilmente traga sua atenção de volta ao momento presente.';
      case 'body_scan_instructions':
        return 'Traga sua atenção para cada parte do seu corpo, dos dedos dos pés à cabeça. Observe as sensações sem julgamento.';
      case 'loving_kindness_instructions':
        return 'Envie pensamentos de amor e compaixão para si mesmo, depois para seus entes queridos, e finalmente para todos os seres.';
      case 'gratitude_instructions':
        return 'Reflita sobre as coisas pelas quais você é grato. Permita que a gratidão encha seu coração.';
      case 'sleep_instructions':
        return 'Relaxe cada músculo do seu corpo. Imagine que você está em um lugar tranquilo e seguro. Deixe a calma te envolver.';
      case 'anxiety_instructions':
        return 'Respire profundamente e expire devagar. Imagine a ansiedade se dissolvendo a cada expiração.';
      case 'default_meditation_instructions':
        return 'Encontre uma posição confortável e feche os olhos. Respire naturalmente e permita que sua mente se acalme.';

      // Journal translations
      case 'journal_subtitle':
        return 'Reflita e escreva sobre seu dia';
      case 'search_hint':
        return 'Pesquisar entradas...';
      case 'all':
        return 'Todas';
      case 'no_entries_found':
        return 'Nenhuma entrada encontrada';
      case 'journal_empty':
        return 'Seu diário está vazio';
      case 'try_other_terms':
        return 'Tente outros termos de pesquisa';
      case 'start_writing':
        return 'Comece a escrever sua primeira entrada';
      case 'write_entry_button':
        return 'Escrever entrada';
      case 'edit_entry':
        return 'Editar entrada';
      case 'mood_tags':
        return 'Tags de humor';
      case 'private_entry':
        return 'Entrada privada';
      case 'content_required':
        return 'Conteúdo é obrigatório';
      case 'entry_updated':
        return 'Entrada atualizada';
      case 'entry_saved':
        return 'Entrada salva';
      case 'information':
        return 'Informações';
      case 'word_count':
        return 'Palavras';
      case 'reading_time':
        return 'Tempo de leitura';
      case 'last_updated':
        return 'Última atualização';
      case 'words':
        return 'palavras';
      case 'delete_entry_title':
        return 'Excluir entrada';
      case 'delete_entry_message':
        return 'Tem certeza de que deseja excluir esta entrada? Esta ação não pode ser desfeita.';
      case 'delete_entry':
        return 'Excluir entrada';
      case 'entry_default_title':
        return 'Entrada de';

      // Journal categories
      case 'category_daily':
        return 'Diário';
      case 'category_gratitude':
        return 'Gratidão';
      case 'category_reflection':
        return 'Reflexão';
      case 'category_goals':
        return 'Metas';
      case 'category_dreams':
        return 'Sonhos';
      case 'category_challenges':
        return 'Desafios';
      case 'category_memories':
        return 'Memórias';
      case 'category_ideas':
        return 'Ideias';

      // Profile section
      case 'user_profile':
        return 'Perfil do usuário';
      case 'member_since':
        return 'Membro desde';
      case 'profile_subtitle':
        return 'Gerencie sua conta e configurações';

      // Settings
      case 'app_settings':
        return 'Configurações do app';
      case 'data_privacy':
        return 'Dados e privacidade';
      case 'language_subtitle':
        return 'Selecione seu idioma preferido';
      case 'select_theme':
        return 'Selecionar tema';
      case 'select_theme_subtitle':
        return 'Escolha a aparência que você prefere';
      case 'light_theme':
        return 'Tema claro para uso diurno';
      case 'dark_theme':
        return 'Tema escuro para uso noturno';
      case 'system_theme':
        return 'Seguir configurações do sistema';

      // Mood tracking
      case 'mood_subtitle':
        return 'Acompanhe seu bem-estar emocional';
      case 'mood_trend_chart':
        return 'Gráfico de tendência do humor';
      case 'time_ranges':
        return 'Intervalos de tempo';
      case 'days_7':
        return '7 dias';
      case 'days_30':
        return '30 dias';
      case 'days_90':
        return '90 dias';
      case 'insufficient_data':
        return 'Dados insuficientes';
      case 'register_mood_trends':
        return 'Registre seu humor para ver tendências';
      case 'recent_entries_title':
        return 'Entradas recentes';
      case 'no_recent_entries':
        return 'Nenhuma entrada recente';
      case 'start_tracking_mood':
        return 'Comece a rastrear seu humor';
      case 'average':
        return 'Média';
      case 'streak_days':
        return 'dias consecutivos';
      case 'records':
        return 'registros';

      // Profile translations
      case 'registros':
        return 'registros';
      case 'sesiones':
        return 'sessões';
      case 'entradas':
        return 'entradas';
      case 'notifications_subtitle':
        return 'Gerencie suas notificações';
      case 'reminder_time':
        return 'Hora do lembrete';
      case 'weekly_reports':
        return 'Relatórios semanais';
      case 'weekly_reports_subtitle':
        return 'Receba resumos semanais do seu progresso';
      case 'export_data':
        return 'Exportar dados';
      case 'export_data_subtitle':
        return 'Baixe seus dados pessoais';
      case 'backup_restore':
        return 'Backup e restauração';
      case 'backup_restore_subtitle':
        return 'Faça backup e restaure suas informações';
      case 'backup_info':
        return 'Mantenha seus dados seguros e acessíveis';
      case 'why_backup':
        return 'Por que fazer backup?';
      case 'backup_benefits':
        return 'Criar backups regulares te ajuda a:';
      case 'protect_data':
        return '• Proteger suas informações pessoais';
      case 'recover_data':
        return '• Recuperar dados em caso de perda';
      case 'maintain_history':
        return '• Manter seu histórico completo';
      case 'transfer_data':
        return '• Transferir dados entre dispositivos';
      case 'backup_recommendation':
        return 'Recomenda-se criar backups semanalmente para manter seus dados atualizados.';
      case 'create_backup_title':
        return 'Criar Backup';
      case 'create_backup_description':
        return 'Gere um arquivo de backup com todos os seus dados do MindSpace.';
      case 'mood_data':
        return 'Humor';
      case 'all_entries':
        return 'Todas as entradas';
      case 'all_sessions':
        return 'Todas as sessões';
      case 'settings_data':
        return 'Configurações';
      case 'preferences_settings':
        return 'Preferências e configurações';
      case 'creating_backup':
        return 'Criando backup...';
      case 'backup_created_successfully':
        return 'Backup criado com sucesso';
      case 'backup_error':
        return 'Erro ao criar backup';
      case 'restore_data_title':
        return 'Restaurar Dados';
      case 'restore_data_description':
        return 'Restaure seus dados de um arquivo de backup anterior.';
      case 'restore_warning':
        return 'AVISO: Esta ação substituirá todos os seus dados atuais pelos dados do backup.';
      case 'restoring':
        return 'Restaurando...';
      case 'restore_from_file':
        return 'Restaurar do arquivo';
      case 'confirm_restoration':
        return 'Confirmar restauração';
      case 'confirm_restoration_message':
        return 'Tem certeza de que deseja restaurar os dados? Esta ação substituirá todos os seus dados atuais.';
      case 'restore':
        return 'Restaurar';
      case 'no_file_selected':
        return 'Nenhum arquivo selecionado';
      case 'invalid_backup_file':
        return 'Arquivo de backup inválido';
      case 'backup_restored_successfully':
        return 'Dados restaurados com sucesso';
      case 'restore_error':
        return 'Erro ao restaurar dados';
      case 'delete_account':
        return 'Excluir conta';
      case 'delete_account_confirm':
        return 'Excluir conta';
      case 'delete_account_message':
        return 'Esta ação excluirá permanentemente todos os seus dados. Esta ação não pode ser desfeita.';
      case 'delete_account_subtitle':
        return 'Excluir permanentemente sua conta';
      case 'achievements_subtitle':
        return 'Veja suas conquistas e medalhas';
      case 'help_support':
        return 'Ajuda e suporte';
      case 'help_support_subtitle':
        return 'Obtenha ajuda e suporte';
      case 'privacy_policy':
        return 'Política de privacidade';
      case 'privacy_policy_subtitle':
        return 'Leia nossa política de privacidade';
      case 'terms_of_service':
        return 'Termos de serviço';
      case 'terms_of_service_subtitle':
        return 'Leia nossos termos de serviço';
      case 'about_message':
        return 'MindSpace é seu companheiro pessoal para o bem-estar mental. Registre seu humor, medite e escreva em seu diário para acompanhar seu crescimento pessoal.';
      case 'terms_of_service_message':
        return 'Ao usar o MindSpace, você concorda com nossos termos e condições de serviço.';
      case 'edit_profile':
        return 'Editar perfil';
      case 'edit_profile_message':
        return 'Esta funcionalidade estará disponível em breve';
      case 'help_message':
        return 'Se precisar de ajuda, você pode nos contatar em support@mindspace.app';
      case 'privacy_message':
        return 'Respeitamos sua privacidade. Seus dados estão seguros conosco.';
      case 'spanish_default':
        return 'Idioma padrão';
      case 'english_default':
        return 'Default language';
      case 'french_default':
        return 'Langue par défaut';
      case 'german_default':
        return 'Standardsprache';
      case 'italian_default':
        return 'Lingua predefinita';
      case 'portuguese_default':
        return 'Idioma padrão';
      case 'selected_language':
        return 'Idioma selecionado';

      // Notification settings
      case 'notification_settings_title':
        return 'Configurações de Notificações';
      case 'notification_settings_subtitle':
        return 'Personalize quando e como receber notificações';
      case 'general_settings':
        return 'Configurações Gerais';
      case 'daily_notifications':
        return 'Notificações diárias';
      case 'daily_notifications_desc':
        return 'Receba lembretes diários para usar o app';
      case 'weekly_reports_notifications':
        return 'Relatórios semanais';
      case 'weekly_reports_notifications_desc':
        return 'Receba um resumo do seu progresso a cada semana';
      case 'reminder_schedules':
        return 'Horários de Lembretes';
      case 'daily_reminder_time':
        return 'Hora do lembrete diário';
      case 'meditation_reminder':
        return 'Lembrete de meditação';
      case 'mood_reminder':
        return 'Lembrete de humor';
      case 'notification_types':
        return 'Tipos de Notificações';
      case 'meditation_reminders':
        return 'Lembretes de meditação';
      case 'meditation_reminders_desc':
        return 'Lembramos você quando é hora de meditar';
      case 'mood_reminders':
        return 'Lembretes de humor';
      case 'mood_reminders_desc':
        return 'Lembramos você de registrar como se sente';
      case 'test_notifications':
        return 'Testar Notificações';
      case 'test_notifications_desc':
        return 'Envie uma notificação de teste para verificar se tudo está funcionando corretamente.';
      case 'send_test_notification':
        return 'Enviar Notificação de Teste';
      case 'test_notification_sent':
        return 'Notificação de teste enviada';
      case 'test_notification_error':
        return 'Erro ao enviar notificação';

      // Theme preview
      case 'theme_preview':
        return 'Visualização do tema';
      case 'primary_color':
        return 'Primário';
      case 'secondary_color':
        return 'Secundário';
      case 'surface_color':
        return 'Superfície';
      case 'sample_text':
        return 'Texto de exemplo';
      case 'sample_text_description':
        return 'Este é um texto de exemplo que mostra como o tema atual se parece.';
      case 'sample_button':
        return 'Botão de exemplo';
      case 'mood_tab':
        return 'Humor';
      case 'meditation_tab':
        return 'Meditação';
      case 'journal_tab':
        return 'Diário';
      case 'mood_chart_title':
        return 'Tendência do Humor';
      case 'meditation_chart_title':
        return 'Sessões de Meditação';
      case 'journal_chart_title':
        return 'Entradas do Diário';
      case 'no_data_chart':
        return 'Dados insuficientes para mostrar o gráfico';
      case 'trends':
        return 'Tendências';
      case 'best_day_week':
        return 'Melhor dia da semana';
      case 'monday':
        return 'Segunda-feira';
      case 'preferred_time':
        return 'Hora preferida';
      case 'morning':
        return 'Manhã';
      case 'most_common_state':
        return 'Estado mais comum';
      case 'good':
        return 'Bom';
      case 'favorite_type':
        return 'Tipo favorito';
      case 'mindfulness':
        return 'Atenção plena';
      case 'average_duration':
        return 'Duração média';
      case 'best_moment':
        return 'Melhor momento';
      case 'favorite_category':
        return 'Categoria favorita';
      case 'reflection':
        return 'Reflexão';
      case 'average_length':
        return 'Comprimento médio';
      case 'words_count':
        return '150 palavras';
      case 'most_active_day':
        return 'Dia mais ativo';
      case 'sunday':
        return 'Domingo';
      case 'all_achievements':
        return 'Todos';
      case 'mood_achievements':
        return 'Humor';
      case 'meditation_achievements':
        return 'Meditação';
      case 'journal_achievements':
        return 'Diário';
      case 'your_progress':
        return 'Seu Progresso';
      case 'level':
        return 'Nível';
      case 'points':
        return 'Pontos';
      case 'locked':
        return 'Bloqueado';
      case 'pts':
        return 'pts';
      case 'achievement_first_day':
        return 'Primeiro Dia';
      case 'achievement_first_day_desc':
        return 'Registre seu primeiro humor';
      case 'achievement_week':
        return 'Uma Semana';
      case 'achievement_week_desc':
        return 'Registre seu humor por 7 dias consecutivos';
      case 'achievement_month':
        return 'Um Mês';
      case 'achievement_month_desc':
        return 'Registre seu humor por 30 dias consecutivos';
      case 'achievement_optimist':
        return 'Otimista';
      case 'achievement_optimist_desc':
        return 'Mantenha um humor positivo por 5 dias consecutivos';
      case 'achievement_first_meditation':
        return 'Primeira Meditação';
      case 'achievement_first_meditation_desc':
        return 'Complete sua primeira sessão de meditação';
      case 'achievement_zen_week':
        return 'Semana Zen';
      case 'achievement_zen_week_desc':
        return 'Medite por 7 dias consecutivos';
      case 'achievement_hour_peace':
        return 'Hora de Paz';
      case 'achievement_hour_peace_desc':
        return 'Acumule 60 minutos de meditação';
      case 'achievement_zen_master':
        return 'Mestre Zen';
      case 'achievement_zen_master_desc':
        return 'Complete 100 sessões de meditação';
      case 'achievement_first_entry':
        return 'Primeira Entrada';
      case 'achievement_first_entry_desc':
        return 'Escreva sua primeira entrada no diário';
      case 'achievement_consistent_writer':
        return 'Escritor Consistente';
      case 'achievement_consistent_writer_desc':
        return 'Escreva no diário por 7 dias consecutivos';
      case 'achievement_words_wisdom':
        return 'Palavras de Sabedoria';
      case 'achievement_words_wisdom_desc':
        return 'Escreva 1000 palavras no total';
      case 'achievement_deep_reflection':
        return 'Reflexão Profunda';
      case 'achievement_deep_reflection_desc':
        return 'Escreva 50 entradas de reflexão';
      case 'export_data_title':
        return 'Exportar Dados';
      case 'export_info_title':
        return 'Informações sobre Exportação';
      case 'export_info_description':
        return 'Você pode exportar seus dados em formato JSON ou CSV. Os dados incluem:';
      case 'export_mood_entries':
        return '• Entradas de humor';
      case 'export_meditation_sessions':
        return '• Sessões de meditação';
      case 'export_journal_entries':
        return '• Entradas de diário pessoal';
      case 'export_settings_preferences':
        return '• Configurações e preferências';
      case 'export_security_note':
        return 'Os dados são exportados com segurança e armazenados apenas localmente no seu dispositivo.';
      case 'select_data_to_export':
        return 'Selecionar dados para exportar';
      case 'mood_data_title':
        return 'Humor';
      case 'mood_data_description':
        return 'Inclui todas as suas entradas de humor';
      case 'meditation_data_title':
        return 'Meditação';
      case 'meditation_data_description':
        return 'Inclui todas as suas sessões de meditação';
      case 'journal_data_title':
        return 'Diário Pessoal';
      case 'journal_data_description':
        return 'Inclui todas as suas entradas de diário';
      case 'export_options_title':
        return 'Opções de Exportação';
      case 'json_format_title':
        return 'Formato JSON';
      case 'json_format_description':
        return 'Formato estruturado, ideal para importar em outras aplicações';
      case 'csv_format_title':
        return 'Formato CSV';
      case 'csv_format_description':
        return 'Formato de planilha, ideal para análise de dados';
      case 'exporting':
        return 'Exportando...';
      case 'export_data_button':
        return 'Exportar Dados';
      case 'export_success':
        return 'Dados exportados com sucesso';
      case 'export_error':
        return 'Erro ao exportar dados';

      // Statistics
      case 'statistics_title':
        return 'Estatísticas';
      case 'statistics_subtitle':
        return 'Seu progresso em detalhes';

      default:
        return key;
    }
  }
}
