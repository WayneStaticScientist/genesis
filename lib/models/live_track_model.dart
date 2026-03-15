class LiveTrackModel {
  final String user;
  final double lat;
  final double lng;
  final String car;
  final double speed;
  final String carModel;
  final double fuelLevel;
  final DateTime timestamp;
  final double rotation;

  LiveTrackModel({
    required this.user,
    required this.carModel,
    required this.lat,
    required this.lng,
    required this.car,
    required this.speed,
    required this.fuelLevel,
    required this.timestamp,
    required this.rotation,
  });
  factory LiveTrackModel.fromJSON(dynamic data) {
    return LiveTrackModel(
      carModel: data['carModel'] ?? '',
      user: data['user'] ?? '',
      rotation: (data['rotation'] as num?)?.toDouble() ?? 0,
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
      car: data['car'] ?? '',
      speed: (data['speed'] as num?)?.toDouble() ?? 0,
      fuelLevel: (data['fuelLevel'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(data['timestamp']) ?? DateTime.now(),
    );
  }
}
