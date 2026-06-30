class CurrentVehicleModel {
  final String id;
  final String carModel;
  final String? licencePlate;
  final String? engineNumber;
  final String? vinNumber;
  final double fuelRatio;
  final double emptyRatio;
  final double loadedFuelRatio;
  final double fullLoad;
  final String loadType;

  CurrentVehicleModel({
    required this.id,
    required this.carModel,
    this.licencePlate,
    this.engineNumber,
    this.vinNumber,
    this.fuelRatio = 0.0,
    this.emptyRatio = 0.0,
    this.loadedFuelRatio = 0.0,
    this.fullLoad = 0.0,
    this.loadType = 'Standard',
  });
  factory CurrentVehicleModel.fromJson(dynamic json) {
    if (json.runtimeType == String || json == null || json['_id'] == null) {
      return CurrentVehicleModel(id: "", carModel: "");
    }
    return CurrentVehicleModel(
      id: json['_id'] ?? '',
      carModel: json['carModel'] ?? '',
      licencePlate: json['licencePlate'],
      engineNumber: json['engineNumber'],
      vinNumber: json['vinNumber'],
      fuelRatio: (json['fuelRatio'] as num?)?.toDouble() ?? 0.0,
      emptyRatio: (json['emptyRatio'] as num?)?.toDouble() ?? 0.0,
      loadedFuelRatio: (json['loadedFuelRatio'] as num?)?.toDouble() ?? 0.0,
      fullLoad: (json['fullLoad'] as num?)?.toDouble() ?? 0.0,
      loadType: json['loadType'] ?? 'Standard',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'carModel': carModel,
      'licencePlate': licencePlate,
      'engineNumber': engineNumber,
      'vinNumber': vinNumber,
    };
  }
}
