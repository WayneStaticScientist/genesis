import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/layouts/main_header.dart';
import 'package:genesis/widgets/layouts/stat_card.dart';
import 'package:genesis/widgets/layouts/vehicle_list_item.dart';

class AdminNavMain extends StatefulWidget {
  const AdminNavMain({super.key});

  @override
  State<AdminNavMain> createState() => _AdminNavMainState();
}

class _AdminNavMainState extends State<AdminNavMain> {
  @override
  Widget build(BuildContext context) {
    return
    // 2. Main Content Area
    Expanded(
      child: Column(
        children: [
          GMainHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Title
                  const Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Statistics Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 1100
                          ? 4
                          : constraints.maxWidth > 700
                          ? 2
                          : 1;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.6,
                        children: const [
                          StatCard(
                            title: "Total Fleet",
                            value: "142",
                            icon: Icons.directions_car,
                            color: Colors.blue,
                            trend: "+12%",
                          ),
                          StatCard(
                            title: "Active Drivers",
                            value: "86",
                            icon: Icons.person_pin_circle,
                            color: Colors.green,
                            trend: "+5%",
                          ),
                          StatCard(
                            title: "Maintenance",
                            value: "8",
                            icon: Icons.build_circle,
                            color: Colors.orange,
                            trend: "-2%",
                          ),
                          StatCard(
                            title: "Fuel Costs",
                            value: "\$12k",
                            icon: Icons.local_gas_station,
                            color: Colors.red,
                            trend: "+1.2%",
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Lower Section: Active Vehicles Table / Map Placeholder
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: GTheme.color(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Live Vehicle Status",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_horiz),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        VehicleListItem(
                          vehicle: "Toyota Hilux - G42",
                          driver: "Wayne (Driver)",
                          status: "En Route",
                          statusColor: Colors.green,
                        ),
                        VehicleListItem(
                          vehicle: "Ford Ranger - X99",
                          driver: "Sarah (Driver)",
                          status: "Idle",
                          statusColor: Colors.amber,
                        ),
                        VehicleListItem(
                          vehicle: "Isuzu NPR - T11",
                          driver: "Mike (Driver)",
                          status: "Maintenance",
                          statusColor: Colors.red,
                        ),
                        VehicleListItem(
                          vehicle: "Nissan NV350 - B22",
                          driver: "John (Driver)",
                          status: "En Route",
                          statusColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Widget ---
}

// --- Stat Card Widget ---
