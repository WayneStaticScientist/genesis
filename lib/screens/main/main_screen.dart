import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/utils/screen_sizes.dart';
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
  late final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Map<String, Widget> widgetTree;
  @override
  void initState() {
    super.initState();
    _selectedIndex = _userController.user.value?.role == "driver"
        ? "tracking"
        : "dashboard";
    widgetTree = {
      "dashboard": const AdminNavMain(),
      "drivers": AdminNavDrivers(triggerKey: _scaffoldKey),
      "reports": const AdminNavReports(),
      "payrolls": const AdminNavPayroll(),
      "vehicles": const AdminNavVehicles(),
      "tracking": FleetTrackingScreen(triggerKey: _scaffoldKey),
      "maintanance": const AdminNavMaintenance(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDeskop = MediaQuery.of(context).size.width > ScreenSizes.DESKTOP_W;
    // Using a Row to create a persistent Sidebar + Content layout common in ERPs
    return Scaffold(
      key: _scaffoldKey,
      drawer: !isDeskop
          ? GNavBar(selectedIndex: _selectedIndex, ontap: _onNavTap)
          : null,
      backgroundColor: GTheme.surface(),
      body: SafeArea(
        child: [
          if (isDeskop) ...[
            GNavBar(selectedIndex: _selectedIndex, ontap: _onNavTap),
          ],
          Expanded(child: widgetTree[_selectedIndex] ?? SizedBox()),
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
