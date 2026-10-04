import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/domain/use_cases/outfit_advisor_use_case.dart';

void main() {
  late OutfitAdvisorUseCase useCase;

  setUp(() {
    useCase = OutfitAdvisorUseCase();
  });

  WeatherModel makeWeather({
    required double temp,
    String condition = 'Clear',
    double windSpeed = 0,
  }) {
    return WeatherModel(
      cityName: 'Test',
      countryCode: 'KZ',
      latitude: 0,
      longitude: 0,
      temperature: temp,
      feelsLike: temp,
      tempMin: temp - 2,
      tempMax: temp + 2,
      humidity: 50,
      windSpeed: windSpeed,
      windDegree: 0,
      visibility: 10000,
      pressure: 1013,
      clouds: 0,
      weatherMain: condition,
      weatherDescription: condition.toLowerCase(),
      weatherIcon: '01d',
      sunrise: 0,
      sunset: 9999999999,
      timestamp: DateTime.now(),
    );
  }

  group('OutfitAdvisorUseCase', () {
    test('returns hot outfit above 25°C', () {
      final outfit = useCase.getRecommendation(makeWeather(temp: 30));
      expect(outfit.category, OutfitCategory.hot);
      expect(outfit.items, isNotEmpty);
    });

    test('returns warm outfit at 22°C', () {
      final outfit = useCase.getRecommendation(makeWeather(temp: 22));
      expect(outfit.category, OutfitCategory.warm);
    });

    test('returns mild outfit at 15°C', () {
      final outfit = useCase.getRecommendation(makeWeather(temp: 15));
      expect(outfit.category, OutfitCategory.mild);
    });

    test('returns cool outfit at 7°C', () {
      final outfit = useCase.getRecommendation(makeWeather(temp: 7));
      expect(outfit.category, OutfitCategory.cool);
    });

    test('returns cold outfit at -5°C', () {
      final outfit = useCase.getRecommendation(makeWeather(temp: -5));
      expect(outfit.category, OutfitCategory.cold);
    });

    test('returns very cold outfit at -20°C', () {
      final outfit = useCase.getRecommendation(makeWeather(temp: -20));
      expect(outfit.category, OutfitCategory.veryCold);
    });

    test('returns rainy outfit for Rain condition', () {
      final outfit = useCase.getRecommendation(
        makeWeather(temp: 15, condition: 'Rain'),
      );
      expect(outfit.category, OutfitCategory.rainy);
      expect(
        outfit.items.any((i) => i.emoji == '☂️'),
        isTrue,
        reason: 'Should include umbrella for rain',
      );
    });

    test('returns stormy outfit for Thunderstorm', () {
      final outfit = useCase.getRecommendation(
        makeWeather(temp: 18, condition: 'Thunderstorm'),
      );
      expect(outfit.category, OutfitCategory.stormy);
    });

    test('returns snowy outfit for Snow condition', () {
      final outfit = useCase.getRecommendation(
        makeWeather(temp: -2, condition: 'Snow'),
      );
      expect(outfit.category, OutfitCategory.snowy);
    });

    test('all outfits have at least one item', () {
      final conditions = ['Clear', 'Clouds', 'Rain', 'Snow', 'Thunderstorm'];
      final temps = [-25.0, -5.0, 5.0, 15.0, 22.0, 30.0];

      for (final condition in conditions) {
        for (final temp in temps) {
          final outfit = useCase.getRecommendation(
            makeWeather(temp: temp, condition: condition),
          );
          expect(outfit.items, isNotEmpty,
              reason: 'No items for $condition at $temp°C');
        }
      }
    });

    test('all outfits have non-empty summary', () {
      final outfit = useCase.getRecommendation(makeWeather(temp: 20));
      expect(outfit.summary, isNotEmpty);
    });
  });
}
