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
      case 'insights':
        return 'Insights';
      case 'wellness_metrics':
        return 'Métricas de Bienestar';
      case 'advanced_prediction':
        return 'Predicción Avanzada';
      case 'prediction_updated':
        return 'Predicción actualizada';
      case 'refresh_prediction':
        return 'Actualizar predicción';
      case 'analyzing_patterns':
        return 'Analizando tus patrones...';
      case 'not_enough_data':
        return 'No hay suficientes datos';
      case 'use_app_for_better_predictions':
        return 'Usa la app más frecuentemente para obtener predicciones precisas';
      case 'log_mood':
        return 'Registrar Estado de Ánimo';
      case 'trend':
        return 'Tendencia';
      case 'confidence':
        return 'Confianza';
      case 'recommendation':
        return 'Recomendación';
      case 'identified_factors':
        return 'Factores identificados';
      case 'next_week_prediction':
        return 'Predicción próxima semana';
      case 'expected_mood':
        return 'Estado de ánimo esperado';
      case 'view_detailed_analysis':
        return 'Ver Análisis Detallado';
      case 'rec_consider_meditating_more':
        return 'Considera meditar más frecuentemente.';
      case 'rec_consider_journaling':
        return 'Escribir sobre tus sentimientos puede ser muy útil.';
      case 'rec_start_meditation_practice_title':
        return 'Comienza tu práctica de meditación';
      case 'rec_start_meditation_practice_description':
        return 'La meditación puede ayudarte a alcanzar tu objetivo de {goal}';
      case 'action_meditate_now':
        return 'Meditar ahora';
      case 'benefit_reduce_stress':
        return 'Reduce el estrés';
      case 'benefit_improve_focus':
        return 'Mejora la concentración';
      case 'benefit_increase_self_awareness':
        return 'Aumenta la autoconciencia';
      case 'rec_maintain_meditation_practice_title':
        return 'Mantén tu práctica de meditación';
      case 'rec_maintain_meditation_practice_description':
        return 'Has meditado {count} veces. ¡Sigue así para ver mejores resultados!';
      case 'action_continue_practice':
        return 'Continuar práctica';
      case 'benefit_build_habit':
        return 'Consolida el hábito';
      case 'benefit_improve_consistency':
        return 'Mejora la consistencia';
      case 'benefit_increase_benefits':
        return 'Aumenta los beneficios';
      case 'rec_low_mood_title':
        return 'Técnicas para mejorar tu estado de ánimo';
      case 'rec_low_mood_description':
        return 'Notamos que te has sentido un poco bajo. Aquí tienes algunas técnicas que pueden ayudar.';
      case 'action_view_techniques':
        return 'Ver técnicas';
      case 'benefit_mood_improvement':
        return 'Mejora el estado de ánimo';
      case 'benefit_reduce_anxiety':
        return 'Reduce la ansiedad';
      case 'benefit_increase_energy':
        return 'Aumenta la energía';
      case 'morning_label':
        return 'Mañana';
      case 'afternoon_label':
        return 'Tarde';
      case 'evening_label':
        return 'Noche';
      case 'optimal_time_title':
        return 'Horario óptimo para tu bienestar';
      case 'optimal_time_message':
        return 'Basado en tus datos, el mejor momento para tus actividades de bienestar es {time}';
      case 'action_configure_reminder':
        return 'Configurar recordatorio';
      case 'benefit_more_effective':
        return 'Mayor efectividad';
      case 'benefit_better_adherence':
        return 'Mejor adherencia';
      case 'benefit_more_consistent_results':
        return 'Resultados más consistentes';
      case 'goal_reduce_stress_title':
        return 'Meditación para reducir el estrés';
      case 'goal_reduce_stress_description':
        return 'Prueba esta meditación específicamente diseñada para reducir el estrés';
      case 'action_start_meditation':
        return 'Comenzar meditación';
      case 'benefit_reduce_cortisol':
        return 'Reduce cortisol';
      case 'benefit_improve_relaxation':
        return 'Mejora la relajación';
      case 'benefit_increase_mental_clarity':
        return 'Aumenta la claridad mental';
      case 'goal_improve_mood_title':
        return 'Actividades para mejorar el estado de ánimo';
      case 'goal_improve_mood_description':
        return 'Una combinación de técnicas que han demostrado mejorar el estado de ánimo';
      case 'action_view_activities':
        return 'Ver actividades';
      case 'benefit_increase_serotonin':
        return 'Aumenta la serotonina';
      case 'benefit_improve_self_esteem':
        return 'Mejora la autoestima';
      case 'goal_sleep_better_title':
        return 'Meditación para el sueño';
      case 'goal_sleep_better_description':
        return 'Técnicas de relajación específicas para mejorar la calidad del sueño';
      case 'action_prepare_sleep':
        return 'Preparar para dormir';
      case 'benefit_improve_sleep_quality':
        return 'Mejora la calidad del sueño';
      case 'benefit_reduce_insomnia':
        return 'Reduce el insomnio';
      case 'benefit_increase_relaxation':
        return 'Aumenta la relajación';
      case 'goal_custom_plan_title':
        return 'Plan personalizado para tu objetivo';
      case 'goal_custom_plan_description':
        return 'Hemos creado un plan específico para ayudarte a alcanzar: {goal}';
      case 'action_view_plan':
        return 'Ver plan';
      case 'time_variable':
        return 'Variable';
      case 'interest_meditation_title':
        return 'Nueva técnica de meditación';
      case 'interest_meditation_description':
        return 'Explora esta nueva técnica que puede enriquecer tu práctica';
      case 'action_learn_technique':
        return 'Aprender técnica';
      case 'benefit_diversify_practice':
        return 'Diversifica tu práctica';
      case 'benefit_increase_motivation':
        return 'Aumenta la motivación';
      case 'benefit_improve_results':
        return 'Mejora los resultados';
      case 'interest_breathing_title':
        return 'Ejercicio de respiración avanzado';
      case 'interest_breathing_description':
        return 'Técnica de respiración que puedes practicar en cualquier momento';
      case 'action_practice_now':
        return 'Practicar ahora';
      case 'benefit_immediate_stress_reduction':
        return 'Reduce el estrés inmediatamente';
      case 'benefit_regulate_nervous_system':
        return 'Regula el sistema nervioso';
      case 'interest_gratitude_title':
        return 'Diario de gratitud';
      case 'interest_gratitude_description':
        return 'Escribe sobre las cosas por las que te sientes agradecido hoy';
      case 'action_write_gratitude':
        return 'Escribir gratitud';
      case 'interest_explore_title':
        return 'Explora más sobre {interest}';
      case 'interest_explore_description':
        return 'Descubre nuevas formas de profundizar en {interest}';
      case 'action_explore':
        return 'Explorar';
      case 'benefit_continuous_learning':
        return 'Aprendizaje continuo';
      case 'benefit_motivation':
        return 'Motivación';
      case 'benefit_personal_growth':
        return 'Crecimiento personal';
      case 'rec_need_more_data':
        return 'Necesitas más datos para hacer predicciones precisas';
      case 'rec_mood_improving':
        return 'Tu estado de ánimo está mejorando. ¡Sigue con las actividades que te hacen sentir bien!';
      case 'rec_mood_declining':
        return 'Notamos una tendencia a la baja. Te sugerimos probar técnicas de relajación o hablar con alguien de confianza.';
      case 'rec_mood_stable':
        return 'Tu estado de ánimo se mantiene estable. Es un buen momento para explorar nuevas actividades de bienestar.';
      case 'factor_positive_trend':
        return 'Tendencia positiva en los últimos días';
      case 'factor_negative_trend':
        return 'Tendencia negativa en los últimos días';
      case 'factor_stable_mood':
        return 'Estado de ánimo estable';
      case 'factor_meditation_helps':
        return 'La meditación mejora tu estado de ánimo';
      case 'factor_journaling_helps':
        return 'Escribir en tu diario te ayuda a procesar emociones';
      case 'factor_december_better':
        return 'Tienes tendencia a sentirte mejor en diciembre';
      case 'factor_january_better':
        return 'Tienes tendencia a sentirte mejor en enero';
      case 'average_1_5':
        return 'Promedio (1-5)';
      case 'consistency':
        return 'Consistencia';
      case 'this_week':
        return 'Esta semana';
      case 'entries_this_week':
        return 'Entradas esta semana';
      case 'score_excellent':
        return 'Excelente';
      case 'score_good':
        return 'Bueno';
      case 'score_fair':
        return 'Regular';
      case 'score_needs_improvement':
        return 'Necesita mejorar';
      case 'wellness_score':
        return 'Puntuación de Bienestar';
      case 'based_on_activity':
        return 'Basado en tu actividad reciente';
      case 'no_insights_yet':
        return 'Aún no hay insights';
      case 'start_using_app':
        return 'Comienza a usar la app para obtener insights personalizados';
      case 'refresh':
        return 'Actualizar';
      case 'insight_great_mood_title':
        return '¡Excelente estado de ánimo!';
      case 'insight_great_mood_description':
        return 'Tu estado de ánimo promedio esta semana ha sido muy bueno. ¡Sigue así!';
      case 'view_statistics':
        return 'Ver estadísticas';
      case 'insight_feeling_low_title':
        return '¿Te sientes un poco bajo?';
      case 'insight_feeling_low_description':
        return 'Tu estado de ánimo ha estado un poco bajo esta semana. ¿Te gustaría probar una meditación relajante?';
      case 'insight_mood_streak_title':
        return '¡Racha de 7 días!';
      case 'insight_mood_streak_description':
        return 'Has registrado tu estado de ánimo durante 7 días seguidos. ¡Increíble consistencia!';
      case 'view_streak':
        return 'Ver racha';
      case 'view_progress':
        return 'Ver progreso';
      case 'insight_ready_to_meditate_title':
        return '¿Listo para meditar?';
      case 'insight_ready_to_meditate_description':
        return 'Hace un tiempo que no meditas. ¿Te gustaría retomar tu práctica?';
      case 'insight_journal_reminder_description':
        return 'Hace {days} días que no escribes en tu diario. ¿Te gustaría reflexionar sobre tu día?';
      case 'write_now':
        return 'Escribir ahora';
      case 'insight_goal_reminder_title':
        return 'Recordatorio de tu objetivo';
      case 'insight_goal_reminder_description':
        return 'Tu objetivo es: {goal}. ¿Cómo vas progresando?';
      case 'insight_welcome_title':
        return '¡Bienvenido a MindSpace!';
      case 'insight_welcome_description':
        return 'Comienza tu viaje hacia el bienestar registrando tu primer estado de ánimo.';
      case 'start':
        return 'Comenzar';

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
      case 'skip':
        return 'Omitir';

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
      case 'rate_session':
        return 'Califica la sesión';
      case 'notes_optional':
        return 'Notas (opcional)';
      case 'notes_hint':
        return 'Escribe observaciones o cómo te sentiste...';
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
      case 'preferences':
        return 'Preferencias';
      case 'haptics':
        return 'Vibración';
      case 'sound':
        return 'Sonido';

      // Breathing phases and body scan (ES)
      case 'inhale':
        return 'Inhala';
      case 'hold':
        return 'Retén';
      case 'exhale':
        return 'Exhala';
      case 'focus_on':
        return 'Enfoca en';
      case 'head':
        return 'Cabeza';
      case 'neck':
        return 'Cuello';
      case 'shoulders':
        return 'Hombros';
      case 'arms':
        return 'Brazos';
      case 'torso':
        return 'Torso';
      case 'legs':
        return 'Piernas';
      case 'feet':
        return 'Pies';
      case 'prompt_observe_breath':
        return 'Observa tu respiración';
      case 'prompt_listen_sounds':
        return 'Escucha los sonidos';
      case 'prompt_feel_body':
        return 'Siente tu cuerpo';
      case 'prompt_notice_thoughts':
        return 'Nota tus pensamientos y déjalos pasar';

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
      case 'smart_analysis':
        return 'Análisis Inteligente';
      case 'quick_summary':
        return 'Resumen Rápido';
      case 'analysis_updated':
        return 'Análisis actualizado';
      case 'refresh_analytics':
        return 'Actualizar análisis';
      case 'analyzing_data':
        return 'Analizando tus datos...';
      case 'correlations':
        return 'Correlaciones';
      case 'patterns':
        return 'Patrones';
      case 'progress':
        return 'Progreso';
      case 'wellness':
        return 'Bienestar';
      case 'identified_correlations':
        return 'Correlaciones Identificadas';
      case 'view_complete_analysis':
        return 'Ver Análisis Completo';
      case 'temporal_patterns':
        return 'Patrones Temporales';
      case 'best_days':
        return 'Mejores Días';
      case 'best_hours':
        return 'Mejores Horas';
      case 'seasonal_patterns':
        return 'Patrones Estacionales';
      case 'progress_analysis':
        return 'Análisis de Progreso';
      case 'overall_progress':
        return 'Progreso General';
      case 'recent_achievements':
        return 'Logros Recientes';
      case 'wellness_analysis':
        return 'Análisis de Bienestar';
      case 'risk_factors':
        return 'Factores de Riesgo';
      case 'protective_factors':
        return 'Factores Protectores';
      case 'detailed_analysis':
        return 'Análisis Detallado';
      case 'found_correlations':
        return 'Correlaciones Encontradas';
      case 'not_enough_data_detailed':
        return 'No hay datos suficientes para mostrar análisis detallado.';
      case 'usage':
        return 'Uso';
      case 'schedule':
        return 'Horario';
      // Insights de correlación
      case 'insight_meditation_positive':
        return 'La meditación tiene un impacto positivo en tu estado de ánimo';
      case 'insight_journal_emotions':
        return 'Escribir en tu diario te ayuda a procesar emociones';
      case 'insight_app_usage_wellness':
        return 'El uso frecuente de la app mejora tu bienestar general';
      case 'insight_specific_schedules':
        return 'Tienes horarios específicos donde te sientes mejor';
      // Patrones estacionales
      case 'feel_better_in':
        return 'Te sientes mejor en';
      // Logros
      case 'achievement_mood_improvement':
        return 'Mejora en estado de ánimo';
      case 'achievement_meditation_consistency':
        return 'Mayor consistencia en meditación';
      case 'achievement_journal_activity':
        return 'Más actividad en el diario';
      // Factores de riesgo
      case 'risk_recent_low_mood':
        return 'Estado de ánimo bajo reciente';
      case 'risk_low_meditation_frequency':
        return 'Baja frecuencia de meditación';
      case 'risk_low_journal_activity':
        return 'Poca actividad en el diario';
      // Factores protectores
      case 'protective_regular_meditation':
        return 'Práctica regular de meditación';
      case 'protective_regular_journaling':
        return 'Reflexión regular en el diario';
      case 'protective_positive_mood':
        return 'Estado de ánimo positivo general';
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
      case 'configure':
        return 'Configurar';
      case 'priority_high':
        return 'Alta';
      case 'priority_medium':
        return 'Media';
      case 'priority_low':
        return 'Baja';

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
      case 'wellness_metrics':
        return 'Wellness Metrics';
      case 'wellness_score':
        return 'Wellness Score';
      case 'based_on_activity':
        return 'Based on your recent activity';
      case 'insight_great_mood_title':
        return 'Great mood!';
      case 'insight_great_mood_description':
        return 'Your average mood this week has been very good. Keep it up!';
      case 'view_statistics':
        return 'View statistics';
      case 'insight_feeling_low_title':
        return 'Feeling a bit low?';
      case 'insight_feeling_low_description':
        return 'Your mood has been a bit low this week. Would you like to try a relaxing meditation?';
      case 'insight_mood_streak_title':
        return '7-day streak!';
      case 'insight_mood_streak_description':
        return 'You have logged your mood for 7 consecutive days. Incredible consistency!';
      case 'view_streak':
        return 'View streak';
      case 'view_progress':
        return 'View progress';
      case 'insight_ready_to_meditate_title':
        return 'Ready to meditate?';
      case 'insight_ready_to_meditate_description':
        return 'It’s been a while since you meditated. Would you like to resume your practice?';
      case 'insight_journal_reminder_description':
        return 'It’s been {days} days since you wrote in your journal. Would you like to reflect on your day?';
      case 'write_now':
        return 'Write now';
      case 'insight_goal_reminder_title':
        return 'Your goal reminder';
      case 'insight_goal_reminder_description':
        return 'Your goal is: {goal}. How is your progress?';
      case 'insight_welcome_title':
        return 'Welcome to MindSpace!';
      case 'insight_welcome_description':
        return 'Start your wellness journey by logging your first mood.';
      case 'start':
        return 'Start';
      case 'advanced_recommendations':
        return 'Advanced Recommendations';
      case 'recommendations_updated':
        return 'Recommendations updated ({count} found)';
      case 'refresh_recommendations':
        return 'Refresh recommendations';
      case 'no_recommendations':
        return 'No recommendations available';
      case 'use_app_for_better_recommendations':
        return 'Use the app more for personalized recommendations';
      case 'benefits':
        return 'Benefits';
      case 'estimated_time':
        return 'Estimated time';
      case 'configure':
        return 'Configure';
      case 'priority_high':
        return 'High';
      case 'priority_medium':
        return 'Medium';
      case 'priority_low':
        return 'Low';
      case 'interest_explore_title':
        return 'Explore {interest}';
      case 'interest_explore_description':
        return 'Discover new ways to incorporate {interest} into your wellness routine.';
      case 'goal_custom_plan_title':
        return 'Custom Plan';
      case 'goal_custom_plan_description':
        return 'Create a personalized plan to achieve: {goal}';
      case 'optimal_time_title':
        return 'Optimal Time';
      case 'optimal_time_message':
        return 'Based on your patterns, the best time for you to meditate is';
      case 'action_explore':
        return 'Explore';
      case 'action_view_plan':
        return 'View Plan';
      case 'time_variable':
        return 'Variable';
      case 'benefit_continuous_learning':
        return 'Continuous Learning';
      case 'benefit_motivation':
        return 'Increased Motivation';
      case 'benefit_personal_growth':
        return 'Personal Growth';
      case 'benefit_reduce_cortisol':
        return 'Reduce Cortisol';
      case 'benefit_improve_relaxation':
        return 'Improve Relaxation';
      case 'benefit_increase_mental_clarity':
        return 'Increase Mental Clarity';
      case 'benefit_increase_serotonin':
        return 'Increase Serotonin';
      case 'benefit_improve_self_esteem':
        return 'Improve Self-Esteem';
      case 'benefit_improve_sleep_quality':
        return 'Improve Sleep Quality';
      case 'benefit_reduce_insomnia':
        return 'Reduce Insomnia';
      case 'benefit_diversify_practice':
        return 'Diversify Practice';
      case 'benefit_increase_happiness':
        return 'Increase Happiness';
      case 'benefit_improve_perspective':
        return 'Improve Perspective';
      case 'advanced_prediction':
        return 'Advanced Prediction';
      case 'prediction_updated':
        return 'Prediction updated';
      case 'refresh_prediction':
        return 'Refresh prediction';
      case 'analyzing_patterns':
        return 'Analyzing your patterns...';
      case 'not_enough_data':
        return 'Not enough data';
      case 'use_app_for_better_predictions':
        return 'Use the app more frequently for better predictions';
      case 'log_mood':
        return 'Log Mood';
      case 'trend':
        return 'Trend';
      case 'confidence':
        return 'Confidence';
      case 'recommendation':
        return 'Recommendation';
      case 'identified_factors':
        return 'Identified factors';
      case 'next_week_prediction':
        return 'Next week prediction';
      case 'expected_mood':
        return 'Expected mood';
      case 'view_detailed_analysis':
        return 'View Detailed Analysis';
      case 'rec_consider_meditating_more':
        return 'Consider meditating more frequently.';
      case 'rec_consider_journaling':
        return 'Writing about your feelings can be very helpful.';
      case 'rec_start_meditation_practice_title':
        return 'Start your meditation practice';
      case 'rec_start_meditation_practice_description':
        return 'Meditation can help you achieve your goal of {goal}';
      case 'action_meditate_now':
        return 'Meditate now';
      case 'benefit_reduce_stress':
        return 'Reduce stress';
      case 'benefit_improve_focus':
        return 'Improve focus';
      case 'benefit_increase_self_awareness':
        return 'Increase self-awareness';
      case 'rec_maintain_meditation_practice_title':
        return 'Maintain your meditation practice';
      case 'rec_maintain_meditation_practice_description':
        return 'You have meditated {count} times. Keep going to see better results!';
      case 'action_continue_practice':
        return 'Continue practice';
      case 'benefit_build_habit':
        return 'Build habit';
      case 'benefit_improve_consistency':
        return 'Improve consistency';
      case 'benefit_increase_benefits':
        return 'Increase benefits';
      case 'rec_low_mood_title':
        return 'Techniques to improve your mood';
      case 'rec_low_mood_description':
        return 'We noticed you have felt a bit low. Here are some techniques that can help.';
      case 'action_view_techniques':
        return 'View techniques';
      case 'benefit_mood_improvement':
        return 'Mood improvement';
      case 'benefit_reduce_anxiety':
        return 'Reduce anxiety';
      case 'benefit_increase_energy':
        return 'Increase energy';
      case 'morning_label':
        return 'Morning';
      case 'afternoon_label':
        return 'Afternoon';
      case 'evening_label':
        return 'Evening';
      case 'action_configure_reminder':
        return 'Configure reminder';
      case 'benefit_more_effective':
        return 'More effective';
      case 'benefit_better_adherence':
        return 'Better adherence';
      case 'benefit_more_consistent_results':
        return 'More consistent results';
      case 'goal_reduce_stress_title':
        return 'Meditation to reduce stress';
      case 'goal_reduce_stress_description':
        return 'Try this meditation specifically designed to reduce stress';
      case 'action_start_meditation':
        return 'Start meditation';
      case 'goal_improve_mood_title':
        return 'Activities to improve mood';
      case 'goal_improve_mood_description':
        return 'A combination of techniques proven to improve mood';
      case 'action_view_activities':
        return 'View activities';
      case 'goal_sleep_better_title':
        return 'Meditation for sleep';
      case 'goal_sleep_better_description':
        return 'Relaxation techniques to improve sleep quality';
      case 'action_prepare_sleep':
        return 'Prepare for sleep';
      case 'interest_meditation_title':
        return 'New meditation technique';
      case 'interest_meditation_description':
        return 'Explore this new technique to enrich your practice';
      case 'action_learn_technique':
        return 'Learn technique';
      case 'benefit_increase_motivation':
        return 'Increase motivation';
      case 'benefit_improve_results':
        return 'Improve results';
      case 'interest_breathing_title':
        return 'Advanced breathing exercise';
      case 'interest_breathing_description':
        return 'Breathing technique you can practice anytime';
      case 'action_practice_now':
        return 'Practice now';
      case 'benefit_immediate_stress_reduction':
        return 'Immediate stress reduction';
      case 'interest_gratitude_title':
        return 'Gratitude journal';
      case 'interest_gratitude_description':
        return 'Write about things you feel grateful for today';
      case 'action_write_gratitude':
        return 'Write gratitude';
      case 'rec_need_more_data':
        return 'You need more data for accurate predictions';
      case 'rec_mood_improving':
        return 'Your mood is improving. Keep doing activities that make you feel good!';
      case 'rec_mood_declining':
        return 'We notice a downward trend. Try relaxation techniques or talk to someone you trust.';
      case 'rec_mood_stable':
        return 'Your mood is stable. It’s a good time to explore new wellness activities.';
      case 'factor_positive_trend':
        return 'Positive trend in recent days';
      case 'factor_negative_trend':
        return 'Negative trend in recent days';
      case 'factor_stable_mood':
        return 'Stable mood';
      case 'factor_meditation_helps':
        return 'Meditation improves your mood';
      case 'factor_journaling_helps':
        return 'Journaling helps you process emotions';
      case 'factor_december_better':
        return 'You tend to feel better in December';
      case 'factor_january_better':
        return 'You tend to feel better in January';
      case 'average_1_5':
        return 'Average (1-5)';
      case 'consistency':
        return 'Consistency';
      case 'this_week':
        return 'This week';
      case 'entries_this_week':
        return 'Entries this week';
      case 'score_excellent':
        return 'Excellent';
      case 'score_good':
        return 'Good';
      case 'score_fair':
        return 'Fair';
      case 'score_needs_improvement':
        return 'Needs improvement';

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
      case 'skip':
        return 'Skip';

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
      case 'rate_session':
        return 'Rate session';
      case 'notes_optional':
        return 'Notes (optional)';
      case 'notes_hint':
        return 'Write observations or how you felt...';
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
      case 'preferences':
        return 'Preferences';
      case 'haptics':
        return 'Haptics';
      case 'sound':
        return 'Sound';

      // Breathing phases and body scan (EN)
      case 'inhale':
        return 'Inhale';
      case 'hold':
        return 'Hold';
      case 'exhale':
        return 'Exhale';
      case 'focus_on':
        return 'Focus on';
      case 'head':
        return 'Head';
      case 'neck':
        return 'Neck';
      case 'shoulders':
        return 'Shoulders';
      case 'arms':
        return 'Arms';
      case 'torso':
        return 'Torso';
      case 'legs':
        return 'Legs';
      case 'feet':
        return 'Feet';
      case 'prompt_observe_breath':
        return 'Observe your breath';
      case 'prompt_listen_sounds':
        return 'Listen to the sounds';
      case 'prompt_feel_body':
        return 'Feel your body';
      case 'prompt_notice_thoughts':
        return 'Notice your thoughts and let them pass';

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
      case 'smart_analysis':
        return 'Smart Analysis';
      case 'quick_summary':
        return 'Quick Summary';
      case 'analysis_updated':
        return 'Analysis updated';
      case 'refresh_analytics':
        return 'Refresh analytics';
      case 'analyzing_data':
        return 'Analyzing your data...';
      case 'correlations':
        return 'Correlations';
      case 'patterns':
        return 'Patterns';
      case 'progress':
        return 'Progress';
      case 'wellness':
        return 'Wellness';
      case 'identified_correlations':
        return 'Identified Correlations';
      case 'view_complete_analysis':
        return 'View Complete Analysis';
      case 'temporal_patterns':
        return 'Temporal Patterns';
      case 'best_days':
        return 'Best Days';
      case 'best_hours':
        return 'Best Hours';
      case 'seasonal_patterns':
        return 'Seasonal Patterns';
      case 'progress_analysis':
        return 'Progress Analysis';
      case 'overall_progress':
        return 'Overall Progress';
      case 'recent_achievements':
        return 'Recent Achievements';
      case 'wellness_analysis':
        return 'Wellness Analysis';
      case 'risk_factors':
        return 'Risk Factors';
      case 'protective_factors':
        return 'Protective Factors';
      case 'detailed_analysis':
        return 'Detailed Analysis';
      case 'found_correlations':
        return 'Found Correlations';
      case 'not_enough_data_detailed':
        return 'Not enough data to show detailed analysis.';
      case 'usage':
        return 'Usage';
      case 'schedule':
        return 'Schedule';
      // Correlation insights
      case 'insight_meditation_positive':
        return 'Meditation has a positive impact on your mood';
      case 'insight_journal_emotions':
        return 'Writing in your journal helps you process emotions';
      case 'insight_app_usage_wellness':
        return 'Frequent use of the app improves your overall wellbeing';
      case 'insight_specific_schedules':
        return 'You have specific times when you feel better';
      // Seasonal patterns
      case 'feel_better_in':
        return 'You feel better in';
      // Achievements
      case 'achievement_mood_improvement':
        return 'Mood improvement';
      case 'achievement_meditation_consistency':
        return 'Greater consistency in meditation';
      case 'achievement_journal_activity':
        return 'More journal activity';
      // Risk factors
      case 'risk_recent_low_mood':
        return 'Recent low mood';
      case 'risk_low_meditation_frequency':
        return 'Low meditation frequency';
      case 'risk_low_journal_activity':
        return 'Little journal activity';
      // Protective factors
      case 'protective_regular_meditation':
        return 'Regular meditation practice';
      case 'protective_regular_journaling':
        return 'Regular journal reflection';
      case 'protective_positive_mood':
        return 'Generally positive mood';
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
      case 'wellness_metrics':
        return 'Indicateurs de bien-être';
      case 'wellness_score':
        return 'Score de bien-être';
      case 'based_on_activity':
        return 'Basé sur votre activité récente';
      case 'insight_great_mood_title':
        return 'Excellente humeur !';
      case 'insight_great_mood_description':
        return 'Votre humeur moyenne cette semaine a été très bonne. Continuez ainsi !';
      case 'view_statistics':
        return 'Voir les statistiques';
      case 'insight_feeling_low_title':
        return 'Vous vous sentez un peu bas ?';
      case 'insight_feeling_low_description':
        return 'Votre humeur a été un peu basse cette semaine. Voulez-vous essayer une méditation relaxante ?';
      case 'insight_mood_streak_title':
        return 'Série de 7 jours !';
      case 'insight_mood_streak_description':
        return 'Vous avez enregistré votre humeur pendant 7 jours consécutifs. Incroyable constance !';
      case 'view_streak':
        return 'Voir la série';
      case 'view_progress':
        return 'Voir les progrès';
      case 'insight_ready_to_meditate_title':
        return 'Prêt à méditer ?';
      case 'insight_ready_to_meditate_description':
        return 'Il y a un moment que vous n’avez pas médité. Voulez-vous reprendre votre pratique ?';
      case 'insight_journal_reminder_description':
        return 'Cela fait {days} jours que vous n’avez pas écrit dans votre journal. Voulez-vous réfléchir à votre journée ?';
      case 'write_now':
        return 'Écrire maintenant';
      case 'insight_goal_reminder_title':
        return 'Rappel de votre objectif';
      case 'insight_goal_reminder_description':
        return 'Votre objectif est : {goal}. Où en êtes-vous ?';
      case 'insight_welcome_title':
        return 'Bienvenue sur MindSpace !';
      case 'insight_welcome_description':
        return 'Commencez votre parcours de bien-être en enregistrant votre première humeur.';
      case 'start':
        return 'Commencer';
      case 'advanced_recommendations':
        return 'Recommandations Avancées';
      case 'recommendations_updated':
        return 'Recommandations mises à jour ({count} trouvées)';
      case 'refresh_recommendations':
        return 'Actualiser les recommandations';
      case 'no_recommendations':
        return 'Aucune recommandation disponible';
      case 'use_app_for_better_recommendations':
        return 'Utilisez l’application plus pour des recommandations personnalisées';
      case 'benefits':
        return 'Bénéfices';
      case 'estimated_time':
        return 'Temps estimé';
      case 'configure':
        return 'Configurer';
      case 'priority_high':
        return 'Élevée';
      case 'priority_medium':
        return 'Moyenne';
      case 'priority_low':
        return 'Faible';
      case 'interest_explore_title':
        return 'Explorer {interest}';
      case 'interest_explore_description':
        return 'Découvrez de nouvelles façons d\'intégrer {interest} dans votre routine de bien-être.';
      case 'goal_custom_plan_title':
        return 'Plan Personnalisé';
      case 'goal_custom_plan_description':
        return 'Créez un plan personnalisé pour atteindre : {goal}';
      case 'optimal_time_title':
        return 'Moment Optimal';
      case 'optimal_time_message':
        return 'Selon vos habitudes, le meilleur moment pour méditer est';
      case 'action_explore':
        return 'Explorer';
      case 'action_view_plan':
        return 'Voir le Plan';
      case 'time_variable':
        return 'Variable';
      case 'benefit_continuous_learning':
        return 'Apprentissage Continu';
      case 'benefit_motivation':
        return 'Motivation Accrue';
      case 'benefit_personal_growth':
        return 'Croissance Personnelle';
      case 'benefit_reduce_cortisol':
        return 'Réduire le Cortisol';
      case 'benefit_improve_relaxation':
        return 'Améliorer la Relaxation';
      case 'benefit_increase_mental_clarity':
        return 'Clarté Mentale';
      case 'benefit_increase_serotonin':
        return 'Augmenter la Sérotonine';
      case 'benefit_improve_self_esteem':
        return 'Améliorer l\'Estime de Soi';
      case 'benefit_improve_sleep_quality':
        return 'Améliorer la Qualité du Sommeil';
      case 'benefit_reduce_insomnia':
        return 'Réduire l\'Insomnie';
      case 'benefit_diversify_practice':
        return 'Diversifier la Pratique';
      case 'benefit_increase_happiness':
        return 'Augmenter le Bonheur';
      case 'benefit_improve_perspective':
        return 'Améliorer la Perspective';
      case 'action_configure_reminder':
        return 'Configurer un rappel';
      case 'benefit_more_effective':
        return 'Plus efficace';
      case 'benefit_better_adherence':
        return 'Meilleure adhérence';
      case 'benefit_more_consistent_results':
        return 'Résultats plus cohérents';
      case 'benefit_increase_motivation':
        return 'Augmenter la motivation';
      case 'benefit_improve_results':
        return 'Améliorer les résultats';
      case 'action_learn_technique':
        return 'Apprendre la technique';
      case 'interest_meditation_title':
        return 'Nouvelle technique de méditation';
      case 'interest_meditation_description':
        return 'Explorez cette nouvelle technique pour enrichir votre pratique';
      case 'advanced_prediction':
        return 'Prédiction avancée';
      case 'prediction_updated':
        return 'Prédiction mise à jour';
      case 'refresh_prediction':
        return 'Actualiser la prédiction';
      case 'analyzing_patterns':
        return 'Analyse de vos schémas...';
      case 'not_enough_data':
        return 'Pas assez de données';
      case 'use_app_for_better_predictions':
        return 'Utilisez l’application plus fréquemment pour de meilleures prédictions';
      case 'log_mood':
        return 'Enregistrer l’humeur';
      case 'trend':
        return 'Tendance';
      case 'confidence':
        return 'Confiance';
      case 'recommendation':
        return 'Recommandation';
      case 'identified_factors':
        return 'Facteurs identifiés';
      case 'next_week_prediction':
        return 'Prédiction de la semaine prochaine';
      case 'expected_mood':
        return 'Humeur prévue';
      case 'view_detailed_analysis':
        return 'Voir l’analyse détaillée';
      case 'rec_need_more_data':
        return 'Vous avez besoin de plus de données pour des prédictions précises';
      case 'rec_mood_improving':
        return 'Votre humeur s’améliore. Continuez les activités qui vous font du bien !';
      case 'rec_mood_declining':
        return 'Nous remarquons une tendance à la baisse. Essayez des techniques de relaxation ou parlez à quelqu’un de confiance.';
      case 'rec_mood_stable':
        return 'Votre humeur est stable. C’est un bon moment pour explorer de nouvelles activités de bien-être.';
      case 'factor_positive_trend':
        return 'Tendance positive ces derniers jours';
      case 'factor_negative_trend':
        return 'Tendance négative ces derniers jours';
      case 'factor_stable_mood':
        return 'Humeur stable';
      case 'factor_meditation_helps':
        return 'La méditation améliore votre humeur';
      case 'factor_journaling_helps':
        return 'L’écriture dans un journal aide à traiter les émotions';
      case 'factor_december_better':
        return 'Vous avez tendance à vous sentir mieux en décembre';
      case 'factor_january_better':
        return 'Vous avez tendance à vous sentir mieux en janvier';
      case 'average_1_5':
        return 'Moyenne (1-5)';
      case 'consistency':
        return 'Cohérence';
      case 'this_week':
        return 'Cette semaine';
      case 'entries_this_week':
        return 'Entrées cette semaine';
      case 'score_excellent':
        return 'Excellent';
      case 'score_good':
        return 'Bon';
      case 'score_fair':
        return 'Passable';
      case 'score_needs_improvement':
        return 'À améliorer';
      case 'inhale':
        return 'Inspirez';
      case 'hold':
        return 'Retenez';
      case 'exhale':
        return 'Expirez';
      case 'focus_on':
        return 'Concentrez-vous sur';
      case 'head':
        return 'Tête';
      case 'neck':
        return 'Cou';
      case 'shoulders':
        return 'Épaules';
      case 'arms':
        return 'Bras';
      case 'torso':
        return 'Torse';
      case 'legs':
        return 'Jambes';
      case 'feet':
        return 'Pieds';
      case 'prompt_observe_breath':
        return 'Observez votre respiration';
      case 'prompt_listen_sounds':
        return 'Écoutez les sons';
      case 'prompt_feel_body':
        return 'Ressentez votre corps';
      case 'prompt_notice_thoughts':
        return 'Remarquez vos pensées et laissez-les passer';

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
      case 'skip':
        return 'Ignorer';

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
      case 'smart_analysis':
        return 'Analyse Intelligente';
      case 'quick_summary':
        return 'Résumé Rapide';
      case 'analysis_updated':
        return 'Analyse mise à jour';
      case 'refresh_analytics':
        return 'Actualiser l\'analyse';
      case 'analyzing_data':
        return 'Analyse de vos données...';
      case 'correlations':
        return 'Corrélations';
      case 'patterns':
        return 'Modèles';
      case 'progress':
        return 'Progrès';
      case 'wellness':
        return 'Bien-être';
      case 'identified_correlations':
        return 'Corrélations Identifiées';
      case 'view_complete_analysis':
        return 'Voir l\'Analyse Complète';
      case 'temporal_patterns':
        return 'Modèles Temporels';
      case 'best_days':
        return 'Meilleurs Jours';
      case 'best_hours':
        return 'Meilleures Heures';
      case 'seasonal_patterns':
        return 'Modèles Saisonniers';
      case 'progress_analysis':
        return 'Analyse des Progrès';
      case 'overall_progress':
        return 'Progrès Global';
      case 'recent_achievements':
        return 'Réalisations Récentes';
      case 'wellness_analysis':
        return 'Analyse du Bien-être';
      case 'risk_factors':
        return 'Facteurs de Risque';
      case 'protective_factors':
        return 'Facteurs Protecteurs';
      case 'detailed_analysis':
        return 'Analyse Détaillée';
      case 'found_correlations':
        return 'Corrélations Trouvées';
      case 'not_enough_data_detailed':
        return 'Pas assez de données pour afficher une analyse détaillée.';
      case 'usage':
        return 'Utilisation';
      case 'schedule':
        return 'Horaire';
      // Insights de corrélation
      case 'insight_meditation_positive':
        return 'La méditation a un impact positif sur votre humeur';
      case 'insight_journal_emotions':
        return 'Écrire dans votre journal vous aide à traiter les émotions';
      case 'insight_app_usage_wellness':
        return 'L\'utilisation fréquente de l\'app améliore votre bien-être général';
      case 'insight_specific_schedules':
        return 'Vous avez des horaires spécifiques où vous vous sentez mieux';
      // Modèles saisonniers
      case 'feel_better_in':
        return 'Vous vous sentez mieux en';
      // Réalisations
      case 'achievement_mood_improvement':
        return 'Amélioration de l\'humeur';
      case 'achievement_meditation_consistency':
        return 'Plus de cohérence dans la méditation';
      case 'achievement_journal_activity':
        return 'Plus d\'activité dans le journal';
      // Facteurs de risque
      case 'risk_recent_low_mood':
        return 'Humeur récente basse';
      case 'risk_low_meditation_frequency':
        return 'Faible fréquence de méditation';
      case 'risk_low_journal_activity':
        return 'Peu d\'activité dans le journal';
      // Facteurs protecteurs
      case 'protective_regular_meditation':
        return 'Pratique régulière de méditation';
      case 'protective_regular_journaling':
        return 'Réflexion régulière dans le journal';
      case 'protective_positive_mood':
        return 'Humeur généralement positive';

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
      case 'wellness_metrics':
        return 'Wohlbefinden-Metriken';
      case 'wellness_score':
        return 'Wohlbefinden-Score';
      case 'based_on_activity':
        return 'Basierend auf Ihrer jüngsten Aktivität';
      case 'insight_great_mood_title':
        return 'Großartige Stimmung!';
      case 'insight_great_mood_description':
        return 'Ihre durchschnittliche Stimmung in dieser Woche war sehr gut. Weiter so!';
      case 'view_statistics':
        return 'Statistiken anzeigen';
      case 'insight_feeling_low_title':
        return 'Fühlen Sie sich etwas niedergeschlagen?';
      case 'insight_feeling_low_description':
        return 'Ihre Stimmung war diese Woche etwas niedrig. Möchten Sie eine entspannende Meditation ausprobieren?';
      case 'insight_mood_streak_title':
        return '7-Tage-Serie!';
      case 'insight_mood_streak_description':
        return 'Sie haben Ihre Stimmung 7 Tage in Folge protokolliert. Tolle Beständigkeit!';
      case 'view_streak':
        return 'Serie anzeigen';
      case 'view_progress':
        return 'Fortschritt anzeigen';
      case 'insight_ready_to_meditate_title':
        return 'Bereit zu meditieren?';
      case 'insight_ready_to_meditate_description':
        return 'Es ist eine Weile her, seit Sie meditiert haben. Möchten Sie Ihre Praxis wieder aufnehmen?';
      case 'insight_journal_reminder_description':
        return 'Es sind {days} Tage vergangen, seit Sie in Ihr Journal geschrieben haben. Möchten Sie über Ihren Tag nachdenken?';
      case 'write_now':
        return 'Jetzt schreiben';
      case 'insight_goal_reminder_title':
        return 'Erinnerung an Ihr Ziel';
      case 'insight_goal_reminder_description':
        return 'Ihr Ziel ist: {goal}. Wie ist Ihr Fortschritt?';
      case 'insight_welcome_title':
        return 'Willkommen bei MindSpace!';
      case 'insight_welcome_description':
        return 'Beginnen Sie Ihre Wellness-Reise, indem Sie Ihre erste Stimmung erfassen.';
      case 'start':
        return 'Starten';
      case 'advanced_recommendations':
        return 'Erweiterte Empfehlungen';
      case 'recommendations_updated':
        return 'Empfehlungen aktualisiert ({count} gefunden)';
      case 'refresh_recommendations':
        return 'Empfehlungen aktualisieren';
      case 'no_recommendations':
        return 'Keine Empfehlungen verfügbar';
      case 'use_app_for_better_recommendations':
        return 'Nutzen Sie die App öfter für personalisierte Empfehlungen';
      case 'benefits':
        return 'Vorteile';
      case 'estimated_time':
        return 'Geschätzte Zeit';
      case 'configure':
        return 'Konfigurieren';
      case 'priority_high':
        return 'Hoch';
      case 'priority_medium':
        return 'Mittel';
      case 'priority_low':
        return 'Niedrig';
      case 'interest_explore_title':
        return '{interest} Erkunden';
      case 'interest_explore_description':
        return 'Entdecken Sie neue Wege, {interest} in Ihre Wellness-Routine zu integrieren.';
      case 'goal_custom_plan_title':
        return 'Individueller Plan';
      case 'goal_custom_plan_description':
        return 'Erstellen Sie einen personalisierten Plan für: {goal}';
      case 'optimal_time_title':
        return 'Optimale Zeit';
      case 'optimal_time_message':
        return 'Basierend auf Ihren Mustern ist die beste Zeit zum Meditieren';
      case 'action_explore':
        return 'Erkunden';
      case 'action_view_plan':
        return 'Plan Ansehen';
      case 'time_variable':
        return 'Variabel';
      case 'benefit_continuous_learning':
        return 'Kontinuierliches Lernen';
      case 'benefit_motivation':
        return 'Erhöhte Motivation';
      case 'benefit_personal_growth':
        return 'Persönliches Wachstum';
      case 'benefit_reduce_cortisol':
        return 'Cortisol Reduzieren';
      case 'benefit_improve_relaxation':
        return 'Entspannung Verbessern';
      case 'benefit_increase_mental_clarity':
        return 'Geistige Klarheit';
      case 'benefit_increase_serotonin':
        return 'Serotonin Erhöhen';
      case 'benefit_improve_self_esteem':
        return 'Selbstwertgefühl Stärken';
      case 'benefit_improve_sleep_quality':
        return 'Schlafqualität Verbessern';
      case 'benefit_reduce_insomnia':
        return 'Schlaflosigkeit Reduzieren';
      case 'benefit_diversify_practice':
        return 'Praxis Diversifizieren';
      case 'benefit_increase_happiness':
        return 'Glück Steigern';
      case 'benefit_improve_perspective':
        return 'Perspektive Verbessern';
      case 'action_configure_reminder':
        return 'Erinnerung konfigurieren';
      case 'benefit_more_effective':
        return 'Effektiver';
      case 'benefit_better_adherence':
        return 'Bessere Einhaltung';
      case 'benefit_more_consistent_results':
        return 'Konsistentere Ergebnisse';
      case 'benefit_increase_motivation':
        return 'Motivation steigern';
      case 'benefit_improve_results':
        return 'Ergebnisse verbessern';
      case 'action_learn_technique':
        return 'Technik lernen';
      case 'interest_meditation_title':
        return 'Neue Meditationstechnik';
      case 'interest_meditation_description':
        return 'Entdecken Sie diese neue Technik, um Ihre Praxis zu bereichern';
      case 'advanced_prediction':
        return 'Erweiterte Vorhersage';
      case 'prediction_updated':
        return 'Vorhersage aktualisiert';
      case 'refresh_prediction':
        return 'Vorhersage aktualisieren';
      case 'analyzing_patterns':
        return 'Muster werden analysiert...';
      case 'not_enough_data':
        return 'Nicht genügend Daten';
      case 'use_app_for_better_predictions':
        return 'Nutzen Sie die App häufiger für bessere Vorhersagen';
      case 'log_mood':
        return 'Stimmung protokollieren';
      case 'trend':
        return 'Trend';
      case 'confidence':
        return 'Zuversicht';
      case 'recommendation':
        return 'Empfehlung';
      case 'identified_factors':
        return 'Identifizierte Faktoren';
      case 'next_week_prediction':
        return 'Vorhersage für nächste Woche';
      case 'expected_mood':
        return 'Erwartete Stimmung';
      case 'view_detailed_analysis':
        return 'Detaillierte Analyse anzeigen';
      case 'rec_need_more_data':
        return 'Sie benötigen mehr Daten für genaue Vorhersagen';
      case 'rec_mood_improving':
        return 'Ihre Stimmung verbessert sich. Machen Sie weiter mit den Aktivitäten, die Ihnen guttun!';
      case 'rec_mood_declining':
        return 'Wir sehen einen Abwärtstrend. Versuchen Sie Entspannungstechniken oder sprechen Sie mit jemandem Ihres Vertrauens.';
      case 'rec_mood_stable':
        return 'Ihre Stimmung ist stabil. Eine gute Gelegenheit, neue Wohlfühlaktivitäten zu erkunden.';
      case 'factor_positive_trend':
        return 'Positiver Trend in den letzten Tagen';
      case 'factor_negative_trend':
        return 'Negativer Trend in den letzten Tagen';
      case 'factor_stable_mood':
        return 'Stabile Stimmung';
      case 'factor_meditation_helps':
        return 'Meditation verbessert Ihre Stimmung';
      case 'factor_journaling_helps':
        return 'Tagebuchschreiben hilft, Emotionen zu verarbeiten';
      case 'factor_december_better':
        return 'Sie fühlen sich tendenziell im Dezember besser';
      case 'factor_january_better':
        return 'Sie fühlen sich tendenziell im Januar besser';
      case 'average_1_5':
        return 'Durchschnitt (1-5)';
      case 'consistency':
        return 'Konsistenz';
      case 'this_week':
        return 'Diese Woche';
      case 'entries_this_week':
        return 'Einträge diese Woche';
      case 'score_excellent':
        return 'Ausgezeichnet';
      case 'score_good':
        return 'Gut';
      case 'score_fair':
        return 'Mittel';
      case 'score_needs_improvement':
        return 'Verbesserungsbedarf';
      case 'inhale':
        return 'Einatmen';
      case 'hold':
        return 'Anhalten';
      case 'exhale':
        return 'Ausatmen';
      case 'focus_on':
        return 'Fokussiere auf';
      case 'head':
        return 'Kopf';
      case 'neck':
        return 'Nacken';
      case 'shoulders':
        return 'Schultern';
      case 'arms':
        return 'Arme';
      case 'torso':
        return 'Oberkörper';
      case 'legs':
        return 'Beine';
      case 'feet':
        return 'Füße';
      case 'prompt_observe_breath':
        return 'Beobachte deinen Atem';
      case 'prompt_listen_sounds':
        return 'Höre auf die Geräusche';
      case 'prompt_feel_body':
        return 'Fühle deinen Körper';
      case 'prompt_notice_thoughts':
        return 'Beobachte deine Gedanken und lass sie vorbeiziehen';

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
      case 'skip':
        return 'Überspringen';

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
      case 'rate_session':
        return 'Sitzung bewerten';
      case 'notes_optional':
        return 'Notizen (optional)';
      case 'notes_hint':
        return 'Schreiben Sie Beobachtungen oder wie Sie sich gefühlt haben...';
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
      case 'preferences':
        return 'Einstellungen';
      case 'haptics':
        return 'Vibration';
      case 'sound':
        return 'Ton';

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
      case 'smart_analysis':
        return 'Intelligente Analyse';
      case 'quick_summary':
        return 'Schnelle Zusammenfassung';
      case 'analysis_updated':
        return 'Analyse aktualisiert';
      case 'refresh_analytics':
        return 'Analyse aktualisieren';
      case 'analyzing_data':
        return 'Analysiere deine Daten...';
      case 'correlations':
        return 'Korrelationen';
      case 'patterns':
        return 'Muster';
      case 'progress':
        return 'Fortschritt';
      case 'wellness':
        return 'Wohlbefinden';
      case 'identified_correlations':
        return 'Identifizierte Korrelationen';
      case 'view_complete_analysis':
        return 'Vollständige Analyse anzeigen';
      case 'temporal_patterns':
        return 'Zeitliche Muster';
      case 'best_days':
        return 'Beste Tage';
      case 'best_hours':
        return 'Beste Stunden';
      case 'seasonal_patterns':
        return 'Saisonale Muster';
      case 'progress_analysis':
        return 'Fortschrittsanalyse';
      case 'overall_progress':
        return 'Gesamtfortschritt';
      case 'recent_achievements':
        return 'Kürzliche Erfolge';
      case 'wellness_analysis':
        return 'Wohlbefindensanalyse';
      case 'risk_factors':
        return 'Risikofaktoren';
      case 'protective_factors':
        return 'Schutzfaktoren';
      case 'detailed_analysis':
        return 'Detaillierte Analyse';
      case 'found_correlations':
        return 'Gefundene Korrelationen';
      case 'not_enough_data_detailed':
        return 'Nicht genügend Daten für eine detaillierte Analyse.';
      case 'usage':
        return 'Nutzung';
      case 'schedule':
        return 'Zeitplan';
      // Korrelations-Einsichten
      case 'insight_meditation_positive':
        return 'Meditation hat einen positiven Einfluss auf Ihre Stimmung';
      case 'insight_journal_emotions':
        return 'Das Schreiben in Ihr Tagebuch hilft Ihnen, Emotionen zu verarbeiten';
      case 'insight_app_usage_wellness':
        return 'Häufige Nutzung der App verbessert Ihr allgemeines Wohlbefinden';
      case 'insight_specific_schedules':
        return 'Sie haben bestimmte Zeiten, in denen Sie sich besser fühlen';
      // Saisonale Muster
      case 'feel_better_in':
        return 'Sie fühlen sich besser in';
      // Erfolge
      case 'achievement_mood_improvement':
        return 'Stimmungsverbesserung';
      case 'achievement_meditation_consistency':
        return 'Mehr Konsistenz bei der Meditation';
      case 'achievement_journal_activity':
        return 'Mehr Tagebuch-Aktivität';
      // Risikofaktoren
      case 'risk_recent_low_mood':
        return 'Kürzlich schlechte Stimmung';
      case 'risk_low_meditation_frequency':
        return 'Niedrige Meditationsfrequenz';
      case 'risk_low_journal_activity':
        return 'Wenig Tagebuch-Aktivität';
      // Schutzfaktoren
      case 'protective_regular_meditation':
        return 'Regelmäßige Meditationspraxis';
      case 'protective_regular_journaling':
        return 'Regelmäßige Tagebuchreflexion';
      case 'protective_positive_mood':
        return 'Allgemein positive Stimmung';

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
      case 'wellness_metrics':
        return 'Metriche di benessere';
      case 'wellness_score':
        return 'Punteggio di benessere';
      case 'based_on_activity':
        return 'Basato sulla tua attività recente';
      case 'insight_great_mood_title':
        return 'Ottimo umore!';
      case 'insight_great_mood_description':
        return 'Il tuo umore medio questa settimana è stato molto buono. Continua così!';
      case 'view_statistics':
        return 'Vedi statistiche';
      case 'insight_feeling_low_title':
        return 'Ti senti un po’ giù?';
      case 'insight_feeling_low_description':
        return 'Il tuo umore è stato un po’ basso questa settimana. Vuoi provare una meditazione rilassante?';
      case 'insight_mood_streak_title':
        return 'Serie di 7 giorni!';
      case 'insight_mood_streak_description':
        return 'Hai registrato il tuo umore per 7 giorni consecutivi. Incredibile costanza!';
      case 'view_streak':
        return 'Vedi serie';
      case 'view_progress':
        return 'Vedi progresso';
      case 'insight_ready_to_meditate_title':
        return 'Pronto a meditare?';
      case 'insight_ready_to_meditate_description':
        return 'È passato un po’ di tempo dall’ultima meditazione. Vuoi riprendere la pratica?';
      case 'insight_journal_reminder_description':
        return 'Sono passati {days} giorni dall’ultima volta che hai scritto nel diario. Vuoi riflettere sulla tua giornata?';
      case 'write_now':
        return 'Scrivi ora';
      case 'insight_goal_reminder_title':
        return 'Promemoria del tuo obiettivo';
      case 'insight_goal_reminder_description':
        return 'Il tuo obiettivo è: {goal}. Come procede?';
      case 'insight_welcome_title':
        return 'Benvenuto in MindSpace!';
      case 'insight_welcome_description':
        return 'Inizia il tuo percorso di benessere registrando il tuo primo umore.';
      case 'start':
        return 'Inizia';
      case 'advanced_recommendations':
        return 'Raccomandazioni Avanzate';
      case 'recommendations_updated':
        return 'Raccomandazioni aggiornate ({count} trovate)';
      case 'refresh_recommendations':
        return 'Aggiorna raccomandazioni';
      case 'no_recommendations':
        return 'Nessuna raccomandazione disponibile';
      case 'use_app_for_better_recommendations':
        return 'Usa l’app di più per raccomandazioni personalizzate';
      case 'benefits':
        return 'Benefici';
      case 'estimated_time':
        return 'Tempo stimato';
      case 'configure':
        return 'Configura';
      case 'priority_high':
        return 'Alta';
      case 'priority_medium':
        return 'Media';
      case 'priority_low':
        return 'Bassa';
      case 'interest_explore_title':
        return 'Esplora {interest}';
      case 'interest_explore_description':
        return 'Scopri nuovi modi per integrare {interest} nella tua routine di benessere.';
      case 'goal_custom_plan_title':
        return 'Piano Personalizzato';
      case 'goal_custom_plan_description':
        return 'Crea un piano personalizzato per raggiungere: {goal}';
      case 'optimal_time_title':
        return 'Momento Ottimale';
      case 'optimal_time_message':
        return 'Basato sui tuoi schemi, il momento migliore per meditare è';
      case 'action_explore':
        return 'Esplora';
      case 'action_view_plan':
        return 'Vedi Piano';
      case 'time_variable':
        return 'Variabile';
      case 'benefit_continuous_learning':
        return 'Apprendimento Continuo';
      case 'benefit_motivation':
        return 'Motivazione Aumentata';
      case 'benefit_personal_growth':
        return 'Crescita Personale';
      case 'benefit_reduce_cortisol':
        return 'Ridurre il Cortisolo';
      case 'benefit_improve_relaxation':
        return 'Migliorare il Rilassamento';
      case 'benefit_increase_mental_clarity':
        return 'Chiarezza Mentale';
      case 'benefit_increase_serotonin':
        return 'Aumentare la Serotonina';
      case 'benefit_improve_self_esteem':
        return 'Migliorare l\'Autostima';
      case 'benefit_improve_sleep_quality':
        return 'Migliorare la Qualità del Sonno';
      case 'benefit_reduce_insomnia':
        return 'Ridurre l\'Insonnia';
      case 'benefit_diversify_practice':
        return 'Diversificare la Pratica';
      case 'benefit_increase_happiness':
        return 'Aumentare la Felicità';
      case 'benefit_improve_perspective':
        return 'Migliorare la Prospettiva';
      case 'action_configure_reminder':
        return 'Configura promemoria';
      case 'benefit_more_effective':
        return 'Più efficace';
      case 'benefit_better_adherence':
        return 'Migliore aderenza';
      case 'benefit_more_consistent_results':
        return 'Risultati più coerenti';
      case 'benefit_increase_motivation':
        return 'Aumentare la motivazione';
      case 'benefit_improve_results':
        return 'Migliorare i risultati';
      case 'action_learn_technique':
        return 'Impara la tecnica';
      case 'interest_meditation_title':
        return 'Nuova tecnica di meditazione';
      case 'interest_meditation_description':
        return 'Esplora questa nuova tecnica per arricchire la tua pratica';
      case 'advanced_prediction':
        return 'Previsione Avanzata';
      case 'prediction_updated':
        return 'Previsione aggiornata';
      case 'refresh_prediction':
        return 'Aggiorna previsione';
      case 'analyzing_patterns':
        return 'Analisi dei tuoi schemi...';
      case 'not_enough_data':
        return 'Dati insufficienti';
      case 'use_app_for_better_predictions':
        return 'Usa l’app più frequentemente per previsioni migliori';
      case 'log_mood':
        return 'Registrare umore';
      case 'trend':
        return 'Tendenza';
      case 'confidence':
        return 'Affidabilità';
      case 'recommendation':
        return 'Raccomandazione';
      case 'identified_factors':
        return 'Fattori identificati';
      case 'next_week_prediction':
        return 'Previsione prossima settimana';
      case 'expected_mood':
        return 'Umore previsto';
      case 'view_detailed_analysis':
        return 'Vedi Analisi Dettagliata';
      case 'rec_need_more_data':
        return 'Hai bisogno di più dati per previsioni accurate';
      case 'rec_mood_improving':
        return 'Il tuo umore sta migliorando. Continua con le attività che ti fanno stare bene!';
      case 'rec_mood_declining':
        return 'Notiamo una tendenza al ribasso. Prova tecniche di rilassamento o parla con qualcuno di fiducia.';
      case 'rec_mood_stable':
        return 'Il tuo umore è stabile. È un buon momento per esplorare nuove attività di benessere.';
      case 'factor_positive_trend':
        return 'Tendenza positiva negli ultimi giorni';
      case 'factor_negative_trend':
        return 'Tendenza negativa negli ultimi giorni';
      case 'factor_stable_mood':
        return 'Umore stabile';
      case 'factor_meditation_helps':
        return 'La meditazione migliora il tuo umore';
      case 'factor_journaling_helps':
        return 'Scrivere nel diario aiuta a elaborare le emozioni';
      case 'factor_december_better':
        return 'Tendi a sentirti meglio a dicembre';
      case 'factor_january_better':
        return 'Tendi a sentirti meglio a gennaio';
      case 'average_1_5':
        return 'Media (1-5)';
      case 'consistency':
        return 'Coerenza';
      case 'this_week':
        return 'Questa settimana';
      case 'entries_this_week':
        return 'Voci questa settimana';
      case 'score_excellent':
        return 'Eccellente';
      case 'score_good':
        return 'Buono';
      case 'score_fair':
        return 'Discreto';
      case 'score_needs_improvement':
        return 'Da migliorare';
      case 'inhale':
        return 'Inspira';
      case 'hold':
        return 'Trattieni';
      case 'exhale':
        return 'Espira';
      case 'focus_on':
        return 'Concentrati su';
      case 'head':
        return 'Testa';
      case 'neck':
        return 'Collo';
      case 'shoulders':
        return 'Spalle';
      case 'arms':
        return 'Braccia';
      case 'torso':
        return 'Torso';
      case 'legs':
        return 'Gambe';
      case 'feet':
        return 'Piedi';
      case 'prompt_observe_breath':
        return 'Osserva il respiro';
      case 'prompt_listen_sounds':
        return 'Ascolta i suoni';
      case 'prompt_feel_body':
        return 'Senti il corpo';
      case 'prompt_notice_thoughts':
        return 'Nota i pensieri e lasciali andare';

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
      case 'skip':
        return 'Salta';

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
      case 'rate_session':
        return 'Valuta la sessione';
      case 'notes_optional':
        return 'Note (opzionale)';
      case 'notes_hint':
        return 'Scrivi osservazioni o come ti sei sentito...';
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
      case 'preferences':
        return 'Preferenze';
      case 'haptics':
        return 'Vibrazione';
      case 'sound':
        return 'Suono';

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
      case 'smart_analysis':
        return 'Analisi Intelligente';
      case 'quick_summary':
        return 'Riassunto Rapido';
      case 'analysis_updated':
        return 'Analisi aggiornata';
      case 'refresh_analytics':
        return 'Aggiorna analisi';
      case 'analyzing_data':
        return 'Analizzando i tuoi dati...';
      case 'correlations':
        return 'Correlazioni';
      case 'patterns':
        return 'Modelli';
      case 'progress':
        return 'Progresso';
      case 'wellness':
        return 'Benessere';
      case 'identified_correlations':
        return 'Correlazioni Identificate';
      case 'view_complete_analysis':
        return 'Visualizza Analisi Completa';
      case 'temporal_patterns':
        return 'Modelli Temporali';
      case 'best_days':
        return 'Giorni Migliori';
      case 'best_hours':
        return 'Ore Migliori';
      case 'seasonal_patterns':
        return 'Modelli Stagionali';
      case 'progress_analysis':
        return 'Analisi del Progresso';
      case 'overall_progress':
        return 'Progresso Generale';
      case 'recent_achievements':
        return 'Risultati Recenti';
      case 'wellness_analysis':
        return 'Analisi del Benessere';
      case 'risk_factors':
        return 'Fattori di Rischio';
      case 'protective_factors':
        return 'Fattori Protettivi';
      case 'detailed_analysis':
        return 'Analisi Dettagliata';
      case 'found_correlations':
        return 'Correlazioni Trovate';
      case 'not_enough_data_detailed':
        return 'Dati insufficienti per mostrare un\'analisi dettagliata.';
      case 'usage':
        return 'Utilizzo';
      case 'schedule':
        return 'Orario';
      // Intuizioni di correlazione
      case 'insight_meditation_positive':
        return 'La meditazione ha un impatto positivo sul tuo umore';
      case 'insight_journal_emotions':
        return 'Scrivere nel tuo diario ti aiuta a elaborare le emozioni';
      case 'insight_app_usage_wellness':
        return 'L\'uso frequente dell\'app migliora il tuo benessere generale';
      case 'insight_specific_schedules':
        return 'Hai orari specifici in cui ti senti meglio';
      // Modelli stagionali
      case 'feel_better_in':
        return 'Ti senti meglio in';
      // Risultati
      case 'achievement_mood_improvement':
        return 'Miglioramento dell\'umore';
      case 'achievement_meditation_consistency':
        return 'Maggiore coerenza nella meditazione';
      case 'achievement_journal_activity':
        return 'Più attività nel diario';
      // Fattori di rischio
      case 'risk_recent_low_mood':
        return 'Umore basso recente';
      case 'risk_low_meditation_frequency':
        return 'Bassa frequenza di meditazione';
      case 'risk_low_journal_activity':
        return 'Poca attività nel diario';
      // Fattori protettivi
      case 'protective_regular_meditation':
        return 'Pratica regolare di meditazione';
      case 'protective_regular_journaling':
        return 'Riflessione regolare nel diario';
      case 'protective_positive_mood':
        return 'Umore generalmente positivo';

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
      case 'wellness_metrics':
        return 'Métricas de Bem-estar';
      case 'wellness_score':
        return 'Pontuação de Bem-estar';
      case 'based_on_activity':
        return 'Com base na sua atividade recente';
      case 'insight_great_mood_title':
        return 'Ótimo humor!';
      case 'insight_great_mood_description':
        return 'Seu humor médio esta semana foi muito bom. Continue assim!';
      case 'view_statistics':
        return 'Ver estatísticas';
      case 'insight_feeling_low_title':
        return 'Sentindo-se um pouco para baixo?';
      case 'insight_feeling_low_description':
        return 'Seu humor esteve um pouco baixo esta semana. Gostaria de tentar uma meditação relaxante?';
      case 'insight_mood_streak_title':
        return 'Sequência de 7 dias!';
      case 'insight_mood_streak_description':
        return 'Você registrou seu humor por 7 dias consecutivos. Incrível consistência!';
      case 'view_streak':
        return 'Ver sequência';
      case 'view_progress':
        return 'Ver progresso';
      case 'insight_ready_to_meditate_title':
        return 'Pronto para meditar?';
      case 'insight_ready_to_meditate_description':
        return 'Faz um tempo que você não medita. Quer retomar a prática?';
      case 'insight_journal_reminder_description':
        return 'Faz {days} dias que você não escreve no diário. Quer refletir sobre seu dia?';
      case 'write_now':
        return 'Escrever agora';
      case 'insight_goal_reminder_title':
        return 'Lembrete do seu objetivo';
      case 'insight_goal_reminder_description':
        return 'Seu objetivo é: {goal}. Como está seu progresso?';
      case 'insight_welcome_title':
        return 'Bem-vindo ao MindSpace!';
      case 'insight_welcome_description':
        return 'Comece sua jornada de bem-estar registrando seu primeiro humor.';
      case 'start':
        return 'Começar';
      case 'advanced_recommendations':
        return 'Recomendações Avançadas';
      case 'recommendations_updated':
        return 'Recomendações atualizadas ({count} encontradas)';
      case 'refresh_recommendations':
        return 'Atualizar recomendações';
      case 'no_recommendations':
        return 'Sem recomendações disponíveis';
      case 'use_app_for_better_recommendations':
        return 'Use o app mais para recomendações personalizadas';
      case 'benefits':
        return 'Benefícios';
      case 'estimated_time':
        return 'Tempo estimado';
      case 'configure':
        return 'Configurar';
      case 'priority_high':
        return 'Alta';
      case 'priority_medium':
        return 'Média';
      case 'priority_low':
        return 'Baixa';
      case 'interest_explore_title':
        return 'Explorar {interest}';
      case 'interest_explore_description':
        return 'Descubra novas maneiras de incorporar {interest} em sua rotina de bem-estar.';
      case 'goal_custom_plan_title':
        return 'Plano Personalizado';
      case 'goal_custom_plan_description':
        return 'Crie um plano personalizado para alcançar: {goal}';
      case 'optimal_time_title':
        return 'Momento Ideal';
      case 'optimal_time_message':
        return 'Com base nos seus padrões, o melhor momento para meditar é';
      case 'action_explore':
        return 'Explorar';
      case 'action_view_plan':
        return 'Ver Plano';
      case 'time_variable':
        return 'Variável';
      case 'benefit_continuous_learning':
        return 'Aprendizado Contínuo';
      case 'benefit_motivation':
        return 'Motivação Aumentada';
      case 'benefit_personal_growth':
        return 'Crescimento Pessoal';
      case 'benefit_reduce_cortisol':
        return 'Reduzir Cortisol';
      case 'benefit_improve_relaxation':
        return 'Melhorar Relaxamento';
      case 'benefit_increase_mental_clarity':
        return 'Clareza Mental';
      case 'benefit_increase_serotonin':
        return 'Aumentar Serotonina';
      case 'benefit_improve_self_esteem':
        return 'Melhorar Autoestima';
      case 'benefit_improve_sleep_quality':
        return 'Melhorar Qualidade do Sono';
      case 'benefit_reduce_insomnia':
        return 'Reduzir Insônia';
      case 'benefit_diversify_practice':
        return 'Diversificar Prática';
      case 'benefit_increase_happiness':
        return 'Aumentar Felicidade';
      case 'benefit_improve_perspective':
        return 'Melhorar Perspectiva';
      case 'action_configure_reminder':
        return 'Configurar lembrete';
      case 'benefit_more_effective':
        return 'Mais eficaz';
      case 'benefit_better_adherence':
        return 'Melhor aderência';
      case 'benefit_more_consistent_results':
        return 'Resultados mais consistentes';
      case 'benefit_increase_motivation':
        return 'Aumentar motivação';
      case 'benefit_improve_results':
        return 'Melhorar resultados';
      case 'action_learn_technique':
        return 'Aprender técnica';
      case 'interest_meditation_title':
        return 'Nova técnica de meditação';
      case 'interest_meditation_description':
        return 'Explore esta nova técnica para enriquecer sua prática';
      case 'advanced_prediction':
        return 'Previsão Avançada';
      case 'prediction_updated':
        return 'Previsão atualizada';
      case 'refresh_prediction':
        return 'Atualizar previsão';
      case 'analyzing_patterns':
        return 'Analisando seus padrões...';
      case 'not_enough_data':
        return 'Dados insuficientes';
      case 'use_app_for_better_predictions':
        return 'Use o app com mais frequência para previsões melhores';
      case 'log_mood':
        return 'Registrar Humor';
      case 'trend':
        return 'Tendência';
      case 'confidence':
        return 'Confiança';
      case 'recommendation':
        return 'Recomendação';
      case 'identified_factors':
        return 'Fatores identificados';
      case 'next_week_prediction':
        return 'Previsão da próxima semana';
      case 'expected_mood':
        return 'Humor esperado';
      case 'view_detailed_analysis':
        return 'Ver Análise Detalhada';
      case 'rec_need_more_data':
        return 'Você precisa de mais dados para previsões precisas';
      case 'rec_mood_improving':
        return 'Seu humor está melhorando. Continue com atividades que te fazem bem!';
      case 'rec_mood_declining':
        return 'Notamos uma tendência de queda. Tente técnicas de relaxamento ou converse com alguém de confiança.';
      case 'rec_mood_stable':
        return 'Seu humor está estável. É um bom momento para explorar novas atividades de bem-estar.';
      case 'factor_positive_trend':
        return 'Tendência positiva nos últimos dias';
      case 'factor_negative_trend':
        return 'Tendência negativa nos últimos dias';
      case 'factor_stable_mood':
        return 'Humor estável';
      case 'factor_meditation_helps':
        return 'A meditação melhora seu humor';
      case 'factor_journaling_helps':
        return 'Escrever no diário ajuda a processar emoções';
      case 'factor_december_better':
        return 'Você tende a se sentir melhor em dezembro';
      case 'factor_january_better':
        return 'Você tende a se sentir melhor em janeiro';
      case 'average_1_5':
        return 'Média (1-5)';
      case 'consistency':
        return 'Consistência';
      case 'this_week':
        return 'Esta semana';
      case 'entries_this_week':
        return 'Entradas esta semana';
      case 'score_excellent':
        return 'Excelente';
      case 'score_good':
        return 'Bom';
      case 'score_fair':
        return 'Regular';
      case 'score_needs_improvement':
        return 'Precisa melhorar';
      case 'inhale':
        return 'Inspire';
      case 'hold':
        return 'Segure';
      case 'exhale':
        return 'Expire';
      case 'focus_on':
        return 'Foque em';
      case 'head':
        return 'Cabeça';
      case 'neck':
        return 'Pescoço';
      case 'shoulders':
        return 'Ombros';
      case 'arms':
        return 'Braços';
      case 'torso':
        return 'Torso';
      case 'legs':
        return 'Pernas';
      case 'feet':
        return 'Pés';
      case 'prompt_observe_breath':
        return 'Observe sua respiração';
      case 'prompt_listen_sounds':
        return 'Ouça os sons';
      case 'prompt_feel_body':
        return 'Sinta seu corpo';
      case 'prompt_notice_thoughts':
        return 'Perceba seus pensamentos e deixe-os passar';

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
      case 'skip':
        return 'Pular';

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
      case 'preferences':
        return 'Preferências';
      case 'haptics':
        return 'Vibração';
      case 'sound':
        return 'Som';

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
      case 'smart_analysis':
        return 'Análise Inteligente';
      case 'quick_summary':
        return 'Resumo Rápido';
      case 'analysis_updated':
        return 'Análise atualizada';
      case 'refresh_analytics':
        return 'Atualizar análise';
      case 'analyzing_data':
        return 'Analisando seus dados...';
      case 'correlations':
        return 'Correlações';
      case 'patterns':
        return 'Padrões';
      case 'progress':
        return 'Progresso';
      case 'wellness':
        return 'Bem-estar';
      case 'identified_correlations':
        return 'Correlações Identificadas';
      case 'view_complete_analysis':
        return 'Ver Análise Completa';
      case 'temporal_patterns':
        return 'Padrões Temporais';
      case 'best_days':
        return 'Melhores Dias';
      case 'best_hours':
        return 'Melhores Horas';
      case 'seasonal_patterns':
        return 'Padrões Sazonais';
      case 'progress_analysis':
        return 'Análise de Progresso';
      case 'overall_progress':
        return 'Progresso Geral';
      case 'recent_achievements':
        return 'Conquistas Recentes';
      case 'wellness_analysis':
        return 'Análise de Bem-estar';
      case 'risk_factors':
        return 'Fatores de Risco';
      case 'protective_factors':
        return 'Fatores Protetivos';
      case 'detailed_analysis':
        return 'Análise Detalhada';
      case 'found_correlations':
        return 'Correlações Encontradas';
      case 'not_enough_data_detailed':
        return 'Dados insuficientes para mostrar análise detalhada.';
      case 'usage':
        return 'Uso';
      case 'schedule':
        return 'Horário';
      // Insights de correlação
      case 'insight_meditation_positive':
        return 'A meditação tem um impacto positivo no seu humor';
      case 'insight_journal_emotions':
        return 'Escrever no seu diário ajuda a processar emoções';
      case 'insight_app_usage_wellness':
        return 'O uso frequente do app melhora seu bem-estar geral';
      case 'insight_specific_schedules':
        return 'Você tem horários específicos em que se sente melhor';
      // Padrões sazonais
      case 'feel_better_in':
        return 'Você se sente melhor em';
      // Conquistas
      case 'achievement_mood_improvement':
        return 'Melhoria do humor';
      case 'achievement_meditation_consistency':
        return 'Maior consistência na meditação';
      case 'achievement_journal_activity':
        return 'Mais atividade no diário';
      // Fatores de risco
      case 'risk_recent_low_mood':
        return 'Humor baixo recente';
      case 'risk_low_meditation_frequency':
        return 'Baixa frequência de meditação';
      case 'risk_low_journal_activity':
        return 'Pouca atividade no diário';
      // Fatores protetivos
      case 'protective_regular_meditation':
        return 'Prática regular de meditação';
      case 'protective_regular_journaling':
        return 'Reflexão regular no diário';
      case 'protective_positive_mood':
        return 'Humor geralmente positivo';

      default:
        return key;
    }
  }
}
