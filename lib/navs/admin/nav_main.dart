import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/layouts/stat_card.dart';
import 'package:genesis/widgets/layouts/main_header.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/widgets/displays/error_widget.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:genesis/widgets/layouts/vehicle_list_item.dart';

class AdminNavMain extends StatefulWidget {
  const AdminNavMain({super.key});

  @override
  State<AdminNavMain> createState() => _AdminNavMainState();
}

class _AdminNavMainState extends State<AdminNavMain> {
  final _statsController = Get.find<StatsController>();

  @override
  void initState() {
    super.initState();
    _statsController.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_statsController.isLoading.value) {
        return MaterialLoader().center();
      }
      if (_statsController.errorState.value.isNotEmpty ||
          _statsController.stats.value == null) {
        return MaterialErrorWidget(
          label: 'Failed to load statistics.',
          onRetry: () {
            _statsController.fetchStats();
          },
        ).center();
      }
      return _buildStats(context);
    });
  }

  Widget _buildStats(BuildContext context) {
    return Column(
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
                      children: [
                        ModernStatCard(
                          title: "Total Fleet",
                          value:
                              _statsController
                                  .stats
                                  .value
                                  ?.totalVehiclesInSystem
                                  .toString() ??
                              "0",
                          icon: Icons.directions_car,
                          gradientColors: [Colors.blue, Colors.blueAccent],
                          trend: "+12%",
                          subtitle: '',
                        ),
                        ModernStatCard(
                          title: "Active Drivers",
                          value:
                              _statsController.stats.value?.totalDriversInSystem
                                  .toString() ??
                              "0",
                          icon: Icons.person_pin_circle,
                          gradientColors: [Colors.green, Colors.greenAccent],
                          trend: "+5%",
                          subtitle: '',
                        ),
                        ModernStatCard(
                          title: "Maintenance",
                          value:
                              _statsController
                                  .stats
                                  .value
                                  ?.totalMaintenanceCount
                                  .toString() ??
                              "0",
                          icon: Icons.build_circle,
                          gradientColors: [Colors.orange, Colors.orangeAccent],
                          trend: "-2%",
                          subtitle: '',
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
                            "List of Vehicles",
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
                      ..._statsController.stats.value!.vehicleDetails
                          .map(
                            (vehicle) => VehicleListItem(
                              status: vehicle.status,
                              vehicle: vehicle.model,
                              driver: vehicle.driverName,
                              statusColor:
                                  vehicle.status.toLowerCase() ==
                                      'in maintenance'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Header Widget ---
}

// --- Stat Card Widget ---
