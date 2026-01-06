class VehicleModel {
  final String? id;
  final String carModel;
  final String licencePlate;

  final String engineType;
  final double fuelRatio;
  final String status;

  final double usage;

  VehicleModel({
    required this.id,
    required this.carModel,
    required this.licencePlate,
    required this.engineType,
    required this.fuelRatio,
    required this.status,
    required this.usage,
  });

  Map<String, dynamic> toJson() {
    return {
      "carModel": carModel,
      "licencePlate": licencePlate,
      'engineType': engineType,
      "fuelRatio": fuelRatio,
      "status": status,
      "usage": usage,
    };
  }

  factory VehicleModel.fromJSON(dynamic data) {
    return VehicleModel(
      id: data['_id'],
      status: data['status'],
      carModel: data['carModel'],
      licencePlate: data['licencePlate'],
      engineType: data['engineType'] ?? '',
      usage: (data['usage'] as num?)?.toDouble() ?? 0,
      fuelRatio: (data['fuelRatio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
