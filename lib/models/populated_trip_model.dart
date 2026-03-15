import 'package:genesis/models/populated_location_model.dart';

class PopulatedTripModel {
  final String id;
  final String status;
  final String origin;
  final String destination;

  final PopulatedLocationModel? location;
  final PopulatedLocationModel? locationOrigin;
  PopulatedTripModel({
    this.location,
    required this.id,
    required this.status,
    required this.origin,
    required this.destination,
    this.locationOrigin,
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
    };
  }
}
