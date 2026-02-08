class VehicleModel {
  final String? id;
  final double usage;
  final String status;
  final String? driver;
  final String carModel;
  final double fuelLevel;
  final double fuelRatio;
  final String engineType;
  final String licencePlate;

  VehicleModel({
    required this.id,
    required this.usage,
    required this.driver,
    required this.status,
    required this.carModel,
    required this.fuelLevel,
    required this.fuelRatio,
    required this.engineType,
    required this.licencePlate,
  });

  Map<String, dynamic> toJson() {
    return {
      "usage": usage,
      'driver': driver,
      "status": status,
      "carModel": carModel,
      'fuelLevel': fuelLevel,
      "fuelRatio": fuelRatio,
      'engineType': engineType,
      "licencePlate": licencePlate,
    };
  }

  factory VehicleModel.fromJSON(dynamic data) {
    return VehicleModel(
      id: data['_id'],
      driver: data['driver'],
      status: data['status'],
      carModel: data['carModel'],
      licencePlate: data['licencePlate'],
      engineType: data['engineType'] ?? '',
      usage: (data['usage'] as num?)?.toDouble() ?? 0,
      fuelLevel: (data['fuelLevel'] as num?)?.toDouble() ?? 0,
      fuelRatio: (data['fuelRatio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
