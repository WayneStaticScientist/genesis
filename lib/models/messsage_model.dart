import 'package:isar_plus/isar_plus.dart';
import 'package:genesis/utils/database_carrier.dart';
part 'messsage_model.g.dart';

@collection
class MesssageModel {
  bool sent = false;
  final int id;
  final String content;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  MesssageModel({
    this.sent = false,
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.receiverId,
  });
  toJSON() => {
    "id": id,
    "sent": sent,
    "content": content,
    "senderId": senderId,
    "receiverId": receiverId,
    "timestamp": timestamp.toIso8601String(),
  };
  factory MesssageModel.fromJSON(Map<String, dynamic> json) {
    Isar isar = IsarStatic.isar!;
    return MesssageModel(
      id: isar.messsageModels.autoIncrement(),
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
