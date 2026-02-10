class PopulatedTripModel {
  final String id;
  final String status;
  final String destination;
  PopulatedTripModel({
    required this.id,
    required this.status,
    required this.destination,
  });
  factory PopulatedTripModel.fromJSON(Map<String, dynamic> data) {
    return PopulatedTripModel(
      id: data['_id'],
      status: data['status'] ?? '',
      destination: data['destination'] ?? '',
    );
  }
}
