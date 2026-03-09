class LicenceModel {
  int licenceClass;
  DateTime expiryDate;
  String licenceNumber;
  LicenceModel({
    required this.expiryDate,
    required this.licenceClass,
    required this.licenceNumber,
  });
  factory LicenceModel.fromJSON(data) {
    return LicenceModel(
      expiryDate: DateTime.parse(data['expiryDate']).toLocal(),
      licenceClass: data['licenceClass'],
      licenceNumber: data['licenceNumber'],
    );
  }
  Map toJson() {
    return {
      "expiryDate": expiryDate.toUtc().toIso8601String(),
      "licenceClass": licenceClass,
      'licenceNumber': licenceNumber,
    };
  }
}
