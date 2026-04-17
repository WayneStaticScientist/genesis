import 'package:genesis/models/current_vehicle_model.dart';
import 'package:genesis/models/populated_location_model.dart';

class OtherExpense {
  final String name;
  final double amount;

  OtherExpense({required this.name, required this.amount});

  factory OtherExpense.fromJson(Map<String, dynamic> json) {
    return OtherExpense(
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'amount': amount};
  }
}

class TripModel {
  String status;
  final String id;
  final String notes;
  final String origin;
  final dynamic driver;
  final dynamic clearer;
  final String loadType;
  final double distance;
  final String receiver;
  final dynamic finalizer;
  final dynamic initiater;
  final DateTime? endTime;
  final double loadWeight;
  final double tripPayout;
  final String destination;
  final DateTime? startTime;
  final double? endFuelLevel;
  final double? startFuelLevel;
  final DateTime? estimatedEndTime;
  final CurrentVehicleModel vehicle;
  final PopulatedLocationModel? location;
  final PopulatedLocationModel? locationOrigin;
  final double fuelExpense;
  final double foodExpense;
  final double tolgateExpense;
  final double truckShopExpense;
  final double finesExpense;
  final double extrasExpense;
  final String tripType;
  final String? portOfExit;
  final String? portOfEntry;
  final List<OtherExpense> otherExpenses;
  TripModel({
    required this.notes,
    required this.driver,
    required this.clearer,
    required this.id,
    required this.origin,
    required this.status,
    required this.loadType,
    required this.endTime,
    required this.loadWeight,
    required this.tripPayout,
    required this.destination,
    required this.startTime,
    required this.endFuelLevel,
    required this.startFuelLevel,
    required this.estimatedEndTime,
    required this.vehicle,
    required this.location,
    required this.locationOrigin,
    required this.fuelExpense,
    required this.foodExpense,
    required this.tolgateExpense,
    required this.truckShopExpense,
    required this.finesExpense,
    required this.extrasExpense,
    required this.finalizer,
    required this.distance,
    required this.receiver,
    required this.initiater,
    required this.tripType,
    this.portOfExit,
    this.portOfEntry,
    this.otherExpenses = const [],
  });
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      clearer: json['clearer'],
      driver: json['driver'],
      notes: json['notes'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      finalizer: (json['finalizer']),
      receiver: (json['receiver']) ?? '',
      id: json['_id'] ?? '',
      origin: json['origin'] ?? '',
      status: json['status'],
      loadType: json['loadType'],
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      loadWeight: (json['loadWeight'] as num?)?.toDouble() ?? 0,
      tripPayout: (json['tripPayout'] as num?)?.toDouble() ?? 0,
      destination: json['destination'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endFuelLevel: (json['endFuelLevel'] as num?)?.toDouble(),
      startFuelLevel: (json['startFuelLevel'] as num?)?.toDouble(),
      estimatedEndTime: json['estimatedEndTime'] != null
          ? DateTime.parse(json['estimatedEndTime'])
          : null,
      vehicle: CurrentVehicleModel.fromJson(json['vehicle']),
      location: json['location'] != null
          ? PopulatedLocationModel.fromJSON(json['location'])
          : null,
      locationOrigin: json['locationOrigin'] != null
          ? PopulatedLocationModel.fromJSON(json['locationOrigin'])
          : null,
      fuelExpense: (json['fuelExpense'] as num?)?.toDouble() ?? 0,
      foodExpense: (json['foodExpense'] as num?)?.toDouble() ?? 0,
      tolgateExpense: (json['tolgateExpense'] as num?)?.toDouble() ?? 0,
      truckShopExpense: (json['truckShopExpense'] as num?)?.toDouble() ?? 0,
      finesExpense: (json['finesExpense'] as num?)?.toDouble() ?? 0,
      extrasExpense: (json['extrasExpense'] as num?)?.toDouble() ?? 0,
      initiater: json['initiater'],
      tripType: json['tripType'] ?? 'Local',
      portOfExit: json['portOfExit'],
      portOfEntry: json['portOfEntry'],
      otherExpenses:
          (json['otherExpenses'] as List<dynamic>?)
              ?.map((e) => OtherExpense.fromJson(e))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'notes': notes,
      'driver': driver,
      'status': status,
      'clearer': clearer,
      'tripType': tripType,
      'loadType': loadType,
      'receiver': receiver,
      'distance': distance,
      'finalizer': finalizer,
      'initiater': initiater,
      'loadWeight': loadWeight,
      'tripPayout': tripPayout,
      'destination': destination,
      'vehicle': vehicle.toJson(),
      'fuelExpense': fuelExpense,
      'foodExpense': foodExpense,
      'endFuelLevel': endFuelLevel,
      'location': location?.toJson(),
      'startFuelLevel': startFuelLevel,
      'locationOrigin': locationOrigin,
      'endTime': endTime?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'estimatedEndTime': estimatedEndTime?.toIso8601String(),
      'otherExpenses': otherExpenses.map((e) => e.toJson()).toList(),
      'tolgateExpense': tolgateExpense,
      'truckShopExpense': truckShopExpense,
      'finesExpense': finesExpense,
      'extrasExpense': extrasExpense,
      'portOfExit': portOfExit,
      'portOfEntry': portOfEntry,
    };
  }
}
