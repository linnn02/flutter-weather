import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_outfit_advisor/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';
import 'package:weather_outfit_advisor/ui/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

/// Favorites / Cities list screen styled like Apple Weather City Management
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavoritesViewModel>();
    final settings = context.watch<SettingsViewModel>();

    final isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final titleColor = isDark ? Colors.white : const Color(0xFF000000);
    final subtextColor =
        isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF8E8E93);
    final addBtnBg = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.08);
    final addBtnIcon = isDark ? Colors.white : const Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // iOS Large Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Погода',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: addBtnBg,
                      ),
                      child: Icon(Icons.add, color: addBtnIcon, size: 20),
                    ),
                    onPressed: () => _showAddCityDialog(context, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: vm.favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_city_outlined,
                              size: 64,
                              color: subtextColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Список городов пуст',
                              style: TextStyle(
                                fontSize: 17,
                                color: subtextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Добавить город'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF2C74B3)
                                    : const Color(0xFF007AFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () =>
                                  _showAddCityDialog(context, isDark),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: isDark ? Colors.white : const Color(0xFF007AFF),
                        onRefresh: () async => vm.loadFavorites(),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: vm.favorites.length,
                          itemBuilder: (context, index) {
                            final city = vm.favorites[index];
                            final weather = vm.weatherCache[city];

                            final gradient = weather != null
                                ? AppTheme.getWeatherGradient(
                                    weather.weatherMain,
                                    weather.isDay,
                                    forceDark: isDark,
                                    forceLight: !isDark,
                                  )
                                : (isDark
                                    ? AppColors.darkSunnyGradient
                                    : AppColors.sunnyGradient);

                            return Dismissible(
                              key: Key(city),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3B30),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete,
                                    color: Colors.white, size: 28),
                              ),
                              onDismissed: (_) {
                                vm.removeFavorite(city);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$city удален из списка'),
                                    action: SnackBarAction(
                                      label: 'Отмена',
                                      onPressed: () => vm.addFavorite(city),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: gradient,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withValues(alpha: 0.3)
                                          : Colors.grey.withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      context
                                          .read<HomeViewModel>()
                                          .loadWeatherByCity(city);
                                      context.go('/home');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    city,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: -0.4,
                                                    ),
                                                  ),
                                                  Text(
                                                    weather != null
                                                        ? weather
                                                            .weatherDescription
                                                        : 'Загрузка...',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.85),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (weather != null)
                                                Text(
                                                  'Макс.: ${settings.formatTemp(weather.tempMax)}, Мин.: ${settings.formatTemp(weather.tempMin)}',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.85),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (weather != null)
                                            Text(
                                              settings.formatTemp(
                                                  weather.temperature),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 48,
                                                fontWeight: FontWeight.w200,
                                                letterSpacing: -1.0,
                                              ),
                                            )
                                          else
                                            const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCityDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Добавить город',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          cursorColor: isDark ? Colors.white : const Color(0xFF007AFF),
          decoration: InputDecoration(
            hintText: 'Название города...',
            hintStyle: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF2F2F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) {
            _addCity(context, controller.text);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFF2C74B3) : const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              _addCity(context, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _addCity(BuildContext context, String city) {
    final name = city.trim();
    if (name.isNotEmpty) {
      context.read<FavoritesViewModel>().addFavorite(name);
    }
  }
}
