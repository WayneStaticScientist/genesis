import 'package:genesis/models/populated_location_model.dart';

class PopulatedTripModel {
  final String id;
  final String status;
  final String destination;
  final PopulatedLocationModel? location;
  PopulatedTripModel({
    this.location,
    required this.id,
    required this.status,
    required this.destination,
  });
  factory PopulatedTripModel.fromJSON(Map<String, dynamic> data) {
    return PopulatedTripModel(
      id: data['_id'],
      status: data['status'] ?? '',
      destination: data['destination'] ?? '',
      location: data['location'] != null
          ? PopulatedLocationModel.fromJSON(data['location'])
          : null,
    );
  }
  Map<String, dynamic> toJSON() {
    return {
      '_id': id,
      'status': status,
      'destination': destination,
      "location": location?.toJson(),
    };
  }
}
