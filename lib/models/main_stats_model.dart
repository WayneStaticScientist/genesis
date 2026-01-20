class VehicleDetails {
  String vehicleId;
  String model;
  String status;
  String driverId;
  String driverName;
  VehicleDetails({
    required this.vehicleId,
    required this.model,
    required this.status,
    required this.driverId,
    required this.driverName,
  });
}

class MainStatsModel {
  int totalMaintenanceCount;
  double totalMaintainanceCost;
  int numberOfVehiclesWithMaintenance;
  int numberOfDriversInvolved;
  List<VehicleDetails> vehicleDetails;
  MainStatsModel({
    required this.totalMaintenanceCount,
    required this.totalMaintainanceCost,
    required this.vehicleDetails,
    required this.numberOfVehiclesWithMaintenance,
    required this.numberOfDriversInvolved,
  });
  factory MainStatsModel.fromJson(Map<String, dynamic> json) {
    return MainStatsModel(
      totalMaintenanceCount: json['totalMaintenanceCount'],
      totalMaintainanceCost: (json['totalCosts'] as num).toDouble(),
      numberOfVehiclesWithMaintenance: json['numberOfVehiclesWithMaintenance'],
      numberOfDriversInvolved: json['numberOfDriversInvolved'],
      vehicleDetails: (json['vehicleDetails'] as List)
          .map(
            (e) => VehicleDetails(
              vehicleId: e['vehicleId'],
              model: e['model'],
              status: e['status'],
              driverId: e['driverId'],
              driverName: e['driverName'],
            ),
          )
          .toList(),
    );
  }
}
