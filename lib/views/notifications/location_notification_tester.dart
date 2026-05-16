import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travixy/providers/notification_provider.dart';
import 'package:travixy/services/location_notification_service.dart';
import 'package:travixy/services/notification_service.dart';

/// Debug widget for testing location-based notifications
/// Shows proximity testing controls
class LocationNotificationTester extends StatefulWidget {
  const LocationNotificationTester({super.key});

  @override
  State<LocationNotificationTester> createState() =>
      _LocationNotificationTesterState();
}

class _LocationNotificationTesterState
    extends State<LocationNotificationTester> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return Column(
          children: [
            ListTile(
              title: const Text('Location Monitoring'),
              trailing: Switch(
                value: notificationProvider.locationNotificationsEnabled,
                onChanged: (value) async {
                  await notificationProvider.setLocationNotificationsEnabled(value);
                },
              ),
            ),
            if (notificationProvider.locationNotificationsEnabled) ...[
              ListTile(
                title: const Text('Simulated Proximity Test'),
                subtitle: const Text('Tap to send test location notification'),
                onTap: () => _sendTestProximityNotification(context),
              ),
              ListTile(
                title: const Text('Reset Place Notifications'),
                subtitle: const Text('Allow re-notification for all places'),
                onTap: () {
                  notificationProvider.resetLocationNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location notifications reset'),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  void _sendTestProximityNotification(BuildContext context) {
    final testPlace = GeofencedPlace(
      id: 'test_place_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Test Hidden Gem',
      latitude: 30.0444,
      longitude: 31.2357, // Cairo coordinates
      radiusMeters: 500,
      description: 'A mysterious local cafe in the heart of the city',
      isHidden: true,
    );

    final notificationProvider =
        context.read<NotificationProvider>();

    // Simulate proximity notification
    notificationProvider.addNotification(
      NotificationModel(
        id: 'geo_test_${DateTime.now().millisecondsSinceEpoch}',
        title: '🎉 Hidden Gem Nearby!',
        body:
            'Check out ${testPlace.description} near you!',
        timestamp: DateTime.now(),
        data: {
          'type': 'location',
          'placeId': testPlace.id,
          'placeName': testPlace.name,
          'isHidden': testPlace.isHidden,
          'latitude': testPlace.latitude,
          'longitude': testPlace.longitude,
        },
        isRead: false,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test location notification sent'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
