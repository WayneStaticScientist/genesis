import 'package:genesis/models/populated_location_model.dart';
import 'package:genesis/models/trip_model.dart';

class PopulatedTripModel {
  final String id;
  final String status;
  final String origin;
  final String destination;
  final List<Destinations> destinations;

  final PopulatedLocationModel? location;
  final PopulatedLocationModel? locationOrigin;
  PopulatedTripModel({
    this.location,
    required this.id,
    required this.status,
    required this.origin,
    required this.destination,
    this.locationOrigin,
    this.destinations = const [],
  });
  factory PopulatedTripModel.fromJSON(dynamic data) {
    if (data.runtimeType == String) {
      return PopulatedTripModel(
        id: '',
        status: '',
        destination: '',
        origin: '',
      );
    }
    return PopulatedTripModel(
      id: data['_id'],
      status: data['status'] ?? '',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      location: data['location'] != null
          ? PopulatedLocationModel.fromJSON(data['location'])
          : null,
      locationOrigin: data['locationOrigin'] != null
          ? PopulatedLocationModel.fromJSON(data['locationOrigin'])
          : null,
      destinations:
          (data['destinations'] as List<dynamic>?)
              ?.map((e) => Destinations.fromJson(e))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJSON() {
    return {
      '_id': id,
      'status': status,
      'origin': origin,
      'destination': destination,
      "location": location?.toJson(),
      'locationOrigin': locationOrigin?.toJson(),
      'destinations': destinations.map((e) => e.toJson()).toList(),
    };
  }
}
