import 'package:flutter/material.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';

/// iOS-styled Weather Header: Minimalist City title, giant temperature, condition, H/L
class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
    required this.settings,
  });

  final WeatherModel weather;
  final SettingsViewModel settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // City Name (iOS SF Pro style)
        Text(
          weather.cityName.isNotEmpty ? weather.cityName : 'Текущее место',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),

        // Huge iOS Temperature
        Text(
          settings.formatTemp(weather.temperature),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 92,
            fontWeight: FontWeight.w200,
            letterSpacing: -2.0,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 4),

        // Weather Description
        Text(
          weather.weatherDescription.isNotEmpty
              ? weather.weatherDescription.substring(0, 1).toUpperCase() +
                  weather.weatherDescription.substring(1)
              : '',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        // High / Low temperatures (H: 24° L: 14°)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Макс.: ${settings.formatTemp(weather.tempMax)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Мин.: ${settings.formatTemp(weather.tempMin)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
