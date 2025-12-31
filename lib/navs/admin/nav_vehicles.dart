import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/screens/vehicles/vehicles_add.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/layouts/main_stat_card.dart';
import 'package:genesis/widgets/layouts/vehicle_cards.dart';
import 'package:get/get.dart';

class AdminNavVehicles extends StatefulWidget {
  const AdminNavVehicles({super.key});

  @override
  State<AdminNavVehicles> createState() => _AdminNavVehiclesState();
}

class _AdminNavVehiclesState extends State<AdminNavVehicles> {
  // Mock Data for the "Wow" factor
  final List<Map<String, dynamic>> vehicles = [
    {
      "model": "Tesla Model 3",
      "plate": "AE-9021-X",
      "status": "Active",
      "cost": 0.15,
      "usage": 85,
      "driver": "Alex Johnson",
      "type": "Electric",
    },
    {
      "model": "Toyota Hilux",
      "plate": "BD-4412-Z",
      "status": "In Service",
      "cost": 0.45,
      "usage": 40,
      "driver": "Sarah Smith",
      "type": "Diesel",
    },
    {
      "model": "Mercedes Sprinter",
      "plate": "GH-1102-M",
      "status": "Idle",
      "cost": 0.65,
      "usage": 10,
      "driver": "Unassigned",
      "type": "Petrol",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // === PREMIUM HEADER ===
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          backgroundColor: GTheme.color(),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            title: "Fleet Management".text(
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha(25),
                child: IconButton(
                  onPressed: () => Get.to(() => AdminAddVehicle()),
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),

        // === METRIC OVERVIEW CARDS ===
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                GMainStatCard(
                  title: "Total Fleet",
                  value: "24",
                  icon: Icons.car_repair,
                  color: Colors.blue,
                ),
                GMainStatCard(
                  title: "Active Now",
                  value: "18",
                  icon: Icons.location_on,
                  color: Colors.green,
                ),
                GMainStatCard(
                  title: "Maintenance",
                  value: "4",
                  icon: Icons.build_circle,
                  color: Colors.orange,
                ),
                GMainStatCard(
                  title: "Cost/KM",
                  value: "\$0.32",
                  icon: Icons.alternate_email,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ),

        // === SEARCH & FILTER ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: GTheme.color(),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Search plate or model...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GTheme.color(),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.filter_list, color: GTheme.reverse()),
                ),
              ],
            ),
          ),
        ),

        // === VEHICLE LIST ===
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => GVehicleCard(vehicle: vehicles[index]),
              childCount: vehicles.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
  }
}
