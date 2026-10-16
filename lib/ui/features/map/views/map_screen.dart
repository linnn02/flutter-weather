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
  bool _isLoadingWeather = false;

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
          // Button: go to current location marker
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
                // Clear selected point when returning to current location
                setState(() => _selectedPoint = null);
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
                // Keep the selected point visible and show the bottom sheet
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
                  // Tapped point — stays until user taps elsewhere or clears
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

          // Loading overlay when fetching weather for tapped point
          if (_isLoadingWeather)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Legend
          Positioned(
            bottom: 76,
            left: 16,
            child: _MapLegend(isDark: isDark),
          ),

          // Hint at bottom when point selected (dismissible)
          if (_selectedPoint != null && !_isLoadingWeather)
            Positioned(
              bottom: 130,
              left: 16,
              right: 16,
              child: _SelectedPointBanner(
                point: _selectedPoint!,
                isDark: isDark,
                onClear: () => setState(() => _selectedPoint = null),
                onLoad: () => _loadWeatherForPoint(context, _selectedPoint!),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadWeatherForPoint(BuildContext context, LatLng point) async {
    setState(() => _isLoadingWeather = true);
    try {
      final homeVm = context.read<HomeViewModel>();
      await homeVm.loadWeatherByCoords(point.latitude, point.longitude);
      if (homeVm.weather != null && context.mounted) {
        context
            .read<ForecastViewModel>()
            .loadForecast(homeVm.weather!.cityName);
        setState(() {
          _selectedPoint = null;
          _isLoadingWeather = false;
        });
        context.go('/home');
      } else {
        setState(() => _isLoadingWeather = false);
      }
    } catch (_) {
      setState(() => _isLoadingWeather = false);
    }
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
      // Don't dismiss selected point when sheet closes — user can cancel or load
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
                    'Выбранная точка',
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
                'Широта: ${point.latitude.toStringAsFixed(4)}, '
                'Долгота: ${point.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _selectedPoint = null);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white70 : Colors.black54,
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon:
                          const Icon(Icons.cloud_download, color: Colors.white),
                      label: const Text(
                        'Загрузить погоду',
                        style: TextStyle(
                            fontSize: 15,
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
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _loadWeatherForPoint(context, point);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner shown at bottom of map when a point is selected
class _SelectedPointBanner extends StatelessWidget {
  const _SelectedPointBanner({
    required this.point,
    required this.isDark,
    required this.onClear,
    required this.onLoad,
  });

  final LatLng point;
  final bool isDark;
  final VoidCallback onClear;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.place, color: Color(0xFFFF3B30), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${point.latitude.toStringAsFixed(3)}, '
              '${point.longitude.toStringAsFixed(3)}',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onLoad,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF007AFF),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Погода', style: TextStyle(fontSize: 13)),
          ),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close,
              size: 18,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
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
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.place, color: Color(0xFFFF3B30), size: 16),
            const SizedBox(width: 4),
            Text(
              'Выбранная точка',
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
