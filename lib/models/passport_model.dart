class PassportModel {
  String passportNumber;
  DateTime expiryDate;
  String issuingCountry;

  PassportModel({
    required this.passportNumber,
    required this.expiryDate,
    required this.issuingCountry,
  });

  factory PassportModel.fromJSON(Map<String, dynamic> data) {
    return PassportModel(
      passportNumber: data['passportNumber'] ?? '',
      expiryDate: data['expiryDate'] != null
          ? DateTime.parse(data['expiryDate']).toLocal()
          : DateTime.now(),
      issuingCountry: data['issuingCountry'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "passportNumber": passportNumber,
      "expiryDate": expiryDate.toUtc().toIso8601String(),
      "issuingCountry": issuingCountry,
    };
  }
}
