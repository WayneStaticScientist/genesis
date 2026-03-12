class PayrollModel {
  double tax;
  double payment;
  double netPayment;
  dynamic userId;
  double insurance;
  DateTime createdAt;
  PayrollModel({
    required this.tax,
    required this.createdAt,
    required this.userId,
    required this.payment,
    required this.insurance,
    required this.netPayment,
  });
  factory PayrollModel.fromJSON(data) {
    return PayrollModel(
      userId: data['userId'],
      createdAt: (DateTime.parse(data['createdAt'])),
      tax: (data['tax'] as num?)?.toDouble() ?? 0,
      payment: (data['payment'] as num?)?.toDouble() ?? 0,
      insurance: (data['insurance'] as num?)?.toDouble() ?? 0,
      netPayment: (data['netPayment'] as num?)?.toDouble() ?? 0,
    );
  }
}
