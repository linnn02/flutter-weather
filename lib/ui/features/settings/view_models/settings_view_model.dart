import 'package:flutter/material.dart';
import 'package:weather_outfit_advisor/data/services/local_storage_service.dart';
import 'package:weather_outfit_advisor/data/services/notification_service.dart';

/// ViewModel for app settings and preferences
class SettingsViewModel extends ChangeNotifier {
  final LocalStorageService _localStorageService;
  final NotificationService _notificationService;

  SettingsViewModel({
    required LocalStorageService localStorageService,
    required NotificationService notificationService,
  })  : _localStorageService = localStorageService,
        _notificationService = notificationService {
    _loadSettings();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _isCelsius = true;
  bool get isCelsius => _isCelsius;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay get notificationTime => _notificationTime;

  void _loadSettings() {
    final theme = _localStorageService.getThemeMode();
    _themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    _isCelsius =
        _localStorageService.getTemperatureUnit() == 'celsius';
    _notificationsEnabled =
        _localStorageService.getNotificationsEnabled();

    final timeStr = _localStorageService.getNotificationTime();
    final parts = timeStr.split(':');
    _notificationTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _localStorageService.setThemeMode(str);
    notifyListeners();
  }

  Future<void> setTemperatureUnit(bool isCelsius) async {
    _isCelsius = isCelsius;
    await _localStorageService.setTemperatureUnit(
      isCelsius ? 'celsius' : 'fahrenheit',
    );
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _localStorageService.setNotificationsEnabled(enabled);
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
