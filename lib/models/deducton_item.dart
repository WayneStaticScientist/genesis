enum DeductionType { percentage, fixed }

class DeductionItem {
  final String name;
  final double value;
  final DeductionType deductionType;

  DeductionItem({
    required this.name,
    required this.value,
    required this.deductionType,
  });

  double calculate(double baseSalary) {
    return deductionType == DeductionType.percentage
        ? (baseSalary * (value / 100))
        : value;
  }

  Map toJson() {
    return {"name": name, "value": value, "deductionType": deductionType.index};
  }

  factory DeductionItem.fromJSON(data) {
    return DeductionItem(
      name: data['name'] ?? '',
      value: (data['value'] as num?)?.toDouble() ?? 0,
      deductionType: data['deductionType'] == 0
          ? DeductionType.percentage
          : DeductionType.fixed,
    );
  }
}
