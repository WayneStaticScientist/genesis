import 'package:genesis/models/licence_model.dart';
import 'package:genesis/models/populated_driver_model.dart';

class VehicleModel {
  final String? id;
  final double usage;
  final String status;
  final String carModel;
  double fuelLevel;
  final double fuelRatio;
  final String engineType;
  final String licencePlate;
  final PopulatedDriverModel? driver;
  LicenceModel? licence;

  VehicleModel({
    this.licence,
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
      "_id": id,
      "usage": usage,
      "status": status,
      'licence': licence,
      "carModel": carModel,
      'fuelLevel': fuelLevel,
      "fuelRatio": fuelRatio,
      'engineType': engineType,
      'driver': driver?.toJSON(),
      "licencePlate": licencePlate,
    };
  }

  factory VehicleModel.fromJSON(dynamic data) {
    return VehicleModel(
      id: data['_id'],
      licence: data['licence'] != null
          ? LicenceModel.fromJSON(data['licence'])
          : null,
      driver: data['driver'] != null
          ? PopulatedDriverModel.fromJSON(data['driver'])
          : null,
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
