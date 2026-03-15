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
}
