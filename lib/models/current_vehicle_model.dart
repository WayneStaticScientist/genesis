class CurrentVehicleModel {
  final String id;
  final String carModel;
  CurrentVehicleModel({required this.id, required this.carModel});
  factory CurrentVehicleModel.fromJson(dynamic json) {
    if (json.runtimeType == String) {
      return CurrentVehicleModel(id: "", carModel: "");
    }
    return CurrentVehicleModel(
      id: json['_id'] ?? '',
      carModel: json['carModel'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {'_id': id, 'carModel': carModel};
  }
}
