import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/data/services/device_info_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeWeatherToolsService (Platform Channel)', () {
    test(
      'isGpsLocationEnabled returns boolean safely in test environment',
      () async {
        final isGps = await NativeWeatherToolsService.isGpsLocationEnabled();
        expect(isGps, isFalse);
      },
    );

    test(
      'vibrateWeatherAlert runs without error in test environment',
      () async {
        expect(
          () => NativeWeatherToolsService.vibrateWeatherAlert(),
          returnsNormally,
        );
      },
    );

    test(
      'getDeviceModel returns null or string in test environment',
      () async {
        final model = await NativeWeatherToolsService.getDeviceModel();
        expect(model == null || model.isNotEmpty, isTrue);
      },
    );
  });
}
