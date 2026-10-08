import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'package:weather_outfit_advisor/data/repositories/weather_repository.dart';
import 'package:weather_outfit_advisor/data/repositories/favorites_repository.dart';
import 'package:weather_outfit_advisor/data/repositories/auth_repository.dart';
import 'package:weather_outfit_advisor/data/repositories/user_repository.dart';
import 'package:weather_outfit_advisor/data/services/weather_api_service.dart';
import 'package:weather_outfit_advisor/data/services/local_storage_service.dart';
import 'package:weather_outfit_advisor/data/services/notification_service.dart';
import 'package:weather_outfit_advisor/data/services/location_service.dart';
import 'package:weather_outfit_advisor/data/services/auth_service.dart';
import 'package:weather_outfit_advisor/data/services/firestore_service.dart';
import 'package:weather_outfit_advisor/ui/core/theme/app_theme.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/forecast/view_models/forecast_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/auth/auth_view_model.dart';
import 'package:weather_outfit_advisor/ui/core/app_router.dart';
import 'package:weather_outfit_advisor/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase с официальными опциями
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase initialization notice: $e');
    }
  }

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    WeatherOutfitApp(
      localStorageService: localStorageService,
      notificationService: notificationService,
      isFirebaseInitialized: isFirebaseInitialized,
    ),
  );
}

class WeatherOutfitApp extends StatefulWidget {
  const WeatherOutfitApp({
    super.key,
    required this.localStorageService,
    required this.notificationService,
    this.isFirebaseInitialized = false,
  });

  final LocalStorageService localStorageService;
  final NotificationService notificationService;
  final bool isFirebaseInitialized;

  @override
  State<WeatherOutfitApp> createState() => _WeatherOutfitAppState();
}

class _WeatherOutfitAppState extends State<WeatherOutfitApp> {
  late final AuthService _authService;
  late final FirestoreService _firestoreService;
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final WeatherRepository _weatherRepository;
  late final FavoritesRepository _favoritesRepository;

  late final AuthViewModel _authViewModel;
  late final SettingsViewModel _settingsViewModel;
  late final HomeViewModel _homeViewModel;
  late final ForecastViewModel _forecastViewModel;
  late final FavoritesViewModel _favoritesViewModel;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _authService = AuthService();
    _firestoreService = FirestoreService();
    _authRepository = AuthRepository(authService: _authService);
    _userRepository = UserRepository(firestoreService: _firestoreService);

    final weatherApiService = WeatherApiService();
    final locationService = LocationService();

    _weatherRepository = WeatherRepository(
      apiService: weatherApiService,
      localStorageService: widget.localStorageService,
    );

    _favoritesRepository = FavoritesRepository(
      localStorageService: widget.localStorageService,
      firestoreService: _firestoreService,
      currentUserId: _authRepository.currentUser?.uid,
    );

    _authViewModel = AuthViewModel(
      authRepository: _authRepository,
      userRepository: _userRepository,
    );

    _settingsViewModel = SettingsViewModel(
      localStorageService: widget.localStorageService,
      notificationService: widget.notificationService,
      userRepository: _userRepository,
      currentUserId: _authRepository.currentUser?.uid,
    );

    _homeViewModel = HomeViewModel(
      weatherRepository: _weatherRepository,
      locationService: locationService,
    );

    _forecastViewModel = ForecastViewModel(
      weatherRepository: _weatherRepository,
    );

    _favoritesViewModel = FavoritesViewModel(
      favoritesRepository: _favoritesRepository,
      weatherRepository: _weatherRepository,
    );

    // Слушаем изменение авторизации для актуализации FavoritesRepository и SettingsViewModel
    _authViewModel.addListener(_handleAuthChange);

    // Создаем защищенный роутер с AuthState
    _router = AppRouter.createRouter(_authViewModel);
  }

  void _handleAuthChange() {
    final uid = _authViewModel.currentUser?.uid;
    _favoritesRepository.updateCurrentUser(uid);
    _settingsViewModel.updateCurrentUser(uid);
    _favoritesViewModel.reset();
    _favoritesViewModel.loadFavorites();
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_handleAuthChange);
    _authViewModel.dispose();
    _settingsViewModel.dispose();
    _homeViewModel.dispose();
    _forecastViewModel.dispose();
    _favoritesViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authViewModel),
        ChangeNotifierProvider.value(value: _settingsViewModel),
        ChangeNotifierProvider.value(value: _homeViewModel),
        ChangeNotifierProvider.value(value: _forecastViewModel),
        ChangeNotifierProvider.value(value: _favoritesViewModel),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Weather & Outfit Advisor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            routerConfig: _router,
            localizationsDelegates: const [
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
