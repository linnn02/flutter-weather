import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weather_outfit_advisor/domain/models/forecast_model.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_glass_card.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';

/// Apple Weather Horizontal Hourly Forecast Strip in Frosted Glass Card
class IosHourlyForecastCard extends StatelessWidget {
  const IosHourlyForecastCard({
    super.key,
    required this.hourly,
    required this.settings,
    this.conditionSummary = 'В течение дня ожидается стабильная погода.',
  });

  final List<HourlyForecastModel> hourly;
  final SettingsViewModel settings;
  final String conditionSummary;

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    return IosGlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header summary text as in iOS Weather
          Text(
            conditionSummary,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1,
            thickness: 0.8,
          ),
          const SizedBox(height: 12),

          // Horizontal scroll of hours with Desktop/Mouse and Touch Drag enabled
          SizedBox(
            height: 104,
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: hourly.take(24).length,
                separatorBuilder: (_, __) => const SizedBox(width: 22),
                itemBuilder: (context, index) {
                  final item = hourly[index];
                  final isNow = index == 0;
                  final timeLabel =
                      isNow ? 'Сейчас' : DateFormat('HH').format(item.dateTime);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          color:
                              Colors.white.withValues(alpha: isNow ? 1.0 : 0.8),
                          fontSize: 14,
                          fontWeight: isNow ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      CachedNetworkImage(
                        imageUrl: item.iconUrl,
                        width: 32,
                        height: 32,
                        errorWidget: (_, __, ___) => const Icon(Icons.wb_sunny,
                            size: 28, color: Colors.white),
                      ),
                      if (item.precipitationProbability > 0.15)
                        Text(
                          '${(item.precipitationProbability * 100).round()}%',
                          style: const TextStyle(
                            color: Color(0xFF64D2FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        const SizedBox(height: 14),
                      Text(
                        settings.formatTemp(item.temperature),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
