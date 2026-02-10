import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/screens/auth/profile_screen.dart';

class GNavBar extends StatefulWidget {
  final String selectedIndex;
  final Function(String index)? ontap;
  const GNavBar({super.key, required this.selectedIndex, this.ontap});

  @override
  State<GNavBar> createState() => _GNavBarState();
}

class _GNavBarState extends State<GNavBar> {
  final _userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final role = _userController.user.value?.role ?? "driver";
      final isDriver = role == "driver";
      return Container(
        width: 250,
        height: double.infinity,
        color: GTheme.color(),
        child: SingleChildScrollView(
          child: [
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
                    _userController.user.value?.firstName ?? "",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ).onTap(() => Get.to(() => ProfileScreen())),
            ),
            40.gapHeight,
            Divider(color: Colors.grey.withAlpha(100)),
            32.gapHeight,
            // Navigation Items
            _buildNavItem(
              context,
              'dashboard',
              "Dashboard",
              Icons.dashboard,
            ).visibleIf(!isDriver),
            _buildNavItem(
              context,
              'vehicles',
              "Vehicles",
              Icons.directions_car,
            ).visibleIf(!isDriver),
            _buildNavItem(
              context,
              'drivers',
              "Drivers",
              Icons.people,
            ).visibleIf(!isDriver),
            _buildNavItem(
              context,
              'tracking',
              "Tracking",
              Icons.map,
            ).visibleIf(isDriver),
            _buildNavItem(context, 'maintanance', "Maintenance", Icons.build),
            _buildNavItem(
              context,
              'reports',
              "Reports",
              Icons.bar_chart,
            ).visibleIf(!isDriver),
            _buildNavItem(
              context,
              'payrolls',
              "Payrolls",
              Icons.payment,
            ).visibleIf(!isDriver),
            // Bottom Settings
            _buildNavItem(context, 'settings', "Settings", Icons.settings),
            const SizedBox(height: 24),
          ].column(),
        ),
      );
    });
  }

  Widget _buildNavItem(
    BuildContext context,
    String index,
    String title,
    IconData icon,
  ) {
    bool isSelected = widget.selectedIndex == index;
    return InkWell(
      onTap: () {
        if (isSelected) return;
        widget.ontap?.call(index);
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
