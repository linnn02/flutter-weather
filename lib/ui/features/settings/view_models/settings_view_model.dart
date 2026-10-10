import 'package:flutter/material.dart';
import 'package:weather_outfit_advisor/data/services/local_storage_service.dart';
import 'package:weather_outfit_advisor/data/services/notification_service.dart';
import 'package:weather_outfit_advisor/data/repositories/user_repository.dart';

/// ViewModel for app settings and preferences with Cloud Firestore synchronization
class SettingsViewModel extends ChangeNotifier {
  final LocalStorageService _localStorageService;
  final NotificationService _notificationService;
  final UserRepository? _userRepository;
  String? _currentUserId;

  SettingsViewModel({
    required LocalStorageService localStorageService,
    required NotificationService notificationService,
    UserRepository? userRepository,
    String? currentUserId,
  })  : _localStorageService = localStorageService,
        _notificationService = notificationService,
        _userRepository = userRepository,
        _currentUserId = currentUserId {
    _loadSettings();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _isCelsius = true;
  bool get isCelsius => _isCelsius;

  String _language = 'ru';
  String get language => _language;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay get notificationTime => _notificationTime;

  /// Обновить текущего пользователя и загрузить его настройки из Firestore
  void updateCurrentUser(String? uid) {
    _currentUserId = uid;
    if (uid != null) {
      loadSettingsFromCloud(uid);
    }
  }

  void _loadSettings() {
    final theme = _localStorageService.getThemeMode();
    _themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    _isCelsius = _localStorageService.getTemperatureUnit() == 'celsius';
    _language = _localStorageService.getLanguage();
    _notificationsEnabled = _localStorageService.getNotificationsEnabled();

    final timeStr = _localStorageService.getNotificationTime();
    final parts = timeStr.split(':');
    _notificationTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Загрузить настройки пользователя из Firestore и применить их в приложении
  Future<void> loadSettingsFromCloud(String uid) async {
    final repo = _userRepository;
    if (repo == null) return;
    try {
      final user = await repo.getUserProfile(uid);
      if (user != null) {
        // Тема
        _themeMode = switch (user.theme) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };
        await _localStorageService.setThemeMode(user.theme);

        // Температура
        _isCelsius = user.temperatureUnit == 'celsius';
        await _localStorageService.setTemperatureUnit(user.temperatureUnit);

        // Язык
        _language = user.language;
        await _localStorageService.setLanguage(user.language);

        // Уведомления
        _notificationsEnabled = user.notificationsEnabled;
        await _localStorageService.setNotificationsEnabled(user.notificationsEnabled);

        notifyListeners();
      }
    } catch (_) {
      // При ошибке соединения сохраняем локальные настройки
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _localStorageService.setThemeMode(str);
    _syncSettingToCloud({'theme': str});
    notifyListeners();
  }

  Future<void> setTemperatureUnit(bool isCelsius) async {
    _isCelsius = isCelsius;
    final unit = isCelsius ? 'celsius' : 'fahrenheit';
    await _localStorageService.setTemperatureUnit(unit);
    _syncSettingToCloud({'temperatureUnit': unit});
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _localStorageService.setLanguage(lang);
    _syncSettingToCloud({'language': lang});
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _localStorageService.setNotificationsEnabled(enabled);
    _syncSettingToCloud({'notificationsEnabled': enabled});
    if (!enabled) {
      await _notificationService.cancelAll();
    } else {
      await _scheduleNotification();
    }
    notifyListeners();
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    _notificationTime = time;
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _localStorageService.setNotificationTime(timeStr);
    if (_notificationsEnabled) {
      await _scheduleNotification();
    }
    notifyListeners();
  }

  void _syncSettingToCloud(Map<String, dynamic> data) {
    final uid = _currentUserId;
    final repo = _userRepository;
    if (uid != null && repo != null) {
      repo.updateUserSettings(uid, data).catchError((_) {});
    }
  }

  Future<void> _scheduleNotification() async {
    await _notificationService.scheduleDailyWeatherNotification(
      title: '🌤️ Прогноз погоды',
      body: 'Откройте приложение, чтобы узнать что одеть сегодня',
      hour: _notificationTime.hour,
      minute: _notificationTime.minute,
    );
  }

  double convertTemp(double celsius) {
    if (_isCelsius) return celsius;
    return celsius * 9 / 5 + 32;
  }

  String formatTemp(double celsius) {
    final value = convertTemp(celsius);
    final unit = _isCelsius ? '°C' : '°F';
    return '${value.round()}$unit';
  }
}
