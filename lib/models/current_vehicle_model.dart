class CurrentVehicleModel {
  final String id;
  final String carModel;
  final String? licencePlate;
  final String? engineNumber;
  final String? vinNumber;

  CurrentVehicleModel({
    required this.id,
    required this.carModel,
    this.licencePlate,
    this.engineNumber,
    this.vinNumber,
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
