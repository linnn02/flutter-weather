import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/data/repositories/weather_repository.dart';
import 'package:weather_outfit_advisor/domain/models/forecast_model.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/ui/features/forecast/view_models/forecast_view_model.dart';

class FakeWeatherForecastRepository implements WeatherRepository {
  List<HourlyForecastModel> hourlyToReturn = [];
  List<DailyForecastModel> dailyToReturn = [];
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async => throw UnimplementedError();

  @override
  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon) async => throw UnimplementedError();

  @override
  Future<List<HourlyForecastModel>> getHourlyForecast(String cityName) async {
    callCount++;
    if (shouldThrow) throw Exception('Network error');
    return hourlyToReturn;
  }

  @override
  Future<List<DailyForecastModel>> getDailyForecast(String cityName) async {
    if (shouldThrow) throw Exception('Network error');
    return dailyToReturn;
  }

  @override
  WeatherModel? getLastCachedWeather() => null;
}

void main() {
  late FakeWeatherForecastRepository fakeRepo;
  late ForecastViewModel vm;

  final testHourly = [
    HourlyForecastModel(
      dateTime: DateTime(2024, 1, 15, 12),
      temperature: 15.0,
      feelsLike: 14.0,
      precipitationProbability: 0.2,
      weatherMain: 'Clouds',
      weatherDescription: 'облачно',
      weatherIcon: '02d',
      windSpeed: 3.0,
      humidity: 60,
    ),
  ];

  final testDaily = DailyForecastModel.fromHourlyList(testHourly);

  setUp(() {
    fakeRepo = FakeWeatherForecastRepository();
    fakeRepo.hourlyToReturn = testHourly;
    fakeRepo.dailyToReturn = testDaily;
    vm = ForecastViewModel(weatherRepository: fakeRepo);
  });

  group('ForecastViewModel', () {
    test('initial state is ForecastState.initial', () {
      expect(vm.state, ForecastState.initial);
    });

    test('loadForecast sets success state', () async {
      await vm.loadForecast('Алматы');

      expect(vm.state, ForecastState.success);
      expect(vm.hourlyForecast, isNotEmpty);
      expect(vm.dailyForecast, isNotEmpty);
    });

    test('loadForecast sets error state on failure', () async {
      fakeRepo.shouldThrow = true;

      await vm.loadForecast('Unknown');

      expect(vm.state, ForecastState.error);
      expect(vm.errorMessage, isNotNull);
    });

    test('loadForecast does not re-fetch same city if already loaded', () async {
      await vm.loadForecast('Алматы');
      await vm.loadForecast('Алматы');

      expect(fakeRepo.callCount, 1);
    });
  });
}
