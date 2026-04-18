import 'package:isar_plus/isar_plus.dart';
part 'notification_model.g.dart';

@collection
class NotificationModel {
  final int id;
  final String channenId;
  final String title;
  final String content;
  final String type;
  final DateTime date;
  final String referedId;
  bool isRead;

  NotificationModel(
    this.id, {
    required this.channenId,
    required this.title,
    required this.content,
    required this.type,
    required this.date,
    required this.referedId,
    this.isRead = false,
  });

  factory NotificationModel.fromJSON(int id, Map<String, dynamic> json) {
    return NotificationModel(
      id,
      channenId: json['channenId'] ?? '',
      referedId: json['referedId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'unknown',
      date: json['date'] != null
          ? DateTime.parse(json['date']).toLocal()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'referedId': referedId,
      'channenId': channenId,
      'title': title,
      'content': content,
      'type': type,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }
}
