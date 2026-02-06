import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/controllers/vehicle_controller.dart';
import 'package:genesis/utils/theme.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

class FleetTrackingScreen extends StatefulWidget {
  const FleetTrackingScreen({super.key});

  @override
  State<FleetTrackingScreen> createState() => _FleetTrackingScreenState();
}

class _FleetTrackingScreenState extends State<FleetTrackingScreen> {
  // Assuming controller exists in your project setup
  final _vehicleController = Get.find<VehicleControler>();
  final _userController = Get.find<UserController>();
  @override
  void initState() {
    super.initState();
    _vehicleController.fetchAllVehicles(
      driverId: _userController.user.value?.role ?? "driver",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // === 1. MOCK MAP LAYER ===
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=2074&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
              opacity:
                  0.6, // Increased opacity slightly for better visibility when sheet is down
            ),
          ),
        ),

        // === 2. TOP NAVIGATION & SEARCH ===
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                DrawerButton().decoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withAlpha(25)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),

        // === 3. ACTIVE ASSETS CAROUSEL (Horizontal) ===
        // We wrap this in a Positioned to ensure it stays behind the sheet when expanded
        Positioned(
          top: 120,
          left: 0,
          right: 0,
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildActiveAssetTile("Tesla M3", "TX-902", true),
              _buildActiveAssetTile("Hino Truck", "HK-112", false),
              _buildActiveAssetTile("BMW i8", "BZ-441", false),
            ],
          ),
        ),

        // === 4. DRAGGABLE BOTTOM SHEET ===
        DraggableScrollableSheet(
          initialChildSize:
              0.45, // Starts at 45% height (same as your original fixed height)
          minChildSize: 0.15, // Can be dragged down to see more map
          maxChildSize: 0.92, // Can be dragged up to almost full screen
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: GTheme.color(), // Your theme color
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(70),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              // We use the scrollController provided by DraggableScrollableSheet
              // This connects the scroll gesture to the sheet expansion
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Driver Info Header
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?u=marcus',
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Marcus Wright",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "On Route: Downtown Delivery",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LineIcons.phone,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Divider(color: Colors.grey.withAlpha(50)),
                    const SizedBox(height: 24),

                    // Live Telemetry Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTelemetryItem(
                          LineIcons.lightningBolt,
                          "84 km/h",
                          "Current Speed",
                        ),
                        _buildTelemetryItem(
                          LineIcons.gasPump,
                          "62%",
                          "Fuel Level",
                        ),
                        _buildTelemetryItem(
                          LineIcons.clock,
                          "14 min",
                          "Est. Arrival",
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Progress Bar
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progress",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "75%",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        minHeight: 8,
                        backgroundColor: Colors.blue.shade50,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "View Full Itinerary",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Added extra space at bottom for scrolling feel when expanded
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ).expanded1;
  }

  Widget _buildActiveAssetTile(String model, String id, bool isSelected) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.white.withAlpha(25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LineIcons.car, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            model,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            id,
            style: TextStyle(color: Colors.white.withAlpha(135), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
