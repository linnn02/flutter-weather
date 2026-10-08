import 'package:go_router/go_router.dart';
import 'package:weather_outfit_advisor/ui/features/auth/auth_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/auth/login_screen.dart';
import 'package:weather_outfit_advisor/ui/features/auth/register_screen.dart';
import 'package:weather_outfit_advisor/ui/features/home/views/home_screen.dart';
import 'package:weather_outfit_advisor/ui/features/forecast/views/forecast_screen.dart';
import 'package:weather_outfit_advisor/ui/features/outfit/views/outfit_screen.dart';
import 'package:weather_outfit_advisor/ui/features/map/views/map_screen.dart';
import 'package:weather_outfit_advisor/ui/features/favorites/views/favorites_screen.dart';
import 'package:weather_outfit_advisor/ui/features/settings/views/settings_screen.dart';
import 'package:weather_outfit_advisor/ui/core/views/main_shell.dart';

/// App routing configuration using go_router with auth state protection and shell navigation
class AppRouter {
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/home',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final loggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // Если пользователь не авторизован и не находится на экране авторизации/регистрации
        if (!authViewModel.isAuthenticated) {
          return loggingIn ? null : '/login';
        }

        // Если пользователь уже авторизован и пытается зайти на логин или регистрацию
        if (loggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
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
}
