import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';

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

    final currentWeather = homeVm.weather;
    final center = currentWeather != null
        ? LatLng(currentWeather.latitude, currentWeather.longitude)
        : const LatLng(43.25, 76.94); // Default: Almaty

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта погоды'),
        actions: [
          if (currentWeather != null)
            IconButton(
              icon: const Icon(Icons.my_location),
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
                _showLocationWeatherSheet(context, point, settings);
              },
            ),
            children: [
              // OSM tiles
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.weatheroutfit.weather_outfit_advisor',
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
                      width: 80,
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
                      width: 70,
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
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Legend
          Positioned(
            bottom: 16,
            left: 16,
            child: _MapLegend(),
          ),
        ],
      ),
    );
  }

  void _showLocationWeatherSheet(
    BuildContext context,
    LatLng point,
    SettingsViewModel settings,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Координаты: ${point.latitude.toStringAsFixed(4)}, '
              '${point.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Нажмите кнопку ниже, чтобы загрузить погоду здесь'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_download_outlined),
                label: const Text('Загрузить погоду'),
                onPressed: () {
                  Navigator.pop(context);
                  context.read<HomeViewModel>().loadWeatherByCity(
                        '${point.latitude.toStringAsFixed(2)}'
                        ',${point.longitude.toStringAsFixed(2)}',
                      );
                },
              ),
            ),
          ],
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
        color: isPrimary ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.location_on, color: Colors.blue, size: 16),
            SizedBox(width: 4),
            Text('Текущий город', style: TextStyle(fontSize: 12)),
          ]),
          SizedBox(height: 4),
          Row(children: [
            Icon(Icons.location_on, color: Colors.grey, size: 16),
            SizedBox(width: 4),
            Text('Избранные', style: TextStyle(fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}
