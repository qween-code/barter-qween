import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:injectable/injectable.dart';
import 'dart:math';

/// Safety Level for meetup points
enum SafetyLevel { high, medium, low }

/// Meetup preferences for optimization
class MeetupPreferences {
  final SafetyLevel preferredSafetyLevel;
  final bool prefersIndoor;
  final bool requiresParking;
  final List<String> preferredTypes;
  final TimeOfDay? preferredTime;

  const MeetupPreferences({
    this.preferredSafetyLevel = SafetyLevel.high,
    this.prefersIndoor = true,
    this.requiresParking = true,
    this.preferredTypes = const ['shopping_mall', 'cafe', 'police_station'],
    this.preferredTime,
  });
}

/// Location Point for meetup and map features
class LocationPoint {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type; // meetup_point, store, café, etc.

  const LocationPoint({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
    };
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      type: json['type'] ?? 'unknown',
    );
  }

  @override
  String toString() => 'LocationPoint(name: $name, type: $type)';
}

/// Enhanced meetup point with safety information
class EnhancedMeetupPoint {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final SafetyLevel safetyLevel;
  final double userRating;
  final bool isOpenNow;
  final List<String> features;
  final String? operatingHours;
  final double distanceFromUser;

  const EnhancedMeetupPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.safetyLevel,
    this.userRating = 4.5,
    this.isOpenNow = true,
    this.features = const [],
    this.operatingHours,
    this.distanceFromUser = 0.0,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  double get safetyScore {
    switch (safetyLevel) {
      case SafetyLevel.high:
        return 1.0;
      case SafetyLevel.medium:
        return 0.7;
      case SafetyLevel.low:
        return 0.4;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'safetyLevel': safetyLevel.toString(),
      'userRating': userRating,
      'isOpenNow': isOpenNow,
      'features': features,
      'operatingHours': operatingHours,
      'distanceFromUser': distanceFromUser,
    };
  }
}

@lazySingleton
class MapService {
  GoogleMapController? _controller;
  final PolylinePoints _polylinePoints = PolylinePoints();
  static const String _googleApiKey = 'AIzaSyBwgXj2qE9o6e9bT3nR4pQ7vX2wZ9c1yA8'; // Replace with actual API key

  MapService();

  void setMapController(GoogleMapController controller) {
    _controller = controller;
  }

  /// Clean up resources
  void dispose() {
    _controller = null;
  }

  Future<void> initializeMap() async {
    // Initialization logic if needed
  }

  /// Get current user location
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

  /// Calculate distance between two points in kilometers
  Future<double> calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Get route between two points using Google Maps Directions API
  Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    try {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        return result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting route: $e');
      return [];
    }
  }

  /// Create map route from polyline points
  Polyline createRoutePolyline(List<LatLng> points, {Color color = Colors.blue}) {
    return Polyline(
      polylineId: const PolylineId('route'),
      color: color,
      width: 5,
      points: points,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  /// Add multiple markers to map
  Future<void> addMarkers(List<Marker> markers) async {
    if (_controller != null) {
      for (final marker in markers) {
        await _controller!.showMarkerInfoWindow(marker.markerId);
      }
    }
  }

  /// Calculate bounding box for a set of coordinates
  LatLngBounds calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(0, 0),
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Get suggested meetup points between two users
  Future<List<LocationPoint>> getMeetupPoints(LatLng userLocation, LatLng otherLocation) async {
    // Calculate midpoint
    double midLat = (userLocation.latitude + otherLocation.latitude) / 2;
    double midLng = (userLocation.longitude + otherLocation.longitude) / 2;
    LatLng midpoint = LatLng(midLat, midLng);

    // Get nearby places around midpoint
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(midpoint.latitude, midpoint.longitude);
      return placemarks.map((placemark) => LocationPoint(
        name: placemark.name ?? 'Unknown Location',
        address: '${placemark.street ?? ''}, ${placemark.locality ?? ''}',
        latitude: midpoint.latitude,
        longitude: midpoint.longitude,
        type: 'meetup_point',
      )).toList();
    } catch (e) {
      // Fallback: return midpoint as default location
      return [LocationPoint(
        name: 'Midpoint Location',
        address: '',
        latitude: midLat,
        longitude: midLng,
        type: 'meetup_point',
      )];
    }
  }

  /// Animate map to show route
  Future<void> animateToRoute(List<LatLng> routePoints) async {
    if (_controller != null && routePoints.isNotEmpty) {
      LatLngBounds bounds = calculateBounds(routePoints);
      await _controller!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  double distanceInKm(double lat1, double lon1, double lat2, double lon2) {
    final distanceMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distanceMeters / 1000;
  }

  String getFormattedDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    }
    return '${distanceInKm.toStringAsFixed(1)}km';
  }

  /// Get safe meetup suggestions with enhanced features
  Future<List<EnhancedMeetupPoint>> getSafeMeetupSuggestions(
    LatLng userLocation, {
    double radiusKm = 5.0,
    MeetupPreferences? preferences,
  }) async {
    try {
      // Predefined safe locations with enhanced features
      final safeLocations = <EnhancedMeetupPoint>[
        EnhancedMeetupPoint(
          id: 'shopping_mall_1',
          name: 'Istanbul Shopping Mall',
          address: 'Popular shopping center with security',
          latitude: userLocation.latitude + 0.01,
          longitude: userLocation.longitude + 0.01,
          type: 'Shopping Mall',
          safetyLevel: SafetyLevel.high,
          features: ['Security', 'Parking', 'WiFi', 'Food Court', 'Indoor'],
          operatingHours: '09:00 - 22:00',
        ),
        EnhancedMeetupPoint(
          id: 'cafe_1',
          name: 'Central Coffee Shop',
          address: 'Popular meet-up spot with good lighting',
          latitude: userLocation.latitude - 0.01,
          longitude: userLocation.longitude - 0.01,
          type: 'Café',
          safetyLevel: SafetyLevel.medium,
          features: ['WiFi', 'Security Camera', 'Indoor Seating'],
          operatingHours: '07:00 - 23:00',
        ),
        EnhancedMeetupPoint(
          id: 'police_station_1',
          name: 'Central Police Station',
          address: 'Government building with 24/7 security',
          latitude: userLocation.latitude + 0.02,
          longitude: userLocation.longitude,
          type: 'Police Station',
          safetyLevel: SafetyLevel.high,
          features: ['24/7 Security', 'Police Presence', 'Parking'],
          operatingHours: '24/7',
        ),
      ];

      // Filter by distance
      return safeLocations.map((location) {
        final distance = distanceInKm(
          userLocation.latitude,
          userLocation.longitude,
          location.latitude,
          location.longitude,
        );
        return EnhancedMeetupPoint(
          id: location.id,
          name: location.name,
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          type: location.type,
          safetyLevel: location.safetyLevel,
          userRating: location.userRating,
          isOpenNow: location.isOpenNow,
          features: location.features,
          operatingHours: location.operatingHours,
          distanceFromUser: distance,
        );
      }).where((location) => location.distanceFromUser <= radiusKm).toList();
    } catch (e) {
      print('Error getting safe meetup suggestions: $e');
      return [];
    }
  }

  /// Calculate estimated travel time between two points
  Future<int> calculateEstimatedTravelTime(
    LatLng origin,
    LatLng destination, {
    String travelMode = 'driving', // 'driving', 'walking', 'transit'
  }) async {
    try {
      final distance = await calculateDistance(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );
      
      // Simple speed estimates (km/h)
      final Map<String, double> speeds = {
        'driving': 40.0,    // Average city driving
        'walking': 5.0,     // Average walking speed
        'transit': 25.0,    // Average public transit
      };
      
      final speed = speeds[travelMode] ?? 40.0;
      final timeInHours = distance / speed;
      return (timeInHours * 60).round(); // Return minutes
    } catch (e) {
      print('Error calculating travel time: $e');
      return 30; // Default 30 minutes
    }
  }

  /// Get optimal meetup points for two users
  Future<List<EnhancedMeetupPoint>> getOptimalMeetupPoints(
    LatLng user1Location,
    LatLng user2Location, {
    int maxResults = 5,
    double maxTravelTimeMinutes = 30,
  }) async {
    try {
      // Calculate midpoint
      final midLat = (user1Location.latitude + user2Location.latitude) / 2;
      final midLng = (user1Location.longitude + user2Location.longitude) / 2;
      final midpoint = LatLng(midLat, midLng);

      // Get safe locations around midpoint
      final safeLocations = await getSafeMeetupSuggestions(midpoint, radiusKm: 10.0);
      
      // Filter and rank by travel time for both users
      final rankedLocations = <Map<String, dynamic>>[];
      
      for (final location in safeLocations) {
        final locationPoint = LatLng(location.latitude, location.longitude);
        
        final travelTime1 = await calculateEstimatedTravelTime(user1Location, locationPoint);
        final travelTime2 = await calculateEstimatedTravelTime(user2Location, locationPoint);
        
        // Only include if both users can reach within max time
        if (travelTime1 <= maxTravelTimeMinutes && travelTime2 <= maxTravelTimeMinutes) {
          final totalTravelTime = travelTime1 + travelTime2;
          final fairnessScore = (travelTime1 - travelTime2).abs(); // Lower is more balanced
          
          rankedLocations.add({
            'location': location,
            'totalTime': totalTravelTime,
            'fairnessScore': fairnessScore,
            'user1Time': travelTime1,
            'user2Time': travelTime2,
          });
        }
      }
      
      // Sort by total travel time (lowest first) and fairness
      rankedLocations.sort((a, b) {
        final timeComparison = (a['totalTime'] as int).compareTo(b['totalTime'] as int);
        if (timeComparison != 0) return timeComparison;
        return (a['fairnessScore'] as int).compareTo(b['fairnessScore'] as int);
      });
      
      return rankedLocations
          .take(maxResults)
          .map((entry) => entry['location'] as EnhancedMeetupPoint)
          .toList();
    } catch (e) {
      print('Error getting optimal meetup points: $e');
      return [];
    }
  }

  /// Calculate location compatibility score for item ranking
  Future<int> calculateLocationScore(
    LatLng userLocation,
    LatLng itemLocation,
    String userId,
  ) async {
    try {
      final distance = await calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        itemLocation.latitude,
        itemLocation.longitude,
      );
      
      // Score calculation (0-100)
      // Closer distance = higher score
      // Basic range-based scoring
      double score = 100.0 - (distance * 2); // 2 points per km penalty
      
      // Bonus for very close items
      if (distance < 2.0) score += 20;      // Within 2km gets bonus
      if (distance < 5.0) score += 10;      // Within 5km gets smaller bonus
      
      return score.clamp(0, 100).round();
    } catch (e) {
      print('Error calculating location score: $e');
      return 50; // Default neutral score
    }
  }
}
