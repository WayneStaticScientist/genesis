import 'package:genesis/utils/bool_utils.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/screens/stats/vehicle_stats.dart';
import 'package:line_icons/line_icons.dart';

class GVehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback? onTrackLive;
  const GVehicleCard({super.key, required this.vehicle, this.onTrackLive});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (vehicle.status) {
      case 'Active':
        statusColor = Colors.green;
        statusIcon = Icons.sensors;
        break;
      case 'In Service':
        statusColor = Colors.orange;
        statusIcon = Icons.build_circle_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.power_settings_new_rounded;
    }

    final driverName = vehicle.driver != null
        ? "${vehicle.driver!.firstName} ${vehicle.driver!.lastName}"
        : "No Driver Assigned";

    final hasTracker =
        vehicle.trackerId != null && vehicle.trackerId!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: GTheme.isDark(
            context,
          ).lord(Colors.white12, Colors.black.withAlpha(10)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Header)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Vehicle Icon wrapper
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withAlpha(30),
                          statusColor.withAlpha(10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      vehicle.engineType == "Electric"
                          ? LineIcons.lightningBolt
                          : LineIcons.car,
                      color: statusColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.carModel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: GTheme.reverse(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                vehicle.licencePlate,
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (hasTracker)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.satellite_alt_rounded,
                                      size: 10,
                                      color: Colors.purple,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "GPS ACTIVE",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withAlpha(40),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          vehicle.status.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, indent: 20, endIndent: 20),

            // Mid Info Grid
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildGridItem(
                        context,
                        icon: LineIcons.user,
                        label: "Driver",
                        value: driverName,
                        valueColor: vehicle.driver == null
                            ? Colors.redAccent
                            : null,
                      ),
                      const SizedBox(width: 16),
                      _buildGridItem(
                        context,
                        icon: LineIcons.gasPump,
                        label: "Engine & Fuel",
                        value:
                            "${vehicle.engineType} (${vehicle.fuelRatio} L/km)",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildGridItem(
                        context,
                        icon: LineIcons.satellite,
                        label: "Hardware GPS ID",
                        value: hasTracker
                            ? vehicle.trackerId!
                            : "Fallback (Phone)",
                        valueColor: !hasTracker ? Colors.orange : null,
                      ),
                      const SizedBox(width: 16),
                      _buildGridItem(
                        context,
                        icon: LineIcons.road,
                        label: "Mileage",
                        value: "${vehicle.mileage.toStringAsFixed(0)} km",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Fuel Level / Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fuel Status",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        "${vehicle.fuelLevel.toStringAsFixed(0)}%",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: vehicle.fuelLevel < 20
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: vehicle.fuelLevel / 100,
                      backgroundColor: GTheme.isDark(
                        context,
                      ).lord(Colors.white10, Colors.grey.shade100),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        vehicle.fuelLevel < 20 ? Colors.red : Colors.green,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: GTheme.isDark(
                context,
              ).lord(Colors.white10.withAlpha(5), Colors.black.withAlpha(5)),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.to(
                        () => VehicleDetailStatsScreen(vehicle: vehicle),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: GTheme.isDark(
                              context,
                            ).lord(Colors.white12, Colors.grey.shade300),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "View Statistics",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: GTheme.reverse(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTrackLive,
                      icon: const Icon(Icons.gps_fixed, size: 14),
                      label: const Text("Track Live"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).onTap(() => Get.to(() => VehicleDetailStatsScreen(vehicle: vehicle)));
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? GTheme.reverse(context),
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
