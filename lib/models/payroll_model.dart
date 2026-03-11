class PayrollModel {
  double tax;
  double payment;
  double netPayment;
  dynamic userId;
  double insurance;
  PayrollModel({
    required this.tax,
    required this.userId,
    required this.payment,
    required this.insurance,
    required this.netPayment,
  });
}
