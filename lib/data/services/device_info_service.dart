import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to call native Android/iOS platform code via MethodChannel.
/// Реализует Неделю 11: нативные возможности через Platform Channel.
class DeviceInfoService {
  static const _channel =
      MethodChannel('com.example.weather_outfit_advisor/device_info');

  /// Get battery level (0–100). Returns null if unavailable.
  static Future<int?> getBatteryLevel() async {
    try {
      final level = await _channel.invokeMethod<int>('getBatteryLevel');
      return level;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Battery level error: ${e.message}');
      }
      return null;
    } on MissingPluginException {
      // Running on desktop/web — not supported
      return null;
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

  /// Get Android version string (e.g. "13").
  static Future<String?> getAndroidVersion() async {
    try {
      return await _channel.invokeMethod<String>('getAndroidVersion');
    } catch (_) {
      return null;
    }
  }
}
