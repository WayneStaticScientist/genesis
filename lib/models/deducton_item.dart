enum DeductionType { percentage, fixed }

class DeductionItem {
  final String name;
  final double value;
  final DeductionType type;

  DeductionItem({required this.name, required this.value, required this.type});

  double calculate(double baseSalary) {
    return type == DeductionType.percentage
        ? (baseSalary * (value / 100))
        : value;
  }

  Map toJson() {
    return {"name": name, "value": value, "type": type.index};
  }

  factory DeductionItem.fromJSON(data) {
    return DeductionItem(
      name: data['name'],
      value: (data['value'] as num?)?.toDouble() ?? 0,
      type: data['type'] == 0 ? DeductionType.percentage : DeductionType.fixed,
    );
  }
}
