import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleUtlis {
  static const vehicleStatuses = [
    "Active",
    "In Service",
    "Idle",
    "Out of Action",
  ];
  static const engineTypes = ["Electric", "Diesel", "Petrol", "Hybrid"];
  static String speedToStandardUnits(double? speed) {
    if (speed == 0 || speed == null) {
      return '0km/h';
    }
    return '${((speed / 1000) * 3600).toStringAsFixed(0)}km/h';
  }

  static double calculateBearing(LatLng startPoint, LatLng endPoint) {
    final lat1 = startPoint.latitude * math.pi / 180.0;
    final lng1 = startPoint.longitude * math.pi / 180.0;
    final lat2 = endPoint.latitude * math.pi / 180.0;
    final lng2 = endPoint.longitude * math.pi / 180.0;

    final dLng = lng2 - lng1;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final bearingRadians = math.atan2(y, x);
    final bearingDegrees = bearingRadians * 180.0 / math.pi;

    return (bearingDegrees + 360.0) % 360.0;
  }
}
