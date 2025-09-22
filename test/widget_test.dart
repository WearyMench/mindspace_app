// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mindspace_app/main.dart';
import 'package:mindspace_app/services/language_service.dart';
import 'package:mindspace_app/services/theme_service.dart';

void main() {
  testWidgets('MindSpace app smoke test', (WidgetTester tester) async {
    // Create mock services
    final languageService = LanguageService();
    final themeService = ThemeService();

    // Initialize services
    await languageService.initialize();
    await themeService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MindSpaceApp(
        languageService: languageService,
        themeService: themeService,
      ),
    );

    // Verify that the app loads with the home screen
    expect(find.text('Buenos días'), findsOneWidget);
    expect(find.text('¿Cómo te sientes hoy?'), findsOneWidget);
    expect(find.text('Acciones rápidas'), findsOneWidget);
  });
}
