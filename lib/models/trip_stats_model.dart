class MonthlyBreakDown {
  final double revenue;
  final DateTime date;
  MonthlyBreakDown({required this.date, required this.revenue});
  factory MonthlyBreakDown.fromJSON(data) {
    if (data == null) return MonthlyBreakDown(date: DateTime.now(), revenue: 0);
    return MonthlyBreakDown(
      date: DateTime.parse(data['date']).toLocal(),
      revenue: (data['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SummaryTile {
  double totalRevenue;
  int totalTrips;
  double margin;
  SummaryTile({
    required this.totalRevenue,
    required this.totalTrips,
    required this.margin,
  });
  factory SummaryTile.fromJSON(data) {
    if (data == null) {
      return SummaryTile(totalRevenue: 0, totalTrips: 0, margin: 0);
    }
    return SummaryTile(
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalTrips: data['totalTrips'],
      margin: (data['margin'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SummaryDriver {
  String name;
  double totalRevenue;
  SummaryDriver({required this.totalRevenue, required this.name});
  factory SummaryDriver.fromJSON(data) {
    if (data == null) {
      return SummaryDriver(totalRevenue: 0, name: '');
    }
    return SummaryDriver(
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      name: data['name'] ?? "",
    );
  }
}

class SummaryVehicle {
  String model;
  String driverName;
  double totalRevenue;
  SummaryVehicle({
    required this.totalRevenue,
    required this.model,
    required this.driverName,
  });
  factory SummaryVehicle.fromJSON(data) {
    if (data == null) {
      return SummaryVehicle(totalRevenue: 0, model: '', driverName: '');
    }
    return SummaryVehicle(
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      model: data['model'] ?? "",
      driverName: data['driverName'] ?? "",
    );
  }
}

class TripStatsModel {
  SummaryTile summary;
  List<SummaryDriver> drivers;
  List<SummaryVehicle> vehicles;
  List<MonthlyBreakDown> monthlyBreakdown;

  TripStatsModel({
    required this.summary,
    required this.drivers,
    required this.vehicles,
    required this.monthlyBreakdown,
  });
  factory TripStatsModel.fromJSON(data) {
    return TripStatsModel(
      summary: SummaryTile.fromJSON(data['summary']),
      drivers:
          (data['drivers'] as List<dynamic>?)
              ?.map((e) => SummaryDriver.fromJSON(e))
              .toList() ??
          const [],
      vehicles:
          (data['vehicles'] as List<dynamic>?)
              ?.map((e) => SummaryVehicle.fromJSON(e))
              .toList() ??
          const [],
      monthlyBreakdown:
          (data['monthlyBreakdown'] as List<dynamic>?)
              ?.map((e) => MonthlyBreakDown.fromJSON(e))
              .toList() ??
          const [],
    );
  }
}
