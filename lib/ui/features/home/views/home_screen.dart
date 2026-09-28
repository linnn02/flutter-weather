import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/forecast/view_models/forecast_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';
import 'package:weather_outfit_advisor/ui/core/theme/app_theme.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/weather_card.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/outfit_preview_card.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/search_bar_widget.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/weather_details_row.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/shimmer_loading.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_hourly_forecast_card.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_daily_forecast_card.dart';

/// Main home screen matching Apple iOS Weather app design
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeVm = context.read<HomeViewModel>();
      await homeVm.loadWeatherByLocation();
      if (!mounted) return;
      if (homeVm.weather != null) {
        context.read<ForecastViewModel>().loadForecast(homeVm.weather!.cityName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.watch<HomeViewModel>(),
      builder: (context, _) {
        final vm = context.read<HomeViewModel>();
        final forecastVm = context.watch<ForecastViewModel>();
        final settings = context.watch<SettingsViewModel>();

        final isForceDark = settings.themeMode == ThemeMode.dark;
        final isForceLight = settings.themeMode == ThemeMode.light;

        final gradient = vm.weather != null
            ? AppTheme.getWeatherGradient(
                vm.weather!.weatherMain,
                vm.weather!.isDay,
                forceDark: isForceDark,
                forceLight: isForceLight,
              )
            : (isForceDark ? AppColors.darkSunnyGradient : AppColors.sunnyGradient);

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradient,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                onRefresh: () async {
                  if (vm.weather != null) {
                    await vm.loadWeatherByCity(vm.weather!.cityName);
                    await forecastVm.loadForecast(vm.weather!.cityName);
                  } else {
                    await vm.loadWeatherByLocation();
                  }
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Search bar pinned or top
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: SearchBarWidget(
                          onSearch: (city) {
                            vm.loadWeatherByCity(city);
                            forecastVm.loadForecast(city);
                          },
                        ),
                      ),
                    ),

                    // Offline banner
                    if (vm.state == HomeState.offline)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: _OfflineBanner(),
                        ),
                      ),

                    // Loading State
                    if (vm.state == HomeState.loading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: ShimmerLoadingHome(),
                        ),
                      )
                    // Error State
                    else if (vm.state == HomeState.error)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ErrorView(
                          message: vm.errorMessage ?? 'Ошибка загрузки погоды',
                          onRetry: vm.loadWeatherByLocation,
                        ),
                      )
                    // Weather Content (Apple Weather Stack)
                    else if (vm.weather != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 28),

                              // 1. Hero City & Big Temperature
                              WeatherCard(
                                weather: vm.weather!,
                                settings: settings,
                              ),
                              const SizedBox(height: 36),

                              // 2. Hourly Forecast Strip (Apple style)
                              if (forecastVm.hourlyForecast.isNotEmpty) ...[
                                IosHourlyForecastCard(
                                  hourly: forecastVm.hourlyForecast,
                                  settings: settings,
                                  conditionSummary:
                                      'Сегодня ожидается ${vm.weather!.weatherDescription.toLowerCase()}, температура до ${settings.formatTemp(vm.weather!.tempMax)}.',
                                ),
                                const SizedBox(height: 12),
                              ],

                              // 3. 5-Day Forecast Card with Color Temp Bars
                              if (forecastVm.dailyForecast.isNotEmpty) ...[
                                IosDailyForecastCard(
                                  daily: forecastVm.dailyForecast,
                                  settings: settings,
                                ),
                                const SizedBox(height: 12),
                              ],

                              // 4. Outfit Recommendation Card
                              if (vm.outfit != null) ...[
                                OutfitPreviewCard(outfit: vm.outfit!),
                                const SizedBox(height: 12),
                              ],

                              // 5. 2x2 Metric Details Grid (Wind, Humidity, Visibility, Pressure)
                              WeatherDetailsRow(weather: vm.weather!),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9500).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Автономный режим — сохраненные данные',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2C74B3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
