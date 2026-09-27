import 'package:flutter/material.dart';
import 'package:weather_outfit_advisor/domain/models/weather_model.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_glass_card.dart';

/// 2x2 Grid of iOS Weather Metric Tiles
class WeatherDetailsRow extends StatelessWidget {
  const WeatherDetailsRow({super.key, required this.weather});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _IosMetricTile(
                icon: Icons.air,
                label: 'ВЕТЕР',
                value: '${weather.windSpeed.toStringAsFixed(1)} м/с',
                subtext: 'Порывы до ${(weather.windSpeed * 1.3).toStringAsFixed(1)} м/с',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _IosMetricTile(
                icon: Icons.water_drop,
                label: 'ВЛАЖНОСТЬ',
                value: '${weather.humidity}%',
                subtext: 'Точка росы сейчас ${(weather.temperature - ((100 - weather.humidity) / 5)).round()}°',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _IosMetricTile(
                icon: Icons.visibility,
                label: 'ВИДИМОСТЬ',
                value: '${(weather.visibility / 1000).toStringAsFixed(1)} км',
                subtext: weather.visibility >= 10000 ? 'Идеальная видимость' : 'Умеренная видимость',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _IosMetricTile(
                icon: Icons.speed,
                label: 'ДАВЛЕНИЕ',
                value: '${weather.pressure} гПа',
                subtext: 'Нормальное давление',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IosMetricTile extends StatelessWidget {
  const _IosMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtext,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    return IosGlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
