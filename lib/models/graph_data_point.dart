class GraphDataPoint {
  DateTime date;
  String originalDateString;
  double revenue;
  int newDrivers;
  double maintenanceCost;
  int newVehicles;

  GraphDataPoint({
    required this.date,
    required this.originalDateString,
    required this.revenue,
    required this.newDrivers,
    required this.maintenanceCost,
    required this.newVehicles,
  });

  factory GraphDataPoint.fromJson(Map<String, dynamic> json) {
    String dateStr = json['date'];
    DateTime parsedDate;
    
    if (dateStr.length == 4) {
      // Yearly: YYYY
      parsedDate = DateTime(int.parse(dateStr), 1, 1);
    } else if (dateStr.length == 7) {
      // Monthly: YYYY-MM
      List<String> parts = dateStr.split('-');
      parsedDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
    } else {
      // Daily: YYYY-MM-DD
      parsedDate = DateTime.parse(dateStr);
    }

    return GraphDataPoint(
      date: parsedDate,
      originalDateString: dateStr,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      newDrivers: json['newDrivers'] ?? 0,
      maintenanceCost: (json['maintenanceCost'] as num?)?.toDouble() ?? 0,
      newVehicles: json['newVehicles'] ?? 0,
    );
  }
}
