import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for local persistence using SharedPreferences
class LocalStorageService {
  late SharedPreferences _prefs;

  static const String _weatherCacheKey = 'cached_weather';
  static const String _forecastCacheKey = 'cached_forecast';
  static const String _favoritesKey = 'favorite_cities';
  static const String _themeModeKey = 'theme_mode';
  static const String _temperatureUnitKey = 'temp_unit';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _lastCityKey = 'last_city';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Weather Cache ────────────────────────────────────────────────────────

  Future<void> cacheWeather(String cityName, Map<String, dynamic> data) async {
    final key = '${_weatherCacheKey}_$cityName';
    await _prefs.setString(key, jsonEncode(data));
    await _prefs.setInt('${key}_time', DateTime.now().millisecondsSinceEpoch);
  }

  Map<String, dynamic>? getCachedWeather(String cityName) {
    final key = '${_weatherCacheKey}_$cityName';
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  bool isCacheValid(String cityName,
      {Duration maxAge = const Duration(minutes: 30)}) {
    final key = '${_weatherCacheKey}_$cityName';
    final time = _prefs.getInt('${key}_time');
    if (time == null) return false;
    final age = DateTime.now().millisecondsSinceEpoch - time;
    return age < maxAge.inMilliseconds;
  }

  Future<void> cacheForecast(
      String cityName, List<Map<String, dynamic>> data) async {
    final key = '${_forecastCacheKey}_$cityName';
    await _prefs.setString(key, jsonEncode(data));
  }

  List<Map<String, dynamic>>? getCachedForecast(String cityName) {
    final key = '${_forecastCacheKey}_$cityName';
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  // ─── Favorites ────────────────────────────────────────────────────────────

  List<String> getFavoriteCities() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addFavoriteCity(String cityName) async {
    final cities = getFavoriteCities();
    if (!cities.contains(cityName)) {
      cities.add(cityName);
      await _prefs.setStringList(_favoritesKey, cities);
    }
  }

  Future<void> removeFavoriteCity(String cityName) async {
    final cities = getFavoriteCities();
    cities.remove(cityName);
    await _prefs.setStringList(_favoritesKey, cities);
  }

  bool isFavorite(String cityName) {
    return getFavoriteCities().contains(cityName);
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  String getThemeMode() => _prefs.getString(_themeModeKey) ?? 'system';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  String getTemperatureUnit() =>
      _prefs.getString(_temperatureUnitKey) ?? 'celsius';

  Future<void> setTemperatureUnit(String unit) async {
    await _prefs.setString(_temperatureUnitKey, unit);
  }

  bool getNotificationsEnabled() =>
      _prefs.getBool(_notificationsEnabledKey) ?? true;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  String getNotificationTime() =>
      _prefs.getString(_notificationTimeKey) ?? '08:00';

  Future<void> setNotificationTime(String time) async {
    await _prefs.setString(_notificationTimeKey, time);
  }

  String? getLastCity() => _prefs.getString(_lastCityKey);

  Future<void> setLastCity(String cityName) async {
    await _prefs.setString(_lastCityKey, cityName);
  }
}
