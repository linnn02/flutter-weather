import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/search_bar_widget.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/weather_details_row.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/outfit_preview_card.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/domain/use_cases/outfit_advisor_use_case.dart';

Widget buildTestable(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

final _testWeather = WeatherModel(
  cityName: 'Алматы',
  countryCode: 'KZ',
  latitude: 43.25,
  longitude: 76.94,
  temperature: 22.0,
  feelsLike: 21.0,
  tempMin: 18.0,
  tempMax: 25.0,
  humidity: 55,
  windSpeed: 4.0,
  windDegree: 90,
  visibility: 10000,
  pressure: 1013,
  clouds: 10,
  weatherMain: 'Clear',
  weatherDescription: 'ясно',
  weatherIcon: '01d',
  sunrise: 1000000,
  sunset: 9999999999,
  timestamp: DateTime.now(),
);

void main() {
  group('SearchBarWidget', () {
    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(buildTestable(
        SearchBarWidget(onSearch: (_) {}),
      ));
      expect(find.text('Поиск города...'), findsOneWidget);
    });

    testWidgets('calls onSearch when text submitted', (tester) async {
      String? searched;
      await tester.pumpWidget(buildTestable(
        SearchBarWidget(onSearch: (city) => searched = city),
      ));
      await tester.enterText(find.byType(TextField), 'Москва');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(searched, 'Москва');
    });

    testWidgets('shows action button when text entered', (tester) async {
      await tester.pumpWidget(buildTestable(
        SearchBarWidget(onSearch: (_) {}),
      ));
      await tester.enterText(find.byType(TextField), 'Астана');
      await tester.pump();
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });
  });

  group('WeatherDetailsRow', () {
    testWidgets('shows humidity value', (tester) async {
      await tester.pumpWidget(buildTestable(
        WeatherDetailsRow(weather: _testWeather),
      ));
      expect(find.text('55%'), findsOneWidget);
    });

    testWidgets('shows wind speed', (tester) async {
      await tester.pumpWidget(buildTestable(
        WeatherDetailsRow(weather: _testWeather),
      ));
      expect(find.text('4.0 м/с'), findsOneWidget);
    });

    testWidgets('shows visibility in km', (tester) async {
      await tester.pumpWidget(buildTestable(
        WeatherDetailsRow(weather: _testWeather),
      ));
      expect(find.text('10.0 км'), findsOneWidget);
    });
  });

  group('OutfitPreviewCard', () {
    testWidgets('shows outfit summary', (tester) async {
      final outfit = OutfitAdvisorUseCase().getRecommendation(_testWeather);
      await tester.pumpWidget(buildTestable(
        OutfitPreviewCard(outfit: outfit),
      ));
      expect(find.text('РЕКОМЕНДАЦИЯ ПО ОДЕЖДЕ'), findsOneWidget);
      expect(find.text(outfit.summary), findsOneWidget);
    });

    testWidgets('shows emoji for first 3 items', (tester) async {
      final outfit = OutfitAdvisorUseCase().getRecommendation(_testWeather);
      await tester.pumpWidget(buildTestable(
        OutfitPreviewCard(outfit: outfit),
      ));
      for (final item in outfit.items.take(3)) {
        expect(find.text(item.emoji), findsOneWidget);
      }
    });
  });
}
