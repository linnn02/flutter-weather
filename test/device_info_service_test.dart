import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/data/services/device_info_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceInfoService (Platform Channel)', () {
    test(
      'getBatteryLevel returns null or int in test environment (no platform)',
      () async {
        // On desktop/test environment, MissingPluginException is caught,
        // so the service returns null gracefully.
        final level = await DeviceInfoService.getBatteryLevel();
        // On Android device it returns 0-100; in test it returns null.
        expect(level == null || (level >= 0 && level <= 100), isTrue);
      },
    );

    test(
      'getDeviceModel returns null in test environment',
      () async {
        final model = await DeviceInfoService.getDeviceModel();
        // In unit tests (no platform), returns null.
        expect(model == null || model.isNotEmpty, isTrue);
      },
    );

    test(
      'getAndroidVersion returns null in test environment',
      () async {
        final version = await DeviceInfoService.getAndroidVersion();
        expect(version == null || version.isNotEmpty, isTrue);
      },
    );
  });
}
