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
  int totalDriversInSystem;
  double totalMaintainanceCost;
  int totalVehiclesInSystem;
  int numberOfVehiclesWithMaintenance;
  List<VehicleDetails> vehicleDetails;
  MainStatsModel({
    required this.totalMaintenanceCount,
    required this.totalDriversInSystem,
    required this.totalVehiclesInSystem,
    required this.totalMaintainanceCost,
    required this.vehicleDetails,
    required this.numberOfVehiclesWithMaintenance,
  });
  factory MainStatsModel.fromJson(Map<String, dynamic> json) {
    return MainStatsModel(
      totalDriversInSystem: json['totalDriversInSystem'] ?? 0,
      totalVehiclesInSystem: json['totalVehiclesInSystem'] ?? 0,
      totalMaintenanceCount: json['totalMaintenanceCount'] ?? 0,
      totalMaintainanceCost: (json['totalCosts'] as num).toDouble(),
      numberOfVehiclesWithMaintenance: json['numberOfVehiclesWithMaintenance'],
      vehicleDetails: (json['vehicleDetails'] as List)
          .map(
            (e) => VehicleDetails(
              vehicleId: e['vehicleId'] ?? '',
              model: e['model'] ?? '',
              status: e['status'] ?? '',
              driverId: e['driverId'] ?? '',
              driverName: e['driverName'] ?? '',
            ),
          )
          .toList(),
    );
  }
}
