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
    );
  }
}
