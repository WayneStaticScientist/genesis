import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/screens/auth/profile_screen.dart';
import 'package:genesis/controllers/messaging_controller.dart';

class GNavBar extends StatefulWidget {
  final String selectedIndex;
  final Function(String index)? ontap;
  const GNavBar({super.key, required this.selectedIndex, this.ontap});

  @override
  State<GNavBar> createState() => _GNavBarState();
}

class _GNavBarState extends State<GNavBar> {
  final _userController = Get.find<UserController>();
  final _messageController = Get.find<MessagingController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Obx(() {
      final user = _userController.user.value;
      final role = user?.role ?? "driver";
      final isDriver = role == "driver";

      return Container(
        width: 280,
        height: double.infinity,
        decoration: BoxDecoration(
          color: GTheme.cardColor(),
          border: Border(
            right: BorderSide(
              color: theme.dividerColor.withAlpha(30),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- APP LOGO SECTION ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.auto_awesome_mosaic_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GENESIS",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          "Fleet Management",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- NAVIGATION ITEMS ---
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _sectionHeader("MAIN MENU"),
                      _buildNavItem(
                        context,
                        'dashboard',
                        "Dashboard",
                        Icons.grid_view_rounded,
                      ).visibleIf(!isDriver),
                      Obx(
                        () => _buildNavItem(
                          context,
                          'chats',
                          "Chats",
                          Icons.message_outlined,
                          notificationSize:
                              _messageController.notifications.value,
                        ),
                      ),
                      _buildNavItem(
                        context,
                        'trips',
                        "Trips",
                        Icons.route_outlined,
                      ).visibleIf(!isDriver),
                      _buildNavItem(
                        context,
                        'vehicles',
                        "Vehicles",
                        Icons.local_shipping_outlined,
                      ).visibleIf(!isDriver),
                      _buildNavItem(
                        context,
                        'drivers',
                        "Drivers",
                        Icons.person_search_rounded,
                      ).visibleIf(!isDriver),
                      _buildNavItem(
                        context,
                        'tracking',
                        "Live Tracking",
                        Icons.near_me_rounded,
                      ).visibleIf(isDriver),

                      const SizedBox(height: 24),
                      _sectionHeader("OPERATIONS"),
                      _buildNavItem(
                        context,
                        'maintanance',
                        "Maintenance",
                        Icons.build_circle_outlined,
                      ),
                      _buildNavItem(
                        context,
                        'payrolls',
                        "Payroll",
                        Icons.account_balance_wallet_outlined,
                      ).visibleIf(!isDriver),
                      _buildNavItem(
                        context,
                        'my_payments',
                        "My Payments",
                        Icons.account_balance,
                      ),

                      const SizedBox(height: 24),
                      _sectionHeader("OPERATIONS"),
                      _buildNavItem(
                        context,
                        'employees',
                        "Employees",
                        Icons.people_alt,
                      ).visibleIf(!isDriver),
                      const SizedBox(height: 24),
                      _sectionHeader("SYSTEM"),
                      _buildNavItem(
                        context,
                        'settings',
                        "Settings",
                        Icons.settings_suggest_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              // --- USER PROFILE CARD (BOTTOM) ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () => Get.to(() => const ProfileScreen()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withAlpha(8)
                          : Colors.grey.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(30)),
                    ),
                    child: Row(
                      children: [
                        // Avatar with online status
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: primaryColor.withAlpha(50),
                              child: Text(
                                (user?.firstName[0] ?? "U").toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: GTheme.cardColor(),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user?.firstName ?? "User",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                role.capitalizeFirst!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.unfold_more_rounded,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.grey[600],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String index,
    String title,
    IconData icon, {
    int notificationSize = 0,
  }) {
    bool isSelected = widget.selectedIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          if (isSelected) return;
          widget.ontap?.call(index);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withAlpha(75),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (notificationSize > 0)
                Badge.count(
                  count: notificationSize,
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[500],
                    size: 22,
                  ),
                )
              else
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[500],
                  size: 22,
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[500],
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
