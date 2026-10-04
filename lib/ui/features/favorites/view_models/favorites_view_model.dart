import 'package:flutter/material.dart';
import 'package:weather_outfit_advisor/data/repositories/favorites_repository.dart';
import 'package:weather_outfit_advisor/data/repositories/weather_repository.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';

/// ViewModel for the favorites screen
class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _favoritesRepository;
  final WeatherRepository _weatherRepository;

  FavoritesViewModel({
    required FavoritesRepository favoritesRepository,
    required WeatherRepository weatherRepository,
  })  : _favoritesRepository = favoritesRepository,
        _weatherRepository = weatherRepository;

  List<String> _favorites = [];
  List<String> get favorites => List.unmodifiable(_favorites);

  final Map<String, WeatherModel> _weatherCache = {};
  Map<String, WeatherModel> get weatherCache => Map.unmodifiable(_weatherCache);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void loadFavorites() {
    _favorites = _favoritesRepository.getFavorites();
    notifyListeners();
    _loadWeatherForFavorites();
  }

  Future<void> _loadWeatherForFavorites() async {
    _isLoading = true;
    notifyListeners();

    for (final city in List<String>.of(_favorites)) {
      try {
        final weather = await _weatherRepository.getCurrentWeather(city);
        _weatherCache[city] = weather;
        notifyListeners();
      } catch (_) {
        // Ignore per-city errors
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(String cityName) async {
    await _favoritesRepository.addFavorite(cityName);
    _favorites = _favoritesRepository.getFavorites();
    notifyListeners();
    // Load weather for the new city
    try {
      final weather = await _weatherRepository.getCurrentWeather(cityName);
      _weatherCache[cityName] = weather;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> removeFavorite(String cityName) async {
    await _favoritesRepository.removeFavorite(cityName);
    _favorites = _favoritesRepository.getFavorites();
    _weatherCache.remove(cityName);
    notifyListeners();
  }

  bool isFavorite(String cityName) => _favoritesRepository.isFavorite(cityName);
}
