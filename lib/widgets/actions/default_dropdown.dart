import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class DefaultDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DefaultDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              labelStyle: const TextStyle(fontSize: 14),
            ),
            dropdownColor: GTheme.color(context),
            style: TextStyle(color: GTheme.reverse(context), fontSize: 14),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: e.text()))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
