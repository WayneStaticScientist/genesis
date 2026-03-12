class PayrollDetails {
  final double grossTotal;
  final int totalEmployees;
  final DateTime createdAt;
  PayrollDetails({
    required this.createdAt,
    required this.grossTotal,
    required this.totalEmployees,
  });
  factory PayrollDetails.fromJSON(data) {
    return PayrollDetails(
      createdAt: DateTime.parse(data["createdAt"]).toLocal(),
      grossTotal: (data["grossTotal"] as num?)?.toDouble() ?? 0,
      totalEmployees: data['totalEmployees'] ?? 0,
    );
  }
}
