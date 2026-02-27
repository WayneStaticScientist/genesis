import 'package:genesis/models/messsage_model.dart';
import 'package:genesis/utils/database_carrier.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class GenesisBackgroundMessageHandler {
  static const String NotificationMessagesCounter =
      "GenesisBackgroundMessageHandler";
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    if (message.data['type'] == "message") {
      return _decodeMessage(message.data);
    }
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
