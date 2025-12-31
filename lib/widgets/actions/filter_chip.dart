import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class GFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  const GFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? color : GTheme.color(),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isSelected ? color : GTheme.color()),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withAlpha(75),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
