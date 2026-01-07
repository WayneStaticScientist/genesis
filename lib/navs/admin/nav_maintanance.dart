import 'package:genesis/controllers/maintainance_controller.dart';
import 'package:genesis/widgets/displays/error_widget.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/screens/maintainance/maintainance_add.dart';
import 'package:genesis/widgets/actions/filter_chip.dart';
import 'package:genesis/widgets/layouts/maintanance_card.dart';

class AdminNavMaintenance extends StatefulWidget {
  const AdminNavMaintenance({super.key});

  @override
  State<AdminNavMaintenance> createState() => _AdminNavMaintenanceState();
}

class _AdminNavMaintenanceState extends State<AdminNavMaintenance> {
  // Mock Maintenance Data
  final _maintainanceController = Get.find<MaintainanceController>();
  @override
  void initState() {
    super.initState();
    _maintainanceController.fetchAllMaintainances();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // === PREMIUM HEADER ===
        SliverAppBar(
          expandedHeight: 160,
          floating: true,
          pinned: true,
          elevation: 0,
          backgroundColor: const Color(0xFF0F172A),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            title: const Text(
              "Maintenance Vault",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Get.to(() => AdminAddMaintenance()),
              icon: Icon(Icons.add),
            ),
          ],
        ),

        // === URGENCY FILTER BUTTONS ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GFilterChip(label: "All Tasks", isSelected: true),
                  GFilterChip(
                    label: "Critical",
                    isSelected: false,
                    color: Colors.red,
                  ),
                  GFilterChip(
                    label: "Upcoming",
                    isSelected: false,
                    color: Colors.orange,
                  ),
                  GFilterChip(
                    label: "Completed",
                    isSelected: false,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() {
          if (_maintainanceController.loadingMaintainances.value &&
              _maintainanceController.maintainances.isEmpty) {
            return SliverFillRemaining(child: MaterialLoader().center());
          }
          if (_maintainanceController
              .mantainanceFetchingStatus
              .value
              .isNotEmpty) {
            return SliverFillRemaining(
              child: MaterialErrorWidget(
                label: _maintainanceController.mantainanceFetchingStatus.value,
              ).center(),
            );
          }
          if (_maintainanceController.maintainances.isEmpty &&
              !_maintainanceController.loadingMaintainances.value) {
            return SliverFillRemaining(
              child: "No results found for maintainances".text(),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => GMaintananceCard(
                  task: _maintainanceController.maintainances[index],
                ),
                childCount: _maintainanceController.maintainances.length,
              ),
            ),
          );
        }),
        // === MAINTENANCE LIST ===
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
  }
}
