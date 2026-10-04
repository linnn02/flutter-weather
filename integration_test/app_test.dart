// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weather_outfit_advisor/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches and shows bottom navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Bottom nav should be visible
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Прогноз'), findsOneWidget);
      expect(find.text('Одежда'), findsOneWidget);
      expect(find.text('Избранное'), findsOneWidget);
      expect(find.text('Настройки'), findsOneWidget);
    });

    testWidgets('Navigation between tabs works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Forecast
      await tester.tap(find.text('Прогноз'));
      await tester.pumpAndSettle();
      expect(find.text('Прогноз погоды'), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.text('Настройки'));
      await tester.pumpAndSettle();
      expect(find.text('Настройки'), findsWidgets);

      // Navigate to Favorites
      await tester.tap(find.text('Избранное'));
      await tester.pumpAndSettle();
      expect(find.text('Избранные города'), findsOneWidget);

      // Navigate back to Home
      await tester.tap(find.text('Главная'));
      await tester.pumpAndSettle();
    });

    testWidgets('Search bar is visible on home screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Поиск города...'), findsOneWidget);
    });

    testWidgets('Settings screen shows theme selector', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Настройки'));
      await tester.pumpAndSettle();

      expect(find.text('Светлая'), findsOneWidget);
      expect(find.text('Тёмная'), findsOneWidget);
      expect(find.text('Авто'), findsOneWidget);
    });

    testWidgets('Can toggle dark theme', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Настройки'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Тёмная'));
      await tester.pumpAndSettle();

      // Switch back
      await tester.tap(find.text('Светлая'));
      await tester.pumpAndSettle();
    });

    testWidgets('Favorites screen shows add button', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Избранное'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Can open add city dialog in favorites', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Избранное'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Добавить город'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
