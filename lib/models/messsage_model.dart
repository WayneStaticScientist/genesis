import 'package:isar_plus/isar_plus.dart';
import 'package:genesis/utils/database_carrier.dart';
part 'messsage_model.g.dart';

@collection
class MesssageModel {
  bool sent = false;
  bool synced = true;
  final int id;
  final String content;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  String? fileUrl;
  String? fileName;
  String? fileType;

  MesssageModel({
    this.sent = false,
    this.synced = true,
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.receiverId,
    this.fileUrl,
    this.fileName,
    this.fileType,
  });

  toJSON() => {
    "id": id,
    "sent": sent,
    "content": content,
    "senderId": senderId,
    "receiverId": receiverId,
    "timestamp": timestamp.toIso8601String(),
    if (fileUrl != null) "fileUrl": fileUrl,
    if (fileName != null) "fileName": fileName,
    if (fileType != null) "fileType": fileType,
  };

  factory MesssageModel.fromJSON(Map<String, dynamic> json) {
    Isar isar = IsarStatic.isar!;
    return MesssageModel(
      id: isar.messsageModels.autoIncrement(),
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileType: json['fileType'] as String?,
    );
  }
}
