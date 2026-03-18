import 'package:genesis/models/maintainance_model.dart';
import 'package:genesis/models/trip_model.dart';

class VehicleStatsModel {
  double totalTrips;
  double totalRevenue;
  double totalMaintenanceCosts;
  List<TripModel> trips;
  List<MaintainanceModel> maintenances;
  VehicleStatsModel({
    required this.totalTrips,
    required this.totalRevenue,
    required this.totalMaintenanceCosts,
    required this.trips,
    required this.maintenances,
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
    );
  }
}
