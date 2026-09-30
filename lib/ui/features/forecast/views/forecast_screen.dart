import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/forecast/view_models/forecast_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';
import 'package:weather_outfit_advisor/ui/core/theme/app_theme.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_hourly_forecast_card.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_daily_forecast_card.dart';

/// Forecast screen styled with iOS Apple Weather components
class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final city = context.read<HomeViewModel>().weather?.cityName ?? '';
      if (city.isNotEmpty) {
        context.read<ForecastViewModel>().loadForecast(city);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final vm = context.watch<ForecastViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final isForceDark = settings.themeMode == ThemeMode.dark;
    final isForceLight = settings.themeMode == ThemeMode.light;

    final gradient = homeVm.weather != null
        ? AppTheme.getWeatherGradient(
            homeVm.weather!.weatherMain,
            homeVm.weather!.isDay,
            forceDark: isForceDark,
            forceLight: isForceLight,
          )
        : (isForceDark ? AppColors.darkSunnyGradient : AppColors.sunnyGradient);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeVm.weather != null ? homeVm.weather!.cityName : 'Прогноз',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Подробный прогноз',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (vm.state == ForecastState.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              else if (vm.state == ForecastState.error)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      vm.errorMessage ?? 'Ошибка загрузки',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              else if (vm.state == ForecastState.success)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    child: Column(
                      children: [
                        // Hourly Forecast
                        IosHourlyForecastCard(
                          hourly: vm.hourlyForecast,
                          settings: settings,
                          conditionSummary: 'Почасовой график температуры и вероятности осадков на 24 часа.',
                        ),
                        const SizedBox(height: 14),

                        // Daily 5-day Forecast
                        IosDailyForecastCard(
                          daily: vm.dailyForecast,
                          settings: settings,
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Выберите город на главном экране',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
