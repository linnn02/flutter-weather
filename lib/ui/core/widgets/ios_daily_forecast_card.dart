import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weather_outfit_advisor/domain/models/forecast_model.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_glass_card.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';

/// Apple Weather 10-day (5-day in OWM) forecast card with colored temp range bars
class IosDailyForecastCard extends StatelessWidget {
  const IosDailyForecastCard({
    super.key,
    required this.daily,
    required this.settings,
  });

  final List<DailyForecastModel> daily;
  final SettingsViewModel settings;

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    // Find global min and max across all days to normalize horizontal gradient bars
    double globalMin = daily.map((d) => d.tempMin).reduce((a, b) => a < b ? a : b);
    double globalMax = daily.map((d) => d.tempMax).reduce((a, b) => a > b ? a : b);
    if (globalMax == globalMin) globalMax += 1;

    return IosGlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 6),
              Text(
                'ПРОГНОЗ НА 5 ДНЕЙ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1,
            thickness: 0.8,
          ),
          const SizedBox(height: 6),

          ...daily.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isToday = idx == 0;
            final dayTitle = isToday
                ? 'Сегодня'
                : DateFormat('EEE', 'ru').format(item.date).toUpperCase();

            // Calculate range bar offsets (0.0 to 1.0)
            final leftPercent = ((item.tempMin - globalMin) / (globalMax - globalMin)).clamp(0.0, 0.8);
            final rightPercent = ((item.tempMax - globalMin) / (globalMax - globalMin)).clamp(0.2, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  // Day Name
                  SizedBox(
                    width: 72,
                    child: Text(
                      dayTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Weather Icon
                  CachedNetworkImage(
                    imageUrl: item.iconUrl,
                    width: 28,
                    height: 28,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.wb_sunny, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 14),

                  // Min Temp
                  SizedBox(
                    width: 38,
                    child: Text(
                      settings.formatTemp(item.tempMin),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // iOS Horizontal Temperature Range Bar
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth;
                          final left = barWidth * leftPercent;
                          final width = (barWidth * (rightPercent - leftPercent)).clamp(8.0, barWidth);

                          return Stack(
                            children: [
                              Positioned(
                                left: left,
                                width: width,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF5AC8FA),
                                        Color(0xFFFFCC00),
                                        Color(0xFFFF9500),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Max Temp
                  SizedBox(
                    width: 38,
                    child: Text(
                      settings.formatTemp(item.tempMax),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
