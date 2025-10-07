import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MapService {
  GoogleMapController? _controller;

  MapService();

  void setMapController(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> initializeMap() async {
    // Initialization logic if needed
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<double> calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // in km
  }

  String getFormattedDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    }
    return '${distanceInKm.toStringAsFixed(1)}km';
  }

  /// Get full address from coordinates using reverse geocoding
  Future<String> getFullAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isEmpty) {
        return 'Unknown location';
      }
      
      final place = placemarks.first;
      final parts = <String>[];
      
      if (place.street != null && place.street!.isNotEmpty) {
        parts.add(place.street!);
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        parts.add(place.subLocality!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        parts.add(place.country!);
      }
      
      return parts.isEmpty ? 'Unknown location' : parts.join(', ');
    } catch (e) {
      return 'Unable to get address';
    }
  }

  /// Check if a point is within a radius from another point
  Future<bool> isWithinRadius(
    LatLng point1,
    LatLng point2,
    double radiusKm,
  ) async {
    final distance = Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
    
    final distanceKm = distance / 1000;
    return distanceKm <= radiusKm;
  }

  /// Animate camera to a new position
  Future<void> animateCamera(CameraPosition position) async {
    if (_controller == null) {
      throw Exception('Map controller not initialized');
    }
    
    await _controller!.animateCamera(
      CameraUpdate.newCameraPosition(position),
    );
  }

  /// Move camera to a target location
  Future<void> moveCamera(LatLng target, {double? zoom}) async {
    if (_controller == null) {
      throw Exception('Map controller not initialized');
    }
    
    await _controller!.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom ?? 14.0),
    );
  }

  List<dynamic> getSafeMeetupSuggestions(String city) {
    // TODO: Implement safe meetup suggestions from database
    return [];
  }
}