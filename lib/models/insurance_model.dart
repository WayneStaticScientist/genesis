import 'package:genesis/models/deducton_item.dart';

class InsuranceModel {
  final double total;
  final List<DeductionItem> insurances;
  final dynamic vehicleId;
  final DateTime createdAt;
  InsuranceModel({
    required this.total,
    required this.insurances,
    required this.vehicleId,
    required this.createdAt,
  });
  factory InsuranceModel.fromJSON(data) {
    return InsuranceModel(
      createdAt: DateTime.parse(data['createdAt']),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      insurances:
          (data['insurances'] as List<dynamic>?)
              ?.map((e) => DeductionItem.fromJSON(data))
              .toList() ??
          [],
      vehicleId: data['vehicleId'],
    );
  }
}
