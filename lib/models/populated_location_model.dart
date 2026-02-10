class PopulatedLocationModel {
  final double lng;
  final double lat;
  PopulatedLocationModel({required this.lat, required this.lng});
  factory PopulatedLocationModel.fromJSON(dynamic data) {
    return PopulatedLocationModel(
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
    );
  }
  toJson() {
    return {"lat": lat, "lng": lng};
  }
}
