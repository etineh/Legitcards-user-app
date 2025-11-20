import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../data/models/notification_model.dart';
import 'k.dart';

class AppNotification {
  // Setup notification listener
  static void setupNotificationListener(widget, context) {
    widget.messagingService.notificationTapStream.listen((data) {
      // print('General log: Notification tap received: $data');

      if (data['action'] == 'navigate_to_detail' ||
          data['action'] == 'notification_tapped') {
        // Use WidgetsBinding to ensure we have a valid context
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // final context = router.routerDelegate.navigatorKey.currentContext;

          if (context != null && context.mounted) {
            // Create notification model from the data received
            final notificationM = NotificationM(
              id: data['data']?['id'] ?? '',
              timer: data['data']?['timer'] ?? 0,
              notification: NotificationContent(
                title: data['title'] ?? 'Notification',
                body: data['body'] ?? '',
              ),
              receiverId: data['data']?['receiver_id'] ?? '',
              reference: data['data']?['reference'] ?? '',
              createdAt: data['data']?['createdAt'] != null
                  ? data['data']['createdAt'] ?? DateTime.now().toString()
                  : DateTime.now().toString(),
              updatedAt: DateTime.now().toString(),
            );

            // Navigate using your custom method
            context.goNextScreenWithData(
              K.notificationDetailScreen,
              extra: notificationM,
            );
          }
        });
      }
    });
  }
}
