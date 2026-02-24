class SevenDaysTotal {
  DateTime date;
  double revenue;
  int newDrivers;
  double maintenanceCost;
  int newVehicles;

  SevenDaysTotal({
    required this.date,
    required this.revenue,
    required this.newDrivers,
    required this.maintenanceCost,
    required this.newVehicles,
  });
  factory SevenDaysTotal.fromJson(Map<String, dynamic> json) {
    return SevenDaysTotal(
      date: DateTime.parse(json['date']),
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      newDrivers: json['newDrivers'] ?? 0,
      maintenanceCost: (json['maintenanceCost'] as num?)?.toDouble() ?? 0,
      newVehicles: json['newVehicles'] ?? 0,
    );
  }
}
