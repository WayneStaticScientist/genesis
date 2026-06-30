import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/screens/auth/profile_screen.dart';
import 'package:genesis/controllers/messaging_controller.dart';
import 'package:genesis/controllers/notifications_controller.dart';

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
  final _notificationsController = Get.find<NotificationsController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final user = _userController.user.value;
      final role = user?.role ?? "driver";
      final isDriver = role == "driver";
      final isMaintainer = role == "maintainer";
      final isAgent = role == "agent";

      return Container(
        width: 280,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1117) : const Color(0xFFFAFAFD),
          border: Border(
            right: BorderSide(
              color: isDark
                  ? Colors.white.withAlpha(12)
                  : Colors.black.withAlpha(10),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── LOGO / BRAND HEADER ────────────────────────────────
              _buildBrandHeader(primaryColor, isDark),

              // ─── SEARCH ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search...",
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ),

              // ─── NAV ITEMS ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("MAIN"),
                      _navItem(
                        context,
                        'dashboard',
                        "Dashboard",
                        Icons.grid_view_rounded,
                        primaryColor,
                        visible: !isDriver && !isMaintainer && !isAgent,
                      ),
                      _navItem(
                        context,
                        'reports',
                        "Revenue Reports",
                        Icons.bar_chart_rounded,
                        primaryColor,
                        visible: !isDriver && !isMaintainer && !isAgent,
                      ),
                      _navItem(
                        context,
                        'monthly_reports',
                        "Monthly Reports",
                        Icons.calendar_month_rounded,
                        primaryColor,
                        visible: !isDriver && !isMaintainer && !isAgent,
                      ),
                      _navItem(
                        context,
                        'yearly_reports',
                        "Yearly Reports",
                        Icons.calendar_view_month_rounded,
                        primaryColor,
                        visible: !isDriver && !isMaintainer && !isAgent,
                      ),
                      Obx(
                        () => _navItem(
                          context,
                          'chats',
                          "Chats",
                          Icons.chat_bubble_outline_rounded,
                          primaryColor,
                          badge: _messageController.notifications.value,
                        ),
                      ),
                      Obx(
                        () => _navItem(
                          context,
                          'notifications',
                          "Notifications",
                          Icons.notifications_none_rounded,
                          primaryColor,
                          badge:
                              _notificationsController.notificationSize.value,
                        ),
                      ),
                      _navItem(
                        context,
                        'trips',
                        "Trips",
                        Icons.route_rounded,
                        primaryColor,
                        visible: !isDriver && !isMaintainer,
                      ),
                      _navItem(
                        context,
                        'vehicles',
                        "Vehicles",
                        Icons.local_shipping_outlined,
                        primaryColor,
                        visible: !isDriver && !isMaintainer,
                      ),
                      _navItem(
                        context,
                        'drivers',
                        "Drivers",
                        Icons.badge_outlined,
                        primaryColor,
                        visible: !isDriver && !isAgent,
                      ),
                      _navItem(
                        context,
                        'tracking',
                        "Live Tracking",
                        Icons.near_me_rounded,
                        primaryColor,
                        visible: isDriver,
                      ),

                      const SizedBox(height: 8),
                      _sectionLabel("OPERATIONS"),
                      _navItem(
                        context,
                        'maintanance',
                        "Maintenance",
                        Icons.build_circle_outlined,
                        primaryColor,
                      ),
                      _navItem(
                        context,
                        'payrolls',
                        "Payroll",
                        Icons.account_balance_wallet_outlined,
                        primaryColor,
                        visible: !isDriver && !isMaintainer && !isAgent,
                      ),
                      _navItem(
                        context,
                        'my_payments',
                        "My Payments",
                        Icons.payments_outlined,
                        primaryColor,
                      ),

                      if (!isDriver && !isMaintainer && !isAgent) ...[
                        const SizedBox(height: 8),
                        _sectionLabel("WORKFORCE"),
                        _navItem(
                          context,
                          'employees',
                          "Employees",
                          Icons.people_alt_outlined,
                          primaryColor,
                        ),
                      ],

                      const SizedBox(height: 8),
                      _sectionLabel("SYSTEM"),
                      _navItem(
                        context,
                        'settings',
                        "Settings",
                        Icons.tune_rounded,
                        primaryColor,
                      ),
                    ],
                  ),
                ),
              ),

              // ─── USER PROFILE CARD ──────────────────────────────────
              _buildUserCard(user, role, primaryColor, isDark),
            ],
          ),
        ),
      );
    });
  }

  // ── Brand Header ──────────────────────────────────────────────────────────
  Widget _buildBrandHeader(Color primaryColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withAlpha(isDark ? 40 : 20),
            primaryColor.withAlpha(isDark ? 15 : 8),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: primaryColor.withAlpha(isDark ? 30 : 15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withBlue(220)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_mosaic_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "GENESIS",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                "Fleet Management",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.grey[500],
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  // ── Nav Item ──────────────────────────────────────────────────────────────
  Widget _navItem(
    BuildContext context,
    String index,
    String title,
    IconData icon,
    Color primaryColor, {
    int badge = 0,
    bool visible = true,
  }) {
    if (!visible) return const SizedBox.shrink();

    final isSelected = widget.selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withBlue((primaryColor.blue + 40).clamp(0, 255)),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: primaryColor.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: () {
          if (!isSelected) widget.ontap?.call(index);
        },
        borderRadius: BorderRadius.circular(14),
        splashColor: primaryColor.withAlpha(20),
        highlightColor: primaryColor.withAlpha(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(30)
                      : (isDark
                            ? Colors.white.withAlpha(10)
                            : Colors.black.withAlpha(6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: badge > 0 && !isSelected
                    ? Badge.count(
                        count: badge,
                        child: Icon(
                          icon,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey[isDark ? 400 : 600],
                        ),
                      )
                    : Icon(
                        icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey[isDark ? 400 : 600],
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.grey[isDark ? 300 : 700],
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              // Active indicator dot
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
              else if (badge > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge > 99 ? "99+" : badge.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── User Profile Card ─────────────────────────────────────────────────────
  Widget _buildUserCard(
    dynamic user,
    String role,
    Color primaryColor,
    bool isDark,
  ) {
    final initials = user != null ? (user.firstName[0]).toUpperCase() : "U";
    final fullName = user != null
        ? "${user.firstName} ${user.lastName}"
        : "User";

    return GestureDetector(
      onTap: () => Get.to(() => const ProfileScreen()),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.white.withAlpha(8), Colors.white.withAlpha(4)]
                : [primaryColor.withAlpha(12), primaryColor.withAlpha(6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(14)
                : primaryColor.withAlpha(30),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withBlue(220)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
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
                      color: const Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF0F1117)
                            : const Color(0xFFFAFAFD),
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
                    fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        role.capitalizeFirst ?? role,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
