import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:weather_outfit_advisor/data/repositories/weather_repository.dart';
import 'package:weather_outfit_advisor/data/repositories/favorites_repository.dart';
import 'package:weather_outfit_advisor/data/services/weather_api_service.dart';
import 'package:weather_outfit_advisor/data/services/local_storage_service.dart';
import 'package:weather_outfit_advisor/data/services/notification_service.dart';
import 'package:weather_outfit_advisor/data/services/location_service.dart';
import 'package:weather_outfit_advisor/ui/core/theme/app_theme.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/forecast/view_models/forecast_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';
import 'package:weather_outfit_advisor/ui/core/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    WeatherOutfitApp(
      localStorageService: localStorageService,
      notificationService: notificationService,
    ),
  );
}

class WeatherOutfitApp extends StatelessWidget {
  const WeatherOutfitApp({
    super.key,
    required this.localStorageService,
    required this.notificationService,
  });

  final LocalStorageService localStorageService;
  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    final weatherApiService = WeatherApiService();
    final locationService = LocationService();
    final weatherRepository = WeatherRepository(
      apiService: weatherApiService,
      localStorageService: localStorageService,
    );
    final favoritesRepository = FavoritesRepository(
      localStorageService: localStorageService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(
            localStorageService: localStorageService,
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            weatherRepository: weatherRepository,
            locationService: locationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ForecastViewModel(
            weatherRepository: weatherRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesViewModel(
            favoritesRepository: favoritesRepository,
            weatherRepository: weatherRepository,
          ),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Weather & Outfit Advisor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            routerConfig: AppRouter.router,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru', 'RU'),
              Locale('en', 'US'),
            ],
          );
        },
      ),
    );
  }
}
