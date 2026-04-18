import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/models/licence_model.dart';
import 'package:genesis/models/populated_driver_model.dart';
import 'package:genesis/models/service_remainder_model.dart';

class VehicleModel {
  final String? id;
  final double usage;
  final String status;
  final String carModel;
  double fuelLevel;
  final double fuelRatio;
  final double emptyRatio;
  final double loadedFuelRatio;
  final String loadType; //loadType: "Loader" | "Standard"
  final String engineType;
  final String? engineNumber;
  final String? vinNumber;
  final String licencePlate;
  final PopulatedDriverModel? driver;
  final List<DeductionItem> insurances;
  final List<ServiceRemainderModel> serviceReminders;
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
    required this.insurances,
    required this.engineType,
    required this.serviceReminders,
    required this.emptyRatio,
    required this.loadType,
    required this.loadedFuelRatio,
    this.engineNumber,
    this.vinNumber,
    required this.licencePlate,
  });

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "usage": usage,
      "status": status,
      'licence': licence,
      "carModel": carModel,
      "fuelRatio": fuelRatio,
      'fuelLevel': fuelLevel,
      "insurances": insurances,
      'engineType': engineType,
      'engineNumber': engineNumber,
      'vinNumber': vinNumber,
      'driver': driver?.toJSON(),
      "licencePlate": licencePlate,
    };
  }

  factory VehicleModel.fromJSON(dynamic data) {
    return VehicleModel(
      id: data['_id'],
      serviceReminders:
          (data['serviceReminders'] as List?)
              ?.map((e) => ServiceRemainderModel.fromJSON(e))
              .toList() ??
          [],
      licence: data['licence'] != null
          ? LicenceModel.fromJSON(data['licence'])
          : null,
      driver: data['driver'] != null
          ? PopulatedDriverModel.fromJSON(data['driver'])
          : null,
      status: data['status'],
      insurances:
          (data['insurances'] as List<dynamic>?)
              ?.map((e) => DeductionItem.fromJSON(e))
              .toList() ??
          [],
      carModel: data['carModel'],
      licencePlate: data['licencePlate'],

      engineType: data['engineType'] ?? '',
      engineNumber: data['engineNumber'],
      vinNumber: data['vinNumber'],
      usage: (data['usage'] as num?)?.toDouble() ?? 0,
      fuelLevel: (data['fuelLevel'] as num?)?.toDouble() ?? 0,
      fuelRatio: (data['fuelRatio'] as num?)?.toDouble() ?? 0.0,
      emptyRatio: (data['emptyRatio'] as num?)?.toDouble() ?? 0.0,
      loadType: data['loadType'] ?? 'Standard',
      loadedFuelRatio: (data['loadedFuelRatio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
