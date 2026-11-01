import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service for device GPS location
class LocationService {
  Geocoding? _geocodingInstance;

  Geocoding? get _geocoding {
    // Geocoding is only supported on mobile platforms (Android, iOS)
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return null;
    }
    try {
      _geocodingInstance ??= Geocoding();
      return _geocodingInstance;
    } catch (_) {
      return null;
    }
  }

  /// Request permission and get current position
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// Get city name (not district/suburb) by coordinates using reverse geocoding.
  /// Returns the locality (город), then adminArea as fallback.
  Future<String?> getCityNameByCoords(double lat, double lon) async {
    try {
      final geocoder = _geocoding;
      if (geocoder == null) return null;

      final placemarks = await geocoder.placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      // locality = город, subAdministrativeArea = район/область
      // Prefer locality (actual city name) over district
      final city =
          p.locality?.isNotEmpty == true ? p.locality : p.administrativeArea;
      if (kDebugMode) {
        debugPrint(
          'Geocoding: locality=${p.locality}, subAdmin=${p.subAdministrativeArea}, '
          'admin=${p.administrativeArea} => city=$city',
        );
      }
      return city;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Reverse geocoding error: $e');
      }
      return null;
    }
  }
}
