import 'dart:developer';

import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/navs/admin/nav_main.dart';
import 'package:genesis/navs/admin/nav_payroll.dart';
import 'package:genesis/navs/admin/nav_drivers.dart';
import 'package:genesis/navs/admin/nav_reports.dart';
import 'package:genesis/navs/admin/nav_vehicles.dart';
import 'package:genesis/widgets/layouts/side_bar.dart';
import 'package:genesis/navs/admin/fleet_tracking.dart';
import 'package:genesis/navs/admin/nav_maintanance.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _userController = Get.find<UserController>();
  String _selectedIndex = "dashboard";
  Map<String, Widget> widgetTree = {
    "dashboard": const AdminNavMain(),
    "drivers": const AdminNavDrivers(),
    "reports": const AdminNavReports(),
    "payrolls": const AdminNavPayroll(),
    "vehicles": const AdminNavVehicles(),
    "tracking": const FleetTrackingScreen(),
    "maintanance": const AdminNavMaintenance(),
  };
  @override
  void initState() {
    super.initState();
    _selectedIndex = _userController.user.value?.role == "driver"
        ? "tracking"
        : "dashboard";
    log("user is ${_userController.user.value?.role}");
  }

  @override
  Widget build(BuildContext context) {
    final isDeskop = MediaQuery.of(context).size.width > 500;
    // Using a Row to create a persistent Sidebar + Content layout common in ERPs
    return Scaffold(
      drawer: !isDeskop
          ? GNavBar(selectedIndex: _selectedIndex, ontap: _onNavTap)
          : null,
      backgroundColor: GTheme.surface(),
      body: SafeArea(
        child: [
          if (isDeskop) ...[
            GNavBar(selectedIndex: _selectedIndex, ontap: _onNavTap),
          ],
          Expanded(child: widgetTree[_selectedIndex]!),
        ].row().sizedBox(),
      ),
    );
  }

  // --- Sidebar Widget ---

  _onNavTap(String index) {
    Get.back();
    setState(() {
      _selectedIndex = index;
    });
  }
}
