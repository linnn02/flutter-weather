import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/domain/models/forecast_model.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
    final json = {
      'name': 'Алматы',
      'sys': {'country': 'KZ', 'sunrise': 1700000000, 'sunset': 1700050000},
      'coord': {'lat': 43.25, 'lon': 76.94},
      'main': {
        'temp': 15.0,
        'feels_like': 14.0,
        'temp_min': 10.0,
        'temp_max': 18.0,
        'humidity': 60,
        'pressure': 1013,
      },
      'wind': {'speed': 3.5, 'deg': 180},
      'visibility': 10000,
      'clouds': {'all': 20},
      'weather': [
        {'main': 'Clear', 'description': 'ясно', 'icon': '01d'}
      ],
    };

    test('fromJson parses correctly', () {
      final model = WeatherModel.fromJson(json);
      expect(model.cityName, 'Алматы');
      expect(model.countryCode, 'KZ');
      expect(model.temperature, 15.0);
      expect(model.humidity, 60);
      expect(model.weatherMain, 'Clear');
      expect(model.weatherDescription, 'ясно');
      expect(model.weatherIcon, '01d');
    });

    test('toJson roundtrip preserves data', () {
      final model = WeatherModel.fromJson(json);
      final json2 = model.toJson();
      final model2 = WeatherModel.fromJson(json2);
      expect(model2.cityName, model.cityName);
      expect(model2.temperature, model.temperature);
      expect(model2.weatherMain, model.weatherMain);
    });

    test('iconUrl is correct', () {
      final model = WeatherModel.fromJson(json);
      expect(
        model.iconUrl,
        'https://openweathermap.org/img/wn/01d@2x.png',
      );
    });

    test('isDay returns true during day', () {
      final model = WeatherModel.fromJson({
        ...json,
        'sys': {
          'country': 'KZ',
          'sunrise': 1000,
          'sunset': 9999999999,
        },
      });
      // Since now is between 1000 and 9999999999 epoch seconds
      expect(model.isDay, isTrue);
    });

    test('fromJson handles missing fields gracefully', () {
      final model = WeatherModel.fromJson({});
      expect(model.cityName, '');
      expect(model.temperature, 0.0);
      expect(model.weatherIcon, '01d');
    });
  });

  group('HourlyForecastModel', () {
    final hourlyJson = {
      'dt': 1700000000,
      'main': {
        'temp': 12.0,
        'feels_like': 11.0,
        'humidity': 70,
      },
      'weather': [
        {'main': 'Rain', 'description': 'дождь', 'icon': '10d'}
      ],
      'wind': {'speed': 5.0},
      'pop': 0.7,
    };

    test('fromJson parses dateTime correctly', () {
      final model = HourlyForecastModel.fromJson(hourlyJson);
      expect(
        model.dateTime.millisecondsSinceEpoch,
        1700000000 * 1000,
      );
      expect(model.temperature, 12.0);
      expect(model.precipitationProbability, 0.7);
      expect(model.weatherMain, 'Rain');
    });

    test('iconUrl is correct', () {
      final model = HourlyForecastModel.fromJson(hourlyJson);
      expect(model.iconUrl, 'https://openweathermap.org/img/wn/10d@2x.png');
    });
  });

  group('DailyForecastModel', () {
    HourlyForecastModel makeHourly(int hour, double temp) {
      return HourlyForecastModel.fromJson({
        'dt': DateTime(2024, 1, 15, hour).millisecondsSinceEpoch ~/ 1000,
        'main': {'temp': temp, 'feels_like': temp, 'humidity': 60},
        'weather': [
          {'main': 'Clear', 'description': 'ясно', 'icon': '01d'}
        ],
        'wind': {'speed': 2.0},
        'pop': 0.0,
      });
    }

    test('fromHourlyList groups by day', () {
      final hourly = [
        makeHourly(9, 15.0),
        makeHourly(12, 18.0),
        makeHourly(15, 20.0),
        makeHourly(18, 17.0),
      ];
      final daily = DailyForecastModel.fromHourlyList(hourly);
      expect(daily.length, 1);
      expect(daily.first.tempMax, 20.0);
      expect(daily.first.tempMin, 15.0);
    });
  });
}
