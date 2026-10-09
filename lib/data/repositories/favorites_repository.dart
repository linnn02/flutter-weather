import 'package:weather_outfit_advisor/data/models/user_model.dart';
import 'package:weather_outfit_advisor/data/services/firestore_service.dart';
import 'package:weather_outfit_advisor/data/services/local_storage_service.dart';

/// Repository for managing favorite cities with Firestore cloud sync + local cache fallback
class FavoritesRepository {
  final LocalStorageService _localStorageService;
  final FirestoreService? _firestoreService;
  String? _currentUserId;

  FavoritesRepository({
    required LocalStorageService localStorageService,
    FirestoreService? firestoreService,
    String? currentUserId,
  })  : _localStorageService = localStorageService,
        _firestoreService = firestoreService,
        _currentUserId = currentUserId;

  /// Обновить текущего авторизованного пользователя
  void updateCurrentUser(String? uid) {
    _currentUserId = uid;
  }

  /// Получить список избранных городов (из локального хранилища)
  List<String> getFavorites() =>
      _localStorageService.getFavoriteCities(userId: _currentUserId);

  /// Загрузить и синхронизировать избранное из Firestore
  Future<List<String>> syncFromCloud() async {
    final uid = _currentUserId;
    final firestore = _firestoreService;
    if (uid != null && firestore != null) {
      try {
        final cloudFavs = await firestore.getFavorites(uid);
        // Получаем локальные данные именно этого пользователя
        final localList = _localStorageService.getFavoriteCities(userId: uid);
        final cloudCityNames = cloudFavs.map((f) => f.cityName).toList();

        // Добавляем оффлайн-города текущего пользователя в его облако
        for (final localCity in localList) {
          if (!cloudCityNames.contains(localCity)) {
            await firestore.addFavorite(
              uid,
              FavoriteCityModel(
                id: localCity.toLowerCase().replaceAll(' ', '_'),
                cityName: localCity,
              ),
            );
          }
        }

        // Обновляем локальный кэш пользователя объединенными данными
        final combined = {...cloudCityNames, ...localList}.toList();
        await _localStorageService.setFavoriteCities(combined, userId: uid);

        return combined;
      } catch (e) {
        // При ошибке облака или отсутствии интернета используем локальный кэш пользователя
        return _localStorageService.getFavoriteCities(userId: uid);
      }
    }
    return _localStorageService.getFavoriteCities(userId: _currentUserId);
  }

  /// Добавить город в избранное (локально + облако если авторизован)
  Future<void> addFavorite(String cityName, {double? lat, double? lon}) async {
    await _localStorageService.addFavoriteCity(cityName, userId: _currentUserId);

    final uid = _currentUserId;
    final firestore = _firestoreService;
    if (uid != null && firestore != null) {
      try {
        final model = FavoriteCityModel(
          id: cityName.toLowerCase().replaceAll(' ', '_'),
          cityName: cityName,
          latitude: lat,
          longitude: lon,
        );
        await firestore.addFavorite(uid, model);
      } catch (_) {
        // Ошибка сети не ломает локальное действие
      }
    }
  }

  /// Удалить город из избранного (локально + облако если авторизован)
  Future<void> removeFavorite(String cityName) async {
    await _localStorageService.removeFavoriteCity(cityName, userId: _currentUserId);

    final uid = _currentUserId;
    final firestore = _firestoreService;
    if (uid != null && firestore != null) {
      try {
        await firestore.removeFavorite(uid, cityName);
      } catch (_) {
        // Ошибка сети не ломает локальное действие
      }
    }
  }

  bool isFavorite(String cityName) =>
      _localStorageService.isFavorite(cityName, userId: _currentUserId);
}
