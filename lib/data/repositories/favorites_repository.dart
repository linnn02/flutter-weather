import 'package:weather_outfit_advisor/data/services/local_storage_service.dart';

/// Repository for managing favorite cities
class FavoritesRepository {
  final LocalStorageService _localStorageService;

  FavoritesRepository({required LocalStorageService localStorageService})
      : _localStorageService = localStorageService;

  List<String> getFavorites() => _localStorageService.getFavoriteCities();

  Future<void> addFavorite(String cityName) =>
      _localStorageService.addFavoriteCity(cityName);

  Future<void> removeFavorite(String cityName) =>
      _localStorageService.removeFavoriteCity(cityName);

  bool isFavorite(String cityName) => _localStorageService.isFavorite(cityName);
}
