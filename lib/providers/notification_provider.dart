import 'package:flutter/foundation.dart';
import 'package:travixy/services/notification_service.dart';
import 'package:travixy/services/location_notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final LocationNotificationService _locationNotificationService =
      LocationNotificationService();

  final List<NotificationModel> _notifications = [];
  bool _permissionGranted = false;
  bool _locationNotificationsEnabled = false;

  List<NotificationModel> get notifications => [..._notifications];
  bool get permissionGranted => _permissionGranted;
  bool get locationNotificationsEnabled => _locationNotificationsEnabled;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).toList().length;

  NotificationProvider() {
    _initialize();
  }

  void _initialize() {
    // Listen to incoming notifications
    _notificationService.notificationStream.listen((notification) {
      addNotification(notification);
    });
  }

  /// Add new notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index =
        _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  /// Delete notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Request notification permissions
  Future<void> requestPermissions() async {
    try {
      await _notificationService.initialize();
      _permissionGranted = true;
      notifyListeners();
    } catch (e) {
      print('Error requesting notification permissions: $e');
      _permissionGranted = false;
      notifyListeners();
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _notificationService.getToken();
  }

  /// Enable/disable location-based notifications
  Future<void> setLocationNotificationsEnabled(bool enabled) async {
    _locationNotificationsEnabled = enabled;
    if (enabled) {
      await _locationNotificationService.initialize();
      await _locationNotificationService.startMonitoring();
    } else {
      _locationNotificationService.stopMonitoring();
    }
    notifyListeners();
  }

  /// Set places to monitor for geofencing
  void setMonitoredPlaces(List<GeofencedPlace> places) {
    _locationNotificationService.setMonitoredPlaces(places);
    notifyListeners();
  }

  /// Set proximity radius in meters
  void setProximityRadius(int radiusMeters) {
    _locationNotificationService.proximityRadius = radiusMeters;
  }

  /// Reset notification history for a place (allows re-notification)
  void resetPlaceNotification(String placeId) {
    _locationNotificationService.resetPlaceNotification(placeId);
  }

  /// Reset all location notifications
  void resetLocationNotifications() {
    _locationNotificationService.resetAllNotifications();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    _locationNotificationService.dispose();
    super.dispose();
  }
}

