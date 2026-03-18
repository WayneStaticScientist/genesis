import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onAdd;
  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        if (onAdd != null)
          IconButton(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.blue,
              size: 20,
            ),
          ),
      ],
    );
  }
}
