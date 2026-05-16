import 'package:geolocator/geolocator.dart';
import 'package:travixy/services/notification_service.dart';
import 'dart:async';
import 'dart:math' show sin, cos, sqrt, pow, atan2, pi;

/// Model for a geofenced place
class GeofencedPlace {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters; // Radius to trigger notification
  final String? description;
  final bool isHidden; // True for hidden gems

  GeofencedPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 500, // Default 500m radius
    this.description,
    this.isHidden = false,
  });

  /// Calculate distance in meters from a given position
  double distanceToPoint(double userLat, double userLng) {
    return _calculateDistance(userLat, userLng, latitude, longitude);
  }

  /// Haversine formula to calculate distance between two points
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusMeters = 6371000; // Earth's radius in meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

class LocationNotificationService {
  static final LocationNotificationService _instance =
      LocationNotificationService._internal();

  final NotificationService _notificationService = NotificationService();
  final Geolocator _geolocator = Geolocator();

  StreamSubscription<Position>? _positionStream;
  Timer? _proximityCheckTimer;

  /// Set of place IDs already notified (to avoid duplicate notifications)
  final Set<String> _notifiedPlaces = {};

  /// List of places to monitor for geofencing
  final List<GeofencedPlace> _monitoredPlaces = [];

  /// Proximity radius in meters (default 500m)
  int proximityRadius = 500;

  /// Enable/disable location monitoring
  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;

  factory LocationNotificationService() {
    return _instance;
  }

  LocationNotificationService._internal();

  /// Initialize location monitoring
  Future<void> initialize() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        print('Location permissions granted');
      }
    } catch (e) {
      print('Error requesting location permission: $e');
    }
  }

  /// Start monitoring location for nearby places
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    try {
      _isMonitoring = true;

      // Request location permission
      await initialize();

      // Listen to position updates (every 30 seconds or 100m movement)
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 100, // Update every 100m
          timeLimit: Duration(minutes: 5), // Max 5 min between updates
        ),
      ).listen((Position position) {
        _checkProximity(position);
      });

      print('Location monitoring started');
    } catch (e) {
      print('Error starting location monitoring: $e');
      _isMonitoring = false;
    }
  }

  /// Stop monitoring location
  void stopMonitoring() {
    _positionStream?.cancel();
    _proximityCheckTimer?.cancel();
    _isMonitoring = false;
    print('Location monitoring stopped');
  }

  /// Add places to monitor
  void setMonitoredPlaces(List<GeofencedPlace> places) {
    _monitoredPlaces.clear();
    _monitoredPlaces.addAll(places);
    print('Now monitoring ${places.length} places');
  }

  /// Check proximity to all monitored places
  void _checkProximity(Position userPosition) {
    for (final place in _monitoredPlaces) {
      final distance = place.distanceToPoint(
        userPosition.latitude,
        userPosition.longitude,
      );

      print(
          'Distance to ${place.name}: ${distance.toStringAsFixed(0)}m (radius: ${place.radiusMeters}m)');

      // Check if user is within geofence and hasn't been notified yet
      if (distance <= place.radiusMeters && !_notifiedPlaces.contains(place.id)) {
        _triggerProximityNotification(place);
        _notifiedPlaces.add(place.id);
      }
    }
  }

  /// Trigger notification when user enters geofence
  void _triggerProximityNotification(GeofencedPlace place) {
    final title = place.isHidden
        ? '🎉 Hidden Gem Nearby!'
        : '📍 Recommended Place Nearby!';

    final description = place.description ?? place.name;

    final notification = NotificationModel(
      id: 'geo_${place.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: 'Check out $description near you!',
      timestamp: DateTime.now(),
      data: {
        'type': 'location',
        'placeId': place.id,
        'placeName': place.name,
        'isHidden': place.isHidden,
        'latitude': place.latitude,
        'longitude': place.longitude,
      },
      isRead: false,
    );

    _notificationService.sendLocalNotification(notification);
    print('Proximity notification sent for ${place.name}');
  }

  /// Clear notification history for a place (allows re-notification)
  void resetPlaceNotification(String placeId) {
    _notifiedPlaces.remove(placeId);
  }

  /// Clear all notification history
  void resetAllNotifications() {
    _notifiedPlaces.clear();
  }

  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _notifiedPlaces.clear();
    _monitoredPlaces.clear();
  }
}
