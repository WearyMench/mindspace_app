# MindSpace - Tu Espacio Mental Personal

![MindSpace Logo](https://via.placeholder.com/200x200/6B46C1/FFFFFF?text=MS)

## 📱 Descripción

MindSpace es una aplicación móvil innovadora diseñada para el bienestar mental y el crecimiento personal. Combina el seguimiento del estado de ánimo, meditación guiada y journaling digital en una experiencia cohesiva y moderna.

## ✨ Características Principales

### 🎯 Seguimiento del Estado de Ánimo

- Registro diario del estado emocional
- Categorización detallada (energía, estrés, felicidad, etc.)
- Visualización de tendencias y patrones
- Sistema de rachas para motivar la constancia

### 🧘 Meditación Guiada

- Múltiples tipos de meditación (mindfulness, respiración, gratitud, etc.)
- Diferentes niveles de dificultad
- Duración personalizable (5-30 minutos)
- Seguimiento de progreso y estadísticas

### 📝 Diario Digital

- Entradas categorizadas por tipo
- Etiquetas de estado de ánimo
- Búsqueda y filtrado avanzado
- Prompts de escritura para inspirar la reflexión

### 📊 Análisis y Estadísticas

- Dashboard personalizado con métricas clave
- Gráficos de tendencias temporales
- Insights sobre patrones de bienestar
- Sistema de logros y rachas

## 🎨 Diseño y UX

- **Material Design 3** con tema personalizado
- **Gradientes suaves** y colores calmantes
- **Animaciones fluidas** con Flutter Animate
- **Interfaz intuitiva** optimizada para uso diario
- **Tema adaptativo** que se ajusta al contexto

## 🛠️ Tecnologías Utilizadas

- **Flutter 3.8+** - Framework multiplataforma
- **Dart** - Lenguaje de programación
- **Provider** - Gestión de estado
- **Go Router** - Navegación
- **Google Fonts** - Tipografía
- **Fl Chart** - Visualización de datos
- **SQLite** - Almacenamiento local
- **Lottie** - Animaciones

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  go_router: ^14.2.7
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  fl_chart: ^0.69.0
  sqflite: ^2.3.3+1
  shared_preferences: ^2.2.3
  lottie: ^3.1.2
  glassmorphism: ^3.0.0
```

## 🚀 Instalación y Configuración

### Prerrequisitos

- Flutter SDK 3.8 o superior
- Dart SDK 3.0 o superior
- Android Studio / VS Code
- Android SDK (para Android)
- Xcode (para iOS)

### Pasos de Instalación

1. **Clonar el repositorio**

   ```bash
   git clone https://github.com/tu-usuario/mindspace-app.git
   cd mindspace-app
   ```

2. **Instalar dependencias**

   ```bash
   flutter pub get
   ```

3. **Configurar la aplicación**

   - Actualizar `applicationId` en `android/app/build.gradle.kts`
   - Configurar firma digital para release
   - Personalizar iconos y splash screen

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📱 Compilación para Producción

### Android (APK)

```bash
flutter build apk --release
```

### Android (AAB para Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🎯 Funcionalidades Implementadas

### ✅ Completado

- [x] Arquitectura base de la aplicación
- [x] Sistema de navegación con bottom navigation
- [x] Pantalla de inicio con acciones rápidas
- [x] Widgets reutilizables y modernos
- [x] Sistema de temas personalizado
- [x] Gestión de estado con Provider
- [x] Modelos de datos completos
- [x] Configuración para Play Store

### 🚧 En Desarrollo

- [ ] Pantallas detalladas de meditación
- [ ] Editor de diario completo
- [ ] Seguimiento avanzado del estado de ánimo
- [ ] Sistema de notificaciones
- [ ] Sincronización en la nube
- [ ] Modo offline completo

## 📊 Estructura del Proyecto

```
lib/
├── constants/          # Colores, temas y constantes
├── models/            # Modelos de datos
├── providers/         # Gestión de estado
├── screens/           # Pantallas de la aplicación
├── widgets/           # Widgets reutilizables
├── services/          # Servicios (base de datos, etc.)
└── utils/             # Utilidades y helpers
```

## 🎨 Paleta de Colores

- **Primario**: Púrpura profundo (#6B46C1) a lavanda suave (#9F7AEA)
- **Secundario**: Azul (#3B82F6) a verde azulado (#14B8A6)
- **Acentos**: Naranja (#F59E0B) y rosa (#EC4899)
- **Neutros**: Grises suaves para texto y fondos

## 📈 Roadmap

### Versión 1.1

- [ ] Meditaciones guiadas con audio
- [ ] Exportación de datos
- [ ] Temas personalizables
- [ ] Widgets de escritorio

### Versión 1.2

- [ ] Integración con wearables
- [ ] Análisis de sueño
- [ ] Comunidad y compartir
- [ ] IA para insights personalizados

### Versión 2.0

- [ ] Terapia cognitivo-conductual
- [ ] Coaching personalizado
- [ ] Integración con profesionales
- [ ] Realidad virtual para meditación

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 👨‍💻 Autor

Desarrollado con ❤️ para promover el bienestar mental y el crecimiento personal.

## 📞 Contacto

- Email: contacto@mindspace.app
- Website: https://mindspace.app
- Twitter: @MindSpaceApp

---

**MindSpace** - Donde tu bienestar mental encuentra su espacio perfecto. 🌟
