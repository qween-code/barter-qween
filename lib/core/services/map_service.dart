import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:injectable/injectable.dart';
import 'dart:math';
import '../../domain/entities/safe_meetup_point_entity.dart';

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
    return distanceInKm(lat1, lon1, lat2, lon2);
  }

  /// Get route between two points using Google Maps Directions API
  Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    try {
      // For now, return a simple route between points
      // TODO: Implement proper Google Maps Directions API
      return [origin, destination];
    } catch (e) {
      print('Error getting route points: $e');
      return [origin, destination];
    }
  }

  /// Create map route from polyline points
  Polyline createRoutePolyline(List<LatLng> points, {Color color = Colors.blue}) {
    return Polyline(
      polylineId: const PolylineId('route'),
      color: color,  // Fixed: Use Color directly instead of .value for Polyline
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
        address: '${placemark.street}, ${placemark.locality}',
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
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
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
  bool isWithinRadius(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
    double radiusKm,
  ) {
    final distanceKm = distanceInKm(startLat, startLng, endLat, endLng);
    return distanceKm <= radiusKm;
  }

  /// Animate camera to a new position
  Future<void> animateCamera(CameraPosition position) async {
    if (_controller == null) {
      throw Exception('Map controller not initialized');
    }

    await _controller!.animateCamera(CameraUpdate.newCameraPosition(position));
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

  /// Get safe meetup suggestions based on user location and preferences
  Future<List<EnhancedMeetupPoint>> getSafeMeetupSuggestions(
    LatLng userLocation, {
    required double radiusKm,
    List<String>? preferredTypes}
  ) async {
    try {
      // These would come from your database of safe meetup points
      // For now, returning predefined safe locations
      final safeLocations = <EnhancedMeetupPoint>[
        EnhancedMeetupPoint(
          id: 'shopping_mall_1',
          name: 'Istanbul Shopping Mall',
          address: 'Popular shopping center with security',
          latitude: userLocation.latitude + 0.01,
          longitude: userLocation.longitude + 0.01,
          type: 'shopping_mall',
          safetyLevel: SafetyLevel.high,
          userRating: 4.8,
          features: ['Security', 'Parking', 'WiFi', 'Food Court'],
          operatingHours: '09:00 - 22:00',
          distanceFromUser: 1.5,
        ),
        EnhancedMeetupPoint(
          id: 'cafe_1',
          name: 'Central Coffee Shop',
          address: 'Popular meet-up spot with good lighting',
          latitude: userLocation.latitude - 0.01,
          longitude: userLocation.longitude - 0.01,
          type: 'cafe',
          safetyLevel: SafetyLevel.medium,
          userRating: 4.5,
          features: ['WiFi', 'Security Camera', 'Indoor Seating'],
          operatingHours: '07:00 - 23:00',
          distanceFromUser: 1.2,
        ),
        EnhancedMeetupPoint(
          id: 'police_station_1',
          name: 'Central Police Station',
          address: 'Government building with 24/7 security',
          latitude: userLocation.latitude + 0.02,
          longitude: userLocation.longitude,
          type: 'police_station',
          safetyLevel: SafetyLevel.high,
          userRating: 5.0,
          features: ['24/7 Security', 'Police Presence', 'Parking'],
          operatingHours: '24/7',
          distanceFromUser: 2.0,
        ),
      ];

      // Filter by distance (need to handle async Distance calculation)
      List<EnhancedMeetupPoint> filteredLocations = [];
      for (var location in safeLocations) {
        final distance = await calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          location.latitude,
          location.longitude,
        );
        if (distance <= radiusKm) {
          filteredLocations.add(location);
        }
      }
      return filteredLocations;
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
      // This would integrate with Google Distance Matrix API
      // For now, using simple estimation
      final distance = calculateDistance(
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
      final distanceValue = await distance;
      final timeInHours = distanceValue / speed;
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
    double maxTravelTimeMinutes = 30,
    int maxResults = 5,
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

  /// Create route sharing session for live tracking
  Future<String> createSharedRouteSession({
    required String userId1,
    required String userId2,
    required String itemId,
    required LatLng meetupPoint,
  }) async {
    // This would create a Firestore document for route sharing
    // Returns session ID for tracking
    final sessionId = 'route_${userId1}_${userId2}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Implementation would include:
    // 1. Create session document in Firestore
    // 2. Set up real-time location sharing
    // 3. Configure safety alerts
    // 4. Set expiration time
    
    print('Created route sharing session: $sessionId');
    return sessionId;
  }

  /// Analyze user movement patterns for ML preparation
  Future<Map<String, dynamic>> analyzeUserMovementPatterns(String userId) async {
    // This would analyze user's meetup history to learn preferences
    // Returns structured data for ML model training
    
    return {
      'preferredMeetupTypes': ['shopping_mall', 'cafe'],
      'averageTravelRadius': 8.5,
      'peakActivityHours': [17, 18, 19], // 5-7 PM
      'preferredMeetingDays': ['saturday', 'sunday'],
      'safetyLevelPreference': 'high',
      'transportationMode': 'driving',
    };
  }

  /// Get distance matrix for multiple locations (optimized)
  Future<Map<String, double>> calculateDistanceMatrix(
    LatLng origin,
    List<LatLng> destinations,
  ) async {
    final results = <String, double>{};
    
    for (int i = 0; i < destinations.length; i++) {
      final destination = destinations[i];
      final distance = await calculateDistance(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );
      results['destination_$i'] = distance;
    }
    
    return results;
  }

  /// Check if location is within user's preferred area
  Future<bool> isInPreferredArea(
    LatLng location,
    String userId, {
    double preferredRadiusKm = 10.0,
  }) async {
    try {
      // This would check user's location preferences
      // For now, using a simple distance check from a user center
      final userPatterns = await analyzeUserMovementPatterns(userId);
      final avgRadius = userPatterns['averageTravelRadius'] as double? ?? preferredRadiusKm;
      
      // Simplified: check if within average travel radius
      // In real implementation, this would check actual preferred zones
      return true;
    } catch (e) {
      print('Error checking preferred area: $e');
      return false;
    }
  }

  /// Get location-based recommendations for users
  Future<List<String>> getLocationBasedRecommendations(
    LatLng userLocation,
    String userId,
  ) async {
    final recommendations = <String>[];
    
    try {
      // Analyze user patterns
      final patterns = await analyzeUserMovementPatterns(userId);
      final safeLocations = await getSafeMeetupSuggestions(userLocation, radiusKm: 5.0);
      
      // Generate recommendations based on patterns and location
      if (patterns['safetyLevelPreference'] == 'high') {
        recommendations.add('Police Station meetups recommended');
        recommendations.add('Shopping malls with high security available');
      }
      
      if (patterns['averageTravelRadius'] as double > 15.0) {
        recommendations.add('Consider meeting halfway for long distances');
      }
      
      if (safeLocations.isNotEmpty) {
        recommendations.add('${safeLocations.length} safe meetup spots nearby');
      }
      
      return recommendations;
    } catch (e) {
      print('Error getting location recommendations: $e');
      return ['Enable location services for better recommendations'];
    }
  }

  /// Bulk distance calculation for item ranking
  Future<int> calculateLocationScore(
    LatLng userLocation,
    LatLng itemLocation,
    String userId,
  ) async {
    try {
      final distance = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        itemLocation.latitude,
        itemLocation.longitude,
      );
      
      final isInPreferred = await isInPreferredArea(itemLocation, userId);
      
      // Score calculation (0-100)
      // Closer distance = higher score
      // Preferred area = higher score
      final distanceValue = await distance;
      double score = 100.0 - (distanceValue * 2); // 2 points per km penalty
      if (isInPreferred) score += 20;
      
      return score.clamp(0, 100).round();
    } catch (e) {
      print('Error calculating location score: $e');
      return 50; // Default neutral score
    }
  }
}
