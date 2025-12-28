import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/navs/admin/nav_maintanance.dart';
import 'package:genesis/navs/admin/nav_payroll.dart';
import 'package:genesis/navs/admin/nav_reports.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/navs/admin/fleet_tracking.dart';
import 'package:genesis/widgets/layouts/side_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDeskop = MediaQuery.of(context).size.width > 500;
    // Using a Row to create a persistent Sidebar + Content layout common in ERPs
    return Scaffold(
      drawer: !isDeskop ? GNavBar(selectedIndex: _selectedIndex) : null,
      backgroundColor: GTheme.surface(),
      body: SafeArea(
        child: [
          if (isDeskop) ...[GNavBar(selectedIndex: _selectedIndex)],
          AdminNavPayroll(),
        ].row(),
      ),
    );
  }

  // --- Sidebar Widget ---
}
