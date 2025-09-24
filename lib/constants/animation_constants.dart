/// Constantes de animación para toda la aplicación
///
/// Este archivo centraliza todas las duraciones y configuraciones de animación
/// para mantener consistencia y facilitar ajustes futuros.

class AnimationConstants {
  // Duraciones balanceadas para mejor UX y elegancia
  static const int fastDuration = 200; // Para micro-interacciones
  static const int normalDuration = 300; // Para transiciones normales
  static const int mediumDuration = 400; // Para animaciones más complejas
  static const int slowDuration = 600; // Para animaciones especiales

  // Delays balanceados para secuencias
  static const int noDelay = 0;
  static const int shortDelay = 75;
  static const int mediumDelay = 150;
  static const int longDelay = 225;

  // Configuraciones de movimiento reducidas para menos distracción
  static const double subtleSlide = 0.05; // Movimiento muy sutil
  static const double normalSlide = 0.1; // Movimiento normal
  static const double mediumSlide = 0.15; // Movimiento más pronunciado

  // Escalas para animaciones de entrada
  static const double subtleScale = 0.98; // Escala muy sutil
  static const double normalScale = 0.95; // Escala normal
  static const double mediumScale = 0.9; // Escala más pronunciada

  // Configuraciones específicas por tipo de componente
  static const int headerAnimationDuration = normalDuration;
  static const int headerAnimationDelay = noDelay;
  static const double headerSlideDistance = normalSlide;

  static const int cardAnimationDuration = normalDuration;
  static const int cardAnimationDelay = shortDelay;
  static const double cardSlideDistance = subtleSlide;
  static const double cardScaleStart = normalScale;

  static const int buttonAnimationDuration = fastDuration;
  static const int buttonAnimationDelay = noDelay;

  static const int modalAnimationDuration = mediumDuration;
  static const int pageTransitionDuration = normalDuration;

  // Configuraciones de shimmer y efectos especiales
  static const int shimmerDuration = 1000; // Reducido de 2000ms
  static const int pulseAnimationDuration = 1500; // Para breathing animations

  // Curvas de animación recomendadas
  static const String defaultCurve = 'easeOut';
  static const String fastCurve = 'easeInOut';
  static const String bounceCurve = 'elasticOut';
}

/// Extensión para usar las constantes fácilmente con flutter_animate
extension AnimationConstantsExtension on int {
  Duration get ms => Duration(milliseconds: this);
}
