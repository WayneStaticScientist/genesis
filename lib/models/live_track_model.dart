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
  final String state;
  final double todayDistance;
  final double mileage;
  final bool? acc;
  final double? voltage;
  final double? battery;

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
    required this.state,
    this.todayDistance = 0.0,
    this.mileage = 0.0,
    this.acc,
    this.voltage,
    this.battery,
  });

  factory LiveTrackModel.fromJSON(dynamic data) {
    return LiveTrackModel(
      carModel: data['carModel'] ?? '',
      state: data['state'] ?? '',
      user: data['user'] ?? '',
      rotation: (data['rotation'] as num?)?.toDouble() ?? 0,
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
      car: data['car'] ?? '',
      speed: (data['speed'] as num?)?.toDouble() ?? 0,
      fuelLevel: (data['fuelLevel'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(data['timestamp']) ?? DateTime.now(),
      todayDistance: (data['todayDistance'] as num?)?.toDouble() ?? 0,
      mileage: (data['mileage'] as num?)?.toDouble() ?? 0,
      acc: data['acc'] as bool?,
      voltage: (data['voltage'] as num?)?.toDouble(),
      battery: (data['battery'] as num?)?.toDouble(),
    );
  }
}
