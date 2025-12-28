import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

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
                  _buildFilterChip("All Tasks", true),
                  _buildFilterChip("Critical", false, color: Colors.red),
                  _buildFilterChip("Upcoming", false, color: Colors.orange),
                  _buildFilterChip("Completed", false, color: Colors.green),
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
                  _buildMaintenanceCard(maintenanceTasks[index]),
              childCount: maintenanceTasks.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected, {
    Color color = Colors.blue,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isSelected ? color : Colors.grey.shade200),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> task) {
    bool isCritical = task['urgency'] == 'Critical';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: task['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(LineIcons.cog, color: task['color'], size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['model'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "ID: ${task['id']}",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isCritical ? "IMMEDIATE" : "IN ${task['daysLeft']} DAYS",
                      style: TextStyle(
                        color: task['color'],
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${task['cost']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Health Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task['issue'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "${task['health']}% Health",
                      style: TextStyle(
                        color: task['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: task['health'] / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(task['color']),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(LineIcons.fileInvoice, size: 18),
                    label: const Text("View History"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCritical ? Colors.red : Colors.white,
                      foregroundColor: isCritical
                          ? Colors.white
                          : Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isCritical ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Approve",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
