import 'package:genesis/models/current_vehicle_model.dart';
import 'package:genesis/models/populated_location_model.dart';

class TripModel {
  final double tolgateFees;
  final String status;
  final String id;
  final String origin;
  final dynamic driver;
  final String loadType;
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

  TripModel({
    required this.tolgateFees,
    required this.driver,
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
  });
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      driver: json['driver'],
      tolgateFees: (json['tolgateFees'] as num?)?.toDouble() ?? 0,
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
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'locationOrigin': locationOrigin,
      'tolgateFees': tolgateFees,
      'driver': driver,
      'status': status,
      'loadType': loadType,
      'endTime': endTime?.toIso8601String(),
      'loadWeight': loadWeight,
      'tripPayout': tripPayout,
      'destination': destination,
      'startTime': startTime?.toIso8601String(),
      'endFuelLevel': endFuelLevel,
      'startFuelLevel': startFuelLevel,
      'estimatedEndTime': estimatedEndTime?.toIso8601String(),
      'vehicle': vehicle.toJson(),
      'location': location?.toJson(),
    };
  }
}
