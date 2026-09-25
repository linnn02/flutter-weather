import 'package:weather_outfit_advisor/data/services/weather_api_service.dart';
import 'package:weather_outfit_advisor/data/services/local_storage_service.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/domain/models/forecast_model.dart';

/// Repository — single source of truth for weather data
class WeatherRepository {
  final WeatherApiService _apiService;
  final LocalStorageService _localStorageService;

  WeatherRepository({
    required WeatherApiService apiService,
    required LocalStorageService localStorageService,
  })  : _apiService = apiService,
        _localStorageService = localStorageService;

  /// Get current weather, using cache when offline or cache is fresh
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    // Return fresh cache if available
    if (_localStorageService.isCacheValid(cityName)) {
      final cached = _localStorageService.getCachedWeather(cityName);
      if (cached != null) {
        return WeatherModel.fromJson(cached);
      }
    }

    try {
      final apiModel = await _apiService.fetchWeatherByCity(cityName);
      final json = apiModel.toJson();

      // Cache for offline use
      await _localStorageService.cacheWeather(cityName, json);
      await _localStorageService.setLastCity(cityName);

      return WeatherModel.fromJson(json);
    } catch (e) {
      // Fallback to stale cache
      final cached = _localStorageService.getCachedWeather(cityName);
      if (cached != null) {
        return WeatherModel.fromJson(cached);
      }
      rethrow;
    }
  }

  /// Get current weather by GPS coordinates
  Future<WeatherModel> getCurrentWeatherByCoords(
    double lat,
    double lon,
  ) async {
    final apiModel = await _apiService.fetchWeatherByCoords(lat, lon);
    final json = apiModel.toJson();
    final model = WeatherModel.fromJson(json);

    // Cache by resolved city name
    await _localStorageService.cacheWeather(model.cityName, json);
    await _localStorageService.setLastCity(model.cityName);

    return model;
  }

  /// Get hourly forecast for a city
  Future<List<HourlyForecastModel>> getHourlyForecast(
    String cityName,
  ) async {
    try {
      final apiModel = await _apiService.fetchForecastByCity(cityName);
      final hourly = apiModel.list
          .map(HourlyForecastModel.fromJson)
          .toList();

      // Cache forecast
      await _localStorageService.cacheForecast(
        cityName,
        apiModel.list,
      );

      return hourly;
    } catch (e) {
      final cached = _localStorageService.getCachedForecast(cityName);
      if (cached != null) {
        return cached.map(HourlyForecastModel.fromJson).toList();
      }
      rethrow;
    }
  }

  /// Get daily forecast aggregated from hourly data
  Future<List<DailyForecastModel>> getDailyForecast(
    String cityName,
  ) async {
    final hourly = await getHourlyForecast(cityName);
    return DailyForecastModel.fromHourlyList(hourly);
  }

  /// Get last cached weather (for offline mode)
  WeatherModel? getLastCachedWeather() {
    final lastCity = _localStorageService.getLastCity();
    if (lastCity == null) return null;
    final cached = _localStorageService.getCachedWeather(lastCity);
    if (cached == null) return null;
    return WeatherModel.fromJson(cached);
  }
}
