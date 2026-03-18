import 'package:flutter/material.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/utils/theme.dart';

class DeductionTile extends StatelessWidget {
  final DeductionItem item;
  final VoidCallback? onRemove;
  const DeductionTile({super.key, required this.item, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(item.name, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            item.deductionType == DeductionType.percentage
                ? "${item.value}%"
                : "\$${item.value}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              child: const Icon(
                Icons.remove_circle,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
