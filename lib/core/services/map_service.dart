import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' show cos, sqrt, asin;

/// World-Class Map Service
/// Based on OfferUp & Facebook Marketplace best practices
class MapService {
  // ========================================
  // CURRENT LOCATION
  // ========================================
  
  /// Get current user location with proper error handling
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedForeverException();
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('❌ Error getting location: $e');
      rethrow;
    }
  }

  // ========================================
  // GEOCODING
  // ========================================
  
  /// Convert coordinates to full address
  Future<String?> getFullAddressFromCoordinates(
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
      
      // Build full address
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
      
      return parts.join(', ');
    } catch (e) {
      print('❌ Error geocoding: $e');
      return null;
    }
  }

  /// Convert coordinates to city name
  Future<String?> getCityFromCoordinates(
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
      return place.locality ?? place.administrativeArea;
    } catch (e) {
      print('❌ Error getting city: $e');
      return null;
    }
  }

  /// Convert address to coordinates (reverse geocoding)
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;
      return locations.first;
    } catch (e) {
      print('❌ Error reverse geocoding: $e');
      return null;
    }
  }

  // ========================================
  // DISTANCE CALCULATIONS
  // ========================================
  
  /// Calculate distance between two points in kilometers
  /// Uses Haversine formula for accuracy
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Calculate distance and return formatted string
  String getFormattedDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final distance = calculateDistance(lat1, lon1, lat2, lon2);
    
    if (distance < 1) {
      return '${(distance * 1000).round()} m uzaklıkta';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(1)} km uzaklıkta';
    } else {
      return '${distance.round()} km uzaklıkta';
    }
  }

  /// Check if point is within radius (in km)
  bool isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusKm,
  ) {
    final distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= radiusKm;
  }

  // ========================================
  // SAFE MEETUP POINTS
  // ========================================
  
  /// Get suggested safe meetup points
  /// Based on OfferUp's Community MeetUp Spots concept
  List<SafeMeetupPoint> getSafeMeetupSuggestions(String city) {
    // TODO: Integrate with real database of safe spots
    // For now, return common safe locations in Turkish cities
    
    final commonPlaces = [
      SafeMeetupPoint(
        name: 'Starbucks',
        type: MeetupPointType.cafe,
        description: 'Halka açık, kameralı ortam',
        icon: '☕',
      ),
      SafeMeetupPoint(
        name: 'Alışveriş Merkezi Ana Giriş',
        type: MeetupPointType.mall,
        description: 'Güvenli, kalabalık alan',
        icon: '🏬',
      ),
      SafeMeetupPoint(
        name: 'Metro İstasyonu',
        type: MeetupPointType.publicTransport,
        description: 'Merkezi lokasyon, kameralı',
        icon: '🚇',
      ),
      SafeMeetupPoint(
        name: 'Polis Karakolu Yakını',
        type: MeetupPointType.policeStation,
        description: 'En güvenli seçenek',
        icon: '🚔',
        isOfficial: true,
      ),
      SafeMeetupPoint(
        name: 'Park Ana Giriş',
        type: MeetupPointType.park,
        description: 'Gündüz saatlerinde güvenli',
        icon: '🌳',
      ),
    ];
    
    return commonPlaces;
  }

  // ========================================
  // PERMISSIONS
  // ========================================
  
  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    }
    
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Open app settings for permission
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Check if location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}

// ========================================
// MODELS
// ========================================

/// Safe meetup point model (like OfferUp)
class SafeMeetupPoint {
  final String name;
  final MeetupPointType type;
  final String description;
  final String icon;
  final bool isOfficial;
  final double? latitude;
  final double? longitude;

  SafeMeetupPoint({
    required this.name,
    required this.type,
    required this.description,
    required this.icon,
    this.isOfficial = false,
    this.latitude,
    this.longitude,
  });
}

enum MeetupPointType {
  policeStation,
  mall,
  cafe,
  publicTransport,
  park,
  other,
}

// ========================================
// EXCEPTIONS
// ========================================

class LocationServiceDisabledException implements Exception {
  @override
  String toString() => 'Konum servisleri kapalı. Lütfen ayarlardan açın.';
}

class LocationPermissionDeniedException implements Exception {
  @override
  String toString() => 'Konum izni reddedildi.';
}

class LocationPermissionDeniedForeverException implements Exception {
  @override
  String toString() => 'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan izin verin.';
}
