import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/data/repositories/weather_repository.dart';
import 'package:weather_outfit_advisor/data/services/location_service.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/domain/models/forecast_model.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:geolocator/geolocator.dart';

// Manual Fake for WeatherRepository to run anywhere without code generation
class FakeWeatherRepository implements WeatherRepository {
  WeatherModel? currentWeatherToReturn;
  WeatherModel? lastCachedToReturn;
  bool shouldThrow = false;

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    if (shouldThrow) throw Exception('Нет соединения');
    return currentWeatherToReturn!;
  }

  @override
  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon) async {
    if (shouldThrow) throw Exception('Нет соединения');
    return currentWeatherToReturn!;
  }

  @override
  Future<List<HourlyForecastModel>> getHourlyForecast(String cityName) async => [];

  @override
  Future<List<DailyForecastModel>> getDailyForecast(String cityName) async => [];

  @override
  WeatherModel? getLastCachedWeather() => lastCachedToReturn;
}

// Manual Fake for LocationService
class FakeLocationService implements LocationService {
  Position? positionToReturn;

  @override
  Future<Position?> getCurrentPosition() async => positionToReturn;

  @override
  Future<bool> hasPermission() async => true;
}

void main() {
  late FakeWeatherRepository fakeRepo;
  late FakeLocationService fakeLocation;
  late HomeViewModel vm;

  final testWeather = WeatherModel(
    cityName: 'Алматы',
    countryCode: 'KZ',
    latitude: 43.25,
    longitude: 76.94,
    temperature: 15.0,
    feelsLike: 14.0,
    tempMin: 10.0,
    tempMax: 18.0,
    humidity: 60,
    windSpeed: 3.5,
    windDegree: 180,
    visibility: 10000,
    pressure: 1013,
    clouds: 20,
    weatherMain: 'Clear',
    weatherDescription: 'ясно',
    weatherIcon: '01d',
    sunrise: 1000000,
    sunset: 9999999,
    timestamp: DateTime.now(),
  );

  setUp(() {
    fakeRepo = FakeWeatherRepository();
    fakeLocation = FakeLocationService();
    vm = HomeViewModel(
      weatherRepository: fakeRepo,
      locationService: fakeLocation,
    );
  });

  group('HomeViewModel', () {
    test('initial state is HomeState.initial', () {
      expect(vm.state, HomeState.initial);
      expect(vm.weather, isNull);
    });

    test('loadWeatherByCity sets success state on success', () async {
      fakeRepo.currentWeatherToReturn = testWeather;

      await vm.loadWeatherByCity('Алматы');

      expect(vm.state, HomeState.success);
      expect(vm.weather, isNotNull);
      expect(vm.weather!.cityName, 'Алматы');
      expect(vm.outfit, isNotNull);
    });

    test('loadWeatherByCity sets error state on failure', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.lastCachedToReturn = null;

      await vm.loadWeatherByCity('InvalidCity');

      expect(vm.state, HomeState.error);
      expect(vm.errorMessage, isNotNull);
    });

    test('loadWeatherByCity uses offline cache on network error', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.lastCachedToReturn = testWeather;

      await vm.loadWeatherByCity('Алматы');

      expect(vm.state, HomeState.offline);
      expect(vm.weather, isNotNull);
    });

    test('loadWeatherByLocation uses GPS coords', () async {
      final position = Position(
        latitude: 43.25,
        longitude: 76.94,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      fakeLocation.positionToReturn = position;
      fakeRepo.currentWeatherToReturn = testWeather;

      await vm.loadWeatherByLocation();

      expect(vm.state, HomeState.success);
      expect(vm.weather!.cityName, 'Алматы');
    });

    test('outfit is generated after successful weather load', () async {
      fakeRepo.currentWeatherToReturn = testWeather;

      await vm.loadWeatherByCity('Алматы');

      expect(vm.outfit, isNotNull);
      expect(vm.outfit!.items, isNotEmpty);
    });

    test('clearError resets errorMessage', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.lastCachedToReturn = null;
      await vm.loadWeatherByCity('X');
      expect(vm.errorMessage, isNotNull);

      vm.clearError();
      expect(vm.errorMessage, isNull);
    });
  });
}
