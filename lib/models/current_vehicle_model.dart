class CurrentVehicleModel {
  final String id;
  final String carModel;
  CurrentVehicleModel({required this.id, required this.carModel});
  factory CurrentVehicleModel.fromJson(Map<String, dynamic> json) {
    return CurrentVehicleModel(id: json['_id'], carModel: json['carModel']);
  }
  Map<String, dynamic> toJson() {
    return {'_id': id, 'carModel': carModel};
  }
}
