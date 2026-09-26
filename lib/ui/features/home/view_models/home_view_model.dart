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

  /// Load weather for current GPS location
  Future<void> loadWeatherByLocation() async {
    _setState(HomeState.loading);

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _weather = await _weatherRepository.getCurrentWeatherByCoords(
          position.latitude,
          position.longitude,
        );
        _outfit = _outfitAdvisor.getRecommendation(_weather!);
        _setState(HomeState.success);
      } else {
        // Try last cached city
        _tryLoadCached();
      }
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
