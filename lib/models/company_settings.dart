class CompanySettings {
  final bool autoApproveMaintainances;
  final bool driverManagedMaintainances;
  CompanySettings({
    required this.autoApproveMaintainances,
    required this.driverManagedMaintainances,
  });
  factory CompanySettings.fromJson(Map<String, dynamic>? json) {
    if (json == null)
      return CompanySettings(
        autoApproveMaintainances: false,
        driverManagedMaintainances: true,
      );
    return CompanySettings(
      autoApproveMaintainances: json['autoApproveMaintainances'] ?? false,
      driverManagedMaintainances: json['driverManagedMaintainances'] ?? true,
    );
  }

  toJson() {
    return {
      'autoApproveMaintainances': autoApproveMaintainances,
      'driverManagedMaintainances': driverManagedMaintainances,
    };
  }
}
