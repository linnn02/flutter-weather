import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/forecast/view_models/forecast_view_model.dart';
import 'package:go_router/go_router.dart';

/// Map screen showing weather location on an interactive map
/// Uses flutter_map with OpenStreetMap tiles (free, no API key)
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final favVm = context.watch<FavoritesViewModel>();
    final settings = context.watch<SettingsViewModel>();

    final isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final currentWeather = homeVm.weather;
    final center = currentWeather != null
        ? LatLng(currentWeather.latitude, currentWeather.longitude)
        : const LatLng(43.25, 76.94); // Default: Almaty

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Карта погоды',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (currentWeather != null)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                child: Icon(Icons.my_location,
                    color: isDark ? Colors.white : const Color(0xFF007AFF),
                    size: 20),
              ),
              tooltip: 'Вернуться к текущему городу',
              onPressed: () {
                _mapController.move(center, 10);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 10,
              onTap: (tapPosition, point) {
                setState(() => _selectedPoint = point);
                _showLocationWeatherSheet(context, point, settings, isDark);
              },
            ),
            children: [
              // OSM tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.weatheroutfit.weather_outfit_advisor',
              ),
              // Markers for current + favorites
              MarkerLayer(
                markers: [
                  // Current city marker
                  if (currentWeather != null)
                    Marker(
                      point: LatLng(
                        currentWeather.latitude,
                        currentWeather.longitude,
                      ),
                      width: 84,
                      height: 60,
                      child: _WeatherMarker(
                        cityName: currentWeather.cityName,
                        temp: settings.formatTemp(currentWeather.temperature),
                        isPrimary: true,
                      ),
                    ),
                  // Favorites markers
                  ...favVm.weatherCache.values.map(
                    (w) => Marker(
                      point: LatLng(w.latitude, w.longitude),
                      width: 76,
                      height: 55,
                      child: _WeatherMarker(
                        cityName: w.cityName,
                        temp: settings.formatTemp(w.temperature),
                        isPrimary: false,
                      ),
                    ),
                  ),
                  // Tapped point
                  if (_selectedPoint != null)
                    Marker(
                      point: _selectedPoint!,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFFFF3B30),
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Legend
          Positioned(
            bottom: 76,
            left: 16,
            child: _MapLegend(isDark: isDark),
          ),
        ],
      ),
    );
  }

  void _showLocationWeatherSheet(
    BuildContext context,
    LatLng point,
    SettingsViewModel settings,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Color(0xFFFF3B30), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Координаты точки',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Широта: ${point.latitude.toStringAsFixed(4)}, Долгота: ${point.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_download, color: Colors.white),
                  label: const Text(
                    'Загрузить погоду в этой точке',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final homeVm = context.read<HomeViewModel>();
                    await homeVm.loadWeatherByCoords(
                        point.latitude, point.longitude);
                    if (homeVm.weather != null && context.mounted) {
                      context
                          .read<ForecastViewModel>()
                          .loadForecast(homeVm.weather!.cityName);
                      context.go('/home');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherMarker extends StatelessWidget {
  const _WeatherMarker({
    required this.cityName,
    required this.temp,
    required this.isPrimary,
  });

  final String cityName;
  final String temp;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF007AFF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            temp,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            cityName,
            style: TextStyle(
              fontSize: 10,
              color: isPrimary ? Colors.white70 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on, color: Color(0xFF007AFF), size: 16),
            const SizedBox(width: 4),
            Text(
              'Текущий город',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              'Избранные',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
