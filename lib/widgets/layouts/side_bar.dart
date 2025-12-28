import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class GNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int index)? ontap;
  const GNavBar({super.key, required this.selectedIndex, this.ontap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: GTheme.color(),
      child: Column(
        children: [
          32.gapHeight,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Icon(
                  Icons.hexagon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                12.gapWidth,
                Text(
                  "GENESIS",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          40.gapHeight,
          Divider(color: Colors.grey.withAlpha(100)),
          32.gapHeight,
          // Navigation Items
          _buildNavItem(context, 0, "Dashboard", Icons.dashboard),
          _buildNavItem(context, 1, "Vehicles", Icons.directions_car),
          _buildNavItem(context, 2, "Drivers", Icons.people),
          _buildNavItem(context, 3, "Tracking", Icons.map),
          _buildNavItem(context, 4, "Maintenance", Icons.build),
          _buildNavItem(context, 5, "Reports", Icons.bar_chart),
          const Spacer(),
          // Bottom Settings
          _buildNavItem(context, 6, "Settings", Icons.settings),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String title,
    IconData icon,
  ) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        if (isSelected) return;
        ontap?.call(index);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 16, bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
