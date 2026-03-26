import 'package:exui/exui.dart';
import 'package:flutter/material.dart';

class FootNote extends StatelessWidget {
  final String description;
  final IconData? iconData;
  final Color? iconColor;
  const FootNote({
    super.key,
    required this.description,
    this.iconData,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor?.withAlpha(25) ?? Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor?.withAlpha(25) ?? Colors.orange.withAlpha(25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            iconData ?? Icons.insights_rounded,
            color: iconColor ?? Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: description.text(
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}
