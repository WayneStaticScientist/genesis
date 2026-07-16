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
  double totalRevenue;
  double idleVehicles;
  double activeVehicles;
  double inServiceVehicles;
  int totalMaintenanceCount;
  int totalDriversInSystem;
  double totalMaintainanceCost;
  int totalVehiclesInSystem;
  int numberOfVehiclesWithMaintenance;
  double fuelExpense;
  double foodExpense;
  double tolgateExpense;
  double finesExpense;
  double extrasExpense;
  double truckStopExpense;
  double grossPayroll;
  int? payrollCount;
  int? servicesDue;
  int? servicesAlmostDue;
  int? tripsFinalized;
  int? tripsActive;
  int? tripsPending;
  int totalTurnaroundTimeMs;
  MainStatsModel({
    required this.idleVehicles,
    required this.activeVehicles,
    required this.inServiceVehicles,
    required this.totalRevenue,
    required this.totalMaintenanceCount,
    required this.totalDriversInSystem,
    required this.totalVehiclesInSystem,
    required this.totalMaintainanceCost,
    required this.numberOfVehiclesWithMaintenance,
    required this.fuelExpense,
    required this.foodExpense,
    required this.tolgateExpense,
    required this.finesExpense,
    required this.extrasExpense,
    required this.truckStopExpense,
    required this.grossPayroll,
    this.payrollCount,
    this.servicesDue,
    this.servicesAlmostDue,
    this.tripsFinalized,
    this.tripsActive,
    this.tripsPending,
    this.totalTurnaroundTimeMs = 0,
  });
  factory MainStatsModel.fromJson(Map<String, dynamic> json) {
    return MainStatsModel(
      idleVehicles: (json['idleVehicles'] as num?)?.toDouble() ?? 0,
      activeVehicles: (json['activeVehicles'] as num?)?.toDouble() ?? 0,
      inServiceVehicles: (json['inServiceVehicles'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalDriversInSystem: json['totalDriversInSystem'] ?? 0,
      totalVehiclesInSystem: json['totalVehicles'] ?? 0,
      totalMaintenanceCount: json['totalMaintenanceCount'] ?? 0,
      totalMaintainanceCost:
          (json['totalMaintenanceCosts'] as num?)?.toDouble() ?? 0,
      numberOfVehiclesWithMaintenance:
          json['numberOfVehiclesWithMaintenance'] ?? 0,
      fuelExpense: (json['fuelExpense'] as num?)?.toDouble() ?? 0,
      foodExpense: (json['foodExpense'] as num?)?.toDouble() ?? 0,
      tolgateExpense: (json['tolgateExpense'] as num?)?.toDouble() ?? 0,
      finesExpense: (json['finesExpense'] as num?)?.toDouble() ?? 0,
      extrasExpense: (json['extrasExpense'] as num?)?.toDouble() ?? 0,
      truckStopExpense: (json['truckStopExpense'] as num?)?.toDouble() ?? 0,
      grossPayroll: (json['grossPayroll'] as num?)?.toDouble() ?? 0,
      payrollCount: json['payrollCount'] ?? 0,
      servicesDue: json['servicesDue'] ?? 0,
      servicesAlmostDue: json['servicesAlmostDue'] ?? 0,
      tripsFinalized: json['tripsFinalized'] ?? 0,
      tripsActive: json['tripsActive'] ?? 0,
      tripsPending: json['tripsPending'] ?? 0,
      totalTurnaroundTimeMs: (json['totalTurnaroundTimeMs'] as num?)?.toInt() ?? 0,
    );
  }
}
