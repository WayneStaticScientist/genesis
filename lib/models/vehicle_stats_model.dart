import 'package:genesis/models/maintainance_model.dart';
import 'package:genesis/models/trip_model.dart';

class VehicleStatsModel {
  int totalHours;
  double totalTrips;
  double totalRevenue;
  double totalMileage;
  double totalMaintenanceCosts;
  List<TripModel> trips;
  List<MaintainanceModel> maintenances;
  VehicleStatsModel({
    required this.totalTrips,
    required this.totalRevenue,
    required this.totalMaintenanceCosts,
    required this.trips,
    required this.maintenances,
    required this.totalHours,
    required this.totalMileage,
  });

  factory VehicleStatsModel.fromJSON(data) {
    return VehicleStatsModel(
      totalTrips: (data['totalTrips'] as num?)?.toDouble() ?? 0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalMaintenanceCosts:
          (data['totalMaintenanceCosts'] as num?)?.toDouble() ?? 0,
      trips:
          (data['trips'] as List<dynamic>?)
              ?.map((e) => TripModel.fromJson(e))
              .toList() ??
          [],
      maintenances:
          (data['maintenances'] as List<dynamic>?)
              ?.map((e) => MaintainanceModel.fromJSON(e))
              .toList() ??
          [],
      totalHours: (data['totalHours'] as num?)?.toInt() ?? 0,
      totalMileage: (data['totalMileage'] as num?)?.toDouble() ?? 0,
    );
  }
}
