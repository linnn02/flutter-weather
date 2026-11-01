import 'package:flutter/material.dart';
import 'package:weather_outfit_advisor/data/repositories/weather_repository.dart';
import 'package:weather_outfit_advisor/data/services/location_service.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/domain/use_cases/outfit_advisor_use_case.dart';

enum HomeState { initial, loading, success, error, offline }

/// ViewModel for the main home screen
class HomeViewModel extends ChangeNotifier {
  final WeatherRepository _weatherRepository;
  final LocationService _locationService;
  final OutfitAdvisorUseCase _outfitAdvisor = OutfitAdvisorUseCase();

  HomeViewModel({
    required WeatherRepository weatherRepository,
    required LocationService locationService,
  })  : _weatherRepository = weatherRepository,
        _locationService = locationService;

  HomeState _state = HomeState.initial;
  HomeState get state => _state;

  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  OutfitRecommendation? _outfit;
  OutfitRecommendation? get outfit => _outfit;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchCity = '';
  String get searchCity => _searchCity;

  /// Load weather for current GPS location.
  Future<void> loadWeatherByLocation() async {
    _setState(HomeState.loading);

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        // 1. Всегда запрашиваем погоду напрямую по координатам (OpenWeather гарантированно найдет точку)
        var weatherModel = await _weatherRepository.getCurrentWeatherByCoords(
          position.latitude,
          position.longitude,
        );

        // 2. Пробуем получить локальное имя города через обратный геокодинг, если оно есть
        final geocodedCity = await _locationService.getCityNameByCoords(
          position.latitude,
          position.longitude,
        );

        if (geocodedCity != null && geocodedCity.trim().isNotEmpty) {
          weatherModel = weatherModel.copyWith(cityName: geocodedCity.trim());
        }

        _weather = weatherModel;
        _outfit = _outfitAdvisor.getRecommendation(_weather!);
        _setState(HomeState.success);
      } else {
        // На десктопе Windows GPS датчик обычно отсутствует.
        final lastCity =
            _weatherRepository.getLastCachedWeather()?.cityName ?? 'Алматы';
        await loadWeatherByCity(lastCity);
      }
    } catch (e) {
      _tryLoadCached();
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Refresh — always re-detect location (does not use cached city)
  Future<void> refresh() async {
    await loadWeatherByLocation();
  }

  /// Load weather for specific coordinates
  Future<void> loadWeatherByCoords(double lat, double lon) async {
    _setState(HomeState.loading);

    try {
      // 1. Запрашиваем по координатам — это всегда успешно возвращает данные для любой точки Земли
      var weatherModel =
          await _weatherRepository.getCurrentWeatherByCoords(lat, lon);

      // 2. Если есть имя города из геокодинга, подставляем его
      final geocodedCity = await _locationService.getCityNameByCoords(lat, lon);
      if (geocodedCity != null && geocodedCity.trim().isNotEmpty) {
        weatherModel = weatherModel.copyWith(cityName: geocodedCity.trim());
      }

      _weather = weatherModel;
      _outfit = _outfitAdvisor.getRecommendation(_weather!);
      _setState(HomeState.success);
    } catch (e) {
      _tryLoadCached();
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Load weather for a specific city name
  Future<void> loadWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) return;
    _searchCity = cityName.trim();
    _setState(HomeState.loading);

    try {
      _weather = await _weatherRepository.getCurrentWeather(_searchCity);
      _outfit = _outfitAdvisor.getRecommendation(_weather!);
      _setState(HomeState.success);
    } catch (e) {
      // Try offline cache
      final cached = _weatherRepository.getLastCachedWeather();
      if (cached != null) {
        _weather = cached;
        _outfit = _outfitAdvisor.getRecommendation(_weather!);
        _setState(HomeState.offline);
      } else {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _setState(HomeState.error);
      }
    }
  }

  void _tryLoadCached() {
    final cached = _weatherRepository.getLastCachedWeather();
    if (cached != null) {
      _weather = cached;
      _outfit = _outfitAdvisor.getRecommendation(_weather!);
      _setState(HomeState.offline);
    } else {
      _setState(HomeState.error);
      _errorMessage = 'Не удалось получить данные. Проверьте интернет.';
    }
  }

  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
