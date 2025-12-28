import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class VehicleListItem extends StatelessWidget {
  final String vehicle;
  final String driver;
  final String status;
  final Color statusColor;
  const VehicleListItem({
    super.key,
    required this.vehicle,
    required this.driver,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GTheme.surface(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_shipping,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          16.gapWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  driver,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
