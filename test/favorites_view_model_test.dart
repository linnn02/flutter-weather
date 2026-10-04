import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/data/repositories/favorites_repository.dart';
import 'package:weather_outfit_advisor/data/repositories/weather_repository.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/domain/models/forecast_model.dart';
import 'package:weather_outfit_advisor/ui/features/favorites/view_models/favorites_view_model.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  List<String> favorites = [];

  @override
  List<String> getFavorites() => favorites;

  @override
  Future<void> addFavorite(String cityName) async {
    if (!favorites.contains(cityName)) favorites.add(cityName);
  }

  @override
  Future<void> removeFavorite(String cityName) async {
    favorites.remove(cityName);
  }

  @override
  bool isFavorite(String cityName) => favorites.contains(cityName);
}

class FakeFavoritesWeatherRepository implements WeatherRepository {
  WeatherModel? weatherToReturn;

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async =>
      weatherToReturn!;

  @override
  Future<WeatherModel> getCurrentWeatherByCoords(
          double lat, double lon) async =>
      throw UnimplementedError();

  @override
  Future<List<HourlyForecastModel>> getHourlyForecast(String cityName) async =>
      [];

  @override
  Future<List<DailyForecastModel>> getDailyForecast(String cityName) async =>
      [];

  @override
  WeatherModel? getLastCachedWeather() => null;
}

void main() {
  late FakeFavoritesRepository fakeFavRepo;
  late FakeFavoritesWeatherRepository fakeWeatherRepo;
  late FavoritesViewModel vm;

  final testWeather = WeatherModel(
    cityName: 'Москва',
    countryCode: 'RU',
    latitude: 55.75,
    longitude: 37.62,
    temperature: 5.0,
    feelsLike: 3.0,
    tempMin: 2.0,
    tempMax: 7.0,
    humidity: 80,
    windSpeed: 6.0,
    windDegree: 270,
    visibility: 8000,
    pressure: 1020,
    clouds: 80,
    weatherMain: 'Clouds',
    weatherDescription: 'облачно',
    weatherIcon: '04d',
    sunrise: 1000000,
    sunset: 9999999999,
    timestamp: DateTime.now(),
  );

  setUp(() {
    fakeFavRepo = FakeFavoritesRepository();
    fakeWeatherRepo = FakeFavoritesWeatherRepository();
    fakeWeatherRepo.weatherToReturn = testWeather;
    vm = FavoritesViewModel(
      favoritesRepository: fakeFavRepo,
      weatherRepository: fakeWeatherRepo,
    );
  });

  group('FavoritesViewModel', () {
    test('loadFavorites loads cities from repo', () {
      fakeFavRepo.favorites = ['Москва', 'Алматы'];

      vm.loadFavorites();

      expect(vm.favorites, ['Москва', 'Алматы']);
    });

    test('addFavorite adds city and reloads', () async {
      await vm.addFavorite('Берлин');

      expect(vm.favorites, contains('Берлин'));
    });

    test('removeFavorite removes city', () async {
      fakeFavRepo.favorites = ['Москва'];
      vm.loadFavorites();

      await vm.removeFavorite('Москва');

      expect(vm.favorites, isEmpty);
    });

    test('isFavorite delegates to repo', () {
      fakeFavRepo.favorites = ['Алматы'];

      expect(vm.isFavorite('Алматы'), isTrue);
      expect(vm.isFavorite('Токио'), isFalse);
    });
  });
}
