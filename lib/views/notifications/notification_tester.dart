import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travixy/services/notification_service.dart';
import 'package:travixy/providers/notification_provider.dart';

/// Debug widget for testing notifications
/// Add this to the drawer or settings for easy testing
class NotificationTester extends StatelessWidget {
  const NotificationTester({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return Column(
          children: [
            ListTile(
              title: const Text('Test Notification'),
              subtitle: const Text('Send a test notification'),
              onTap: () => _sendTestNotification(context, notificationProvider),
            ),
            ListTile(
              title: const Text('Unread Count'),
              trailing: Badge(
                label: Text('${notificationProvider.unreadCount}'),
              ),
            ),
            if (notificationProvider.notifications.isNotEmpty)
              ListTile(
                title: const Text('Clear All'),
                onTap: () => notificationProvider.clearAll(),
              ),
          ],
        );
      },
    );
  }

  void _sendTestNotification(
    BuildContext context,
    NotificationProvider provider,
  ) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Test Notification',
      body: 'This is a test notification from Travixy',
      timestamp: DateTime.now(),
      isRead: false,
    );

    provider.addNotification(notification);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
