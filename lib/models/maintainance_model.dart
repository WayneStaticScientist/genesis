class MaintenanceComment {
  final String text;
  final dynamic author;
  final DateTime createdAt;

  MaintenanceComment({
    required this.text,
    required this.author,
    required this.createdAt,
  });

  factory MaintenanceComment.fromJson(Map<String, dynamic> json) {
    return MaintenanceComment(
      text: json['text'] ?? '',
      author: json['author'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author is String ? author : author['_id'],
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MaintainanceModel {
  final String? id;
  final dynamic maintainerId;
  final dynamic approverId;
  final String licencePlate;
  final String? vehicleId;
  final String? carModel;
  final String issueDetails;
  final String urgenceLevel;
  final DateTime dueDate;
  final double currentHealth;
  final double estimatedCosts;
  final String status;
  final List<MaintenanceComment> comments;

  MaintainanceModel({
    this.id,
    this.carModel,
    required this.licencePlate,
    required this.vehicleId,
    required this.issueDetails,
    required this.urgenceLevel,
    required this.dueDate,
    required this.currentHealth,
    required this.estimatedCosts,
    required this.status,
    required this.maintainerId,
    required this.approverId,
    this.comments = const [],
  });

  factory MaintainanceModel.fromJSON(dynamic data) {
    return MaintainanceModel(
      id: data['_id'],
      status: data['status'] ?? '',
      carModel: data['carModel'] ?? '',
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'])
          : DateTime.now(),
      vehicleId: data['vehicleId'],
      issueDetails: data['issueDetails'] ?? '',
      licencePlate: data['licencePlate'] ?? '',
      urgenceLevel: data['urgenceLevel'] ?? '',
      currentHealth: (data['currentHealth'] as num?)?.toDouble() ?? 0.00,
      estimatedCosts: (data['estimatedCosts'] as num?)?.toDouble() ?? 0.0,
      maintainerId: data['maintainerId'],
      approverId: data['approverId'],
      comments: (data['comments'] as List<dynamic>?)
              ?.map((e) => MaintenanceComment.fromJson(e))
              .toList() ??
          [],
    );
  }
}
