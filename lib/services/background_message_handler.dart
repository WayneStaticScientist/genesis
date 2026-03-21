import 'package:genesis/models/messsage_model.dart';
import 'package:genesis/utils/database_carrier.dart';
import 'package:genesis/models/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:genesis/services/genesis_notification_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'messages_channel', // ID must match your backend
  'High Importance Notifications',
  description: 'This channel is used for chat messages.',
  importance: Importance.high,
  playSound: true,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class GenesisBackgroundMessageHandler {
  static const String NotificationMessagesCounter =
      "GenesisBackgroundMessageHandler";
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    GenesisNotificationHandler.showNotification(message);
    if (message.data['type'] == "message") {
      return _decodeMessage(message.data);
    }
    IsarStatic.isar ?? await IsarStatic.init();
    final isar = IsarStatic.isar;
    if (isar == null) return;
    final notification = NotificationModel.fromJSON(
      isar.notificationModels.autoIncrement(),
      message.data,
    );
    await isar.write((isar) async {
      isar.notificationModels.put(notification);
    });
  }

  static Future<void> _decodeMessage(Map<String, dynamic> data) async {
    IsarStatic.isar ?? await IsarStatic.init();
    final isar = IsarStatic.isar!;
    final message = MesssageModel.fromJSON(data);
    message.synced = false;
    await isar.write((isar) async {
      isar.messsageModels.put(message);
    });
  }
}
