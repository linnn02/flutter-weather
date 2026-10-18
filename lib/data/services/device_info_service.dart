import 'package:flutter/services.dart';

/// Service to call native Android/iOS platform code via MethodChannel.
/// Реализует Неделю 11: нативные возможности через Platform Channel.
/// Нативные погодные функции: проверка аппаратного GPS и тактильный отклик погоды.
class NativeWeatherToolsService {
  static const _channel =
      MethodChannel('com.example.weather_outfit_advisor/native_weather_tools');

  /// Check if GPS location sensor is active on device
  static Future<bool> isGpsLocationEnabled() async {
    try {
      final enabled = await _channel.invokeMethod<bool>('isGpsLocationEnabled');
      return enabled ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Trigger native haptic/vibration feedback for weather updates
  static Future<void> vibrateWeatherAlert() async {
    try {
      await _channel.invokeMethod<void>('vibrateWeatherAlert');
    } catch (_) {
      // Gracefully ignore on unsupported platforms
    }
  }

  /// Get device model string (e.g. "Samsung Galaxy S21").
  static Future<String?> getDeviceModel() async {
    try {
      return await _channel.invokeMethod<String>('getDeviceModel');
    } catch (_) {
      return null;
    }
  }
}
