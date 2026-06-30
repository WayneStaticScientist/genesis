class MonthlyData {
  final int month;
  final double revenue;
  final double expenses;
  final double payroll;
  final double netProfit;
  final int trips;

  MonthlyData({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.payroll,
    required this.netProfit,
    required this.trips,
  });

  factory MonthlyData.fromJSON(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] ?? 1,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0.0,
      payroll: (json['payroll'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      trips: json['trips'] ?? 0,
    );
  }
}

class YearlyReportModel {
  final double yearlyRevenue;
  final double yearlyExpenses;
  final double yearlyPayroll;
  final double yearlyNetProfit;
  final int yearlyTrips;
  final List<MonthlyData> monthlyData;

  YearlyReportModel({
    required this.yearlyRevenue,
    required this.yearlyExpenses,
    required this.yearlyPayroll,
    required this.yearlyNetProfit,
    required this.yearlyTrips,
    required this.monthlyData,
  });

  factory YearlyReportModel.fromJSON(Map<String, dynamic> json) {
    final yearly = json['yearly'] ?? {};
    final mData = json['monthlyData'] as List<dynamic>? ?? [];

    return YearlyReportModel(
      yearlyRevenue: (yearly['revenue'] as num?)?.toDouble() ?? 0.0,
      yearlyExpenses: (yearly['expenses'] as num?)?.toDouble() ?? 0.0,
      yearlyPayroll: (yearly['payroll'] as num?)?.toDouble() ?? 0.0,
      yearlyNetProfit: (yearly['netProfit'] as num?)?.toDouble() ?? 0.0,
      yearlyTrips: yearly['trips'] ?? 0,
      monthlyData: mData.map((e) => MonthlyData.fromJSON(e)).toList(),
    );
  }
}
