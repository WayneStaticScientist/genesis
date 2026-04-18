import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:genesis/services/background_message_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GenesisNotificationHandler {
  static void showNotification(RemoteMessage message) {
    Map<String, dynamic> notification = message.data;
    if (notification['title'] != null) {
      flutterLocalNotificationsPlugin.show(
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
        id: notification.hashCode,
        title: notification['title'] ?? '',
        body: notification['content'] ?? '',
      );
    }
  }
}
