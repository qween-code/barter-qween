import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service for handling location operations
class LocationService {
  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permissions
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

      // Get position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Convert coordinates to address
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      return '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'
          .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Open app settings for permission
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
