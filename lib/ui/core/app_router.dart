import 'package:go_router/go_router.dart';
import 'package:weather_outfit_advisor/ui/features/home/views/home_screen.dart';
import 'package:weather_outfit_advisor/ui/features/forecast/views/forecast_screen.dart';
import 'package:weather_outfit_advisor/ui/features/outfit/views/outfit_screen.dart';
import 'package:weather_outfit_advisor/ui/features/map/views/map_screen.dart';
import 'package:weather_outfit_advisor/ui/features/favorites/views/favorites_screen.dart';
import 'package:weather_outfit_advisor/ui/features/settings/views/settings_screen.dart';
import 'package:weather_outfit_advisor/ui/core/views/main_shell.dart';

/// App routing configuration using go_router with shell navigation
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/forecast',
            name: 'forecast',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ForecastScreen(),
            ),
          ),
          GoRoute(
            path: '/outfit',
            name: 'outfit',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OutfitScreen(),
            ),
          ),
          GoRoute(
            path: '/map',
            name: 'map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapScreen(),
            ),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FavoritesScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
