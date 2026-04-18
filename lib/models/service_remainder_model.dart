class ServiceRemainderModel {
  final String name;
  final double mileage;
  final String type; //date or mileage;
  final DateTime? date;
  ServiceRemainderModel({
    required this.name,
    required this.mileage,
    required this.type,
    required this.date,
  });
  factory ServiceRemainderModel.fromJSON(data) {
    return ServiceRemainderModel(
      name: data['name'] ?? '',
      mileage: (data['mileage'] as num?)?.toDouble() ?? 0,
      type: data['type'],
      date: (data['date'] != null
          ? DateTime.tryParse(data['date'])?.toLocal()
          : null),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      if (type == 'date') "date": date?.toIso8601String(),
      if (type == 'mileage') "mileage": mileage,
    };
  }
}
