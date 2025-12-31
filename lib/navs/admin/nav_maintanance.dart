import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/screens/maintainance/maintainance_add.dart';
import 'package:genesis/widgets/actions/filter_chip.dart';
import 'package:genesis/widgets/layouts/maintanance_card.dart';
import 'package:get/get.dart';

class AdminNavMaintenance extends StatefulWidget {
  const AdminNavMaintenance({super.key});

  @override
  State<AdminNavMaintenance> createState() => _AdminNavMaintenanceState();
}

class _AdminNavMaintenanceState extends State<AdminNavMaintenance> {
  // Mock Maintenance Data
  final List<Map<String, dynamic>> maintenanceTasks = [
    {
      "model": "Tesla Model 3",
      "id": "TX-902",
      "issue": "Tire Rotation",
      "health": 88,
      "urgency": "Routine",
      "daysLeft": 12,
      "cost": 120.00,
      "color": Colors.blue,
    },
    {
      "model": "Toyota Hilux",
      "id": "BD-441",
      "issue": "Brake Pad Replacement",
      "health": 24,
      "urgency": "Critical",
      "daysLeft": 0,
      "cost": 450.00,
      "color": Colors.red,
    },
    {
      "model": "Mercedes Sprinter",
      "id": "GH-110",
      "issue": "Engine Oil Change",
      "health": 45,
      "urgency": "Due Soon",
      "daysLeft": 2,
      "cost": 85.00,
      "color": Colors.orange,
    },
  ];

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

        // === MAINTENANCE LIST ===
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  GMaintananceCard(task: maintenanceTasks[index]),
              childCount: maintenanceTasks.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
  }
}
