import 'package:genesis/widgets/displays/error_widget.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:genesis/screens/pilots/drivers_add.dart';
import 'package:genesis/widgets/layouts/driver_card.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/widgets/layouts/quick_stats.dart';

class AdminNavDrivers extends StatefulWidget {
  const AdminNavDrivers({super.key});
  @override
  State<AdminNavDrivers> createState() => _AdminNavDriversState();
}

class _AdminNavDriversState extends State<AdminNavDrivers> {
  final _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _userController.fetchDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // === LUXURY HEADER ===
        SliverAppBar(
          expandedHeight: 140,
          floating: true,
          pinned: true,
          backgroundColor: const Color(0xFF1A1D1E),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            title: const Text(
              "Fleet Pilots",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1D1E), Color(0xFF2C3E50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Iconify(Bx.group, color: Colors.white.withAlpha(30)),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Get.to(() => AdminAddDriver()),
              icon: Icon(Icons.add),
            ),
          ],
        ),

        // === QUICK STATS BAR ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GQuickStats(label: "Active", value: "12", color: Colors.green),
                GQuickStats(label: "Resting", value: "05", color: Colors.blue),
                GQuickStats(
                  label: "Top Rated",
                  value: "08",
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),

        // === DRIVERS LIST ===
        Obx(() {
          if (_userController.loadingDrivers.value &&
              _userController.drivers.isEmpty) {
            return SliverFillRemaining(child: MaterialLoader().center());
          }
          if (_userController.driversResponse.value.isNotEmpty) {
            return SliverFillRemaining(
              child: MaterialErrorWidget(
                label: _userController.driversResponse.value,
              ).center(),
            );
          }
          if (_userController.drivers.isEmpty &&
              !_userController.loadingDrivers.value) {
            return SliverFillRemaining(
              child: "No results found for drivers".text(),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    GDriverCard(driver: _userController.drivers[index]),
                childCount: _userController.drivers.length,
              ),
            ),
          );
        }),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
  }
}
