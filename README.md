# MindSpace

Aplicacion movil orientada al seguimiento del estado de animo, meditacion guiada y registro personal.

![MindSpace Logo](https://via.placeholder.com/200x200/6B46C1/FFFFFF?text=MS)

## Descripcion

MindSpace reune herramientas de bienestar personal en una sola aplicacion. El proyecto incluye funciones para registrar estados de animo, consultar metricas basicas, realizar sesiones de meditacion y guardar entradas de diario.

## Caracteristicas principales

### Seguimiento del estado de animo

- Registro diario del estado emocional
- Categorizacion por indicadores como energia, estres y felicidad
- Visualizacion de tendencias y patrones
- Sistema de rachas

### Meditacion guiada

- Tipos de meditacion como mindfulness, respiracion y gratitud
- Diferentes niveles de dificultad
- Duracion configurable entre 5 y 30 minutos
- Seguimiento de progreso y estadisticas

### Diario digital

- Entradas categorizadas por tipo
- Etiquetas de estado de animo
- Busqueda y filtrado
- Prompts de escritura

### Analisis y estadisticas

- Panel con metricas principales
- Graficos de tendencias temporales
- Resumenes sobre patrones de bienestar
- Sistema de logros y rachas

## Diseno y UX

- Material Design 3 con tema personalizado
- Gradientes y paleta de colores suaves
- Animaciones con Flutter Animate
- Interfaz adaptada a uso diario
- Tema adaptativo

## Tecnologias utilizadas

- Flutter 3.8+
- Dart
- Provider
- Go Router
- Google Fonts
- Fl Chart
- SQLite
- Lottie

## Dependencias principales

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

## Instalacion y configuracion

### Prerrequisitos

- Flutter SDK 3.8 o superior
- Dart SDK 3.0 o superior
- Android Studio o VS Code
- Android SDK para Android
- Xcode para iOS

### Pasos de instalacion

1. Clonar el repositorio

   ```bash
   git clone https://github.com/tu-usuario/mindspace-app.git
   cd mindspace-app
   ```

2. Instalar dependencias

   ```bash
   flutter pub get
   ```

3. Configurar la aplicacion

- Actualizar `applicationId` en `android/app/build.gradle.kts`
- Configurar la firma digital para release
- Personalizar iconos y splash screen

4. Ejecutar la aplicacion

   ```bash
   flutter run
   ```

## Compilacion para produccion

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

## Estado del proyecto

### Implementado

- [x] Arquitectura base de la aplicacion
- [x] Navegacion con bottom navigation
- [x] Pantalla de inicio con acciones rapidas
- [x] Widgets reutilizables
- [x] Sistema de temas
- [x] Gestion de estado con Provider
- [x] Modelos de datos
- [x] Configuracion inicial para Play Store

### En desarrollo

- [ ] Pantallas detalladas de meditacion
- [ ] Editor de diario completo
- [ ] Seguimiento avanzado del estado de animo
- [ ] Sistema de notificaciones
- [ ] Sincronizacion en la nube
- [ ] Modo offline completo

## Estructura del proyecto

```text
lib/
|-- constants/          # Colores, temas y constantes
|-- models/             # Modelos de datos
|-- providers/          # Gestion de estado
|-- screens/            # Pantallas de la aplicacion
|-- widgets/            # Widgets reutilizables
|-- services/           # Servicios
`-- utils/              # Utilidades y helpers
```

## Paleta de colores

- Primario: purpura profundo (`#6B46C1`) a lavanda suave (`#9F7AEA`)
- Secundario: azul (`#3B82F6`) a verde azulado (`#14B8A6`)
- Acentos: naranja (`#F59E0B`) y rosa (`#EC4899`)
- Neutros: grises para texto y fondos

## Roadmap

### Version 1.1

- [ ] Meditaciones guiadas con audio
- [ ] Exportacion de datos
- [ ] Temas personalizables
- [ ] Widgets de escritorio

### Version 1.2

- [ ] Integracion con wearables
- [ ] Analisis de sueno
- [ ] Comunidad y compartir
- [ ] IA para insights personalizados

### Version 2.0

- [ ] Terapia cognitivo-conductual
- [ ] Coaching personalizado
- [ ] Integracion con profesionales
- [ ] Realidad virtual para meditacion

## Contribucion

Las contribuciones pueden enviarse mediante pull requests:

1. Crear un fork del proyecto
2. Crear una rama para el cambio
3. Realizar y confirmar los cambios
4. Enviar la rama al repositorio remoto
5. Abrir un pull request

## Licencia

Este proyecto se distribuye bajo la licencia MIT. Ver `LICENSE` para mas detalles.
