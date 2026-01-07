class MaintainanceModel {
  final String? id;
  final String licencePlate;
  final String? vehicleId;
  final String? carModel;
  final String issueDetails;
  final String urgenceLevel;
  final int dueDays;
  final double currentHealth;
  final double estimatedCosts;
  MaintainanceModel({
    this.id,
    this.carModel,
    required this.licencePlate,
    required this.vehicleId,
    required this.issueDetails,
    required this.urgenceLevel,
    required this.dueDays,
    required this.currentHealth,
    required this.estimatedCosts,
  });
  factory MaintainanceModel.fromJSON(dynamic data) {
    return MaintainanceModel(
      id: data['_id'],
      carModel: data['carModel'],
      dueDays: data['dueDays'],
      vehicleId: data['vehicleId'],
      issueDetails: data['issueDetails'],
      licencePlate: data['licencePlate'],
      urgenceLevel: data['urgenceLevel'],
      currentHealth: (data['currentHealth'] as num?)?.toDouble() ?? 0.00,
      estimatedCosts: (data['estimatedCosts'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
