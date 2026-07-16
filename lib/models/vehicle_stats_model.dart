import 'package:genesis/models/maintainance_model.dart';
import 'package:genesis/models/trip_model.dart';

class VehicleMonthSummary {
  final double trips;
  final double revenue;
  final double mileage;
  final double hours;
  final double maintenanceCosts;
  final double totalMaintenances;
  final double profit;

  VehicleMonthSummary({
    required this.trips,
    required this.revenue,
    required this.mileage,
    required this.hours,
    required this.maintenanceCosts,
    required this.totalMaintenances,
    required this.profit,
  });

  factory VehicleMonthSummary.fromJSON(data) {
    if (data == null) {
      return VehicleMonthSummary(
        trips: 0,
        revenue: 0,
        mileage: 0,
        hours: 0,
        maintenanceCosts: 0,
        totalMaintenances: 0,
        profit: 0,
      );
    }
    return VehicleMonthSummary(
      trips: (data['trips'] as num?)?.toDouble() ?? 0,
      revenue: (data['revenue'] as num?)?.toDouble() ?? 0,
      mileage: (data['mileage'] as num?)?.toDouble() ?? 0,
      hours: (data['hours'] as num?)?.toDouble() ?? 0,
      maintenanceCosts: (data['maintenanceCosts'] as num?)?.toDouble() ?? 0,
      totalMaintenances: (data['totalMaintenances'] as num?)?.toDouble() ?? 0,
      profit: (data['profit'] as num?)?.toDouble() ?? 0,
    );
  }
}

class VehicleStatsModel {
  int totalHours;
  double totalTrips;
  double totalRevenue;
  double totalMileage;
  double totalMaintenanceCosts;
  List<TripModel> trips;
  List<MaintainanceModel> maintenances;
  VehicleMonthSummary? thisMonth;

  VehicleStatsModel({
    required this.totalTrips,
    required this.totalRevenue,
    required this.totalMaintenanceCosts,
    required this.trips,
    required this.maintenances,
    required this.totalHours,
    required this.totalMileage,
    this.thisMonth,
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
      thisMonth: data['thisMonth'] != null
          ? VehicleMonthSummary.fromJSON(data['thisMonth'])
          : null,
    );
  }
}
