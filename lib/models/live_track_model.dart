class LiveTrackModel {
  final String user;
  final double lat;
  final double lng;
  final String car;
  final double speed;
  final double fuelLevel;
  final DateTime timestamp;

  LiveTrackModel({
    required this.user,
    required this.lat,
    required this.lng,
    required this.car,
    required this.speed,
    required this.fuelLevel,
    required this.timestamp,
  });
  factory LiveTrackModel.fromJSON(dynamic data) {
    return LiveTrackModel(
      user: data['user'] ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
      car: data['car'] ?? '',
      speed: (data['speed'] as num?)?.toDouble() ?? 0,
      fuelLevel: (data['fuelLevel'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(data['timestamp']) ?? DateTime.now(),
    );
  }
}
