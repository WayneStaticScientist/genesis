import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/controllers/vehicle_controller.dart';

class FleetTrackingScreen extends StatefulWidget {
  const FleetTrackingScreen({super.key});

  @override
  State<FleetTrackingScreen> createState() => _FleetTrackingScreenState();
}

class _FleetTrackingScreenState extends State<FleetTrackingScreen> {
  final _vehicleController = Get.find<VehicleControler>();
  final _userController = Get.find<UserController>();

  // Controllers for the Trip Dialog
  final _timeController = TextEditingController();
  final _fuelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vehicleController.fetchAllVehicles(
      driverId: _userController.user.value?.id ?? "---",
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // === 1. MOCK MAP LAYER ===
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              image: DecorationImage(
                image: const NetworkImage(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=2074&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),

          // === 2. TOP NAVIGATION ===
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  DrawerButton(color: Colors.white).decoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withAlpha(25)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === 3. ACTIVE ASSETS CAROUSEL ===
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            height: 100,
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _vehicleController.vehicles.length,
                itemBuilder: (context, index) {
                  final item = _vehicleController.vehicles[index];
                  final isCurrent =
                      item.id == _userController.user.value?.currentVehicle;
                  return _buildActiveAssetTile(
                    item.carModel,
                    item.licencePlate,
                    isCurrent,
                  ).onTap(() {
                    if (!isCurrent) {
                      _openSetupCurrentVehicle(item);
                    }
                  });
                },
              ),
            ),
          ),

          // === 4. DRAGGABLE BOTTOM SHEET ===
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      // Driver Info
                      Obx(() {
                        final user = _userController.user.value;
                        final isOnTrip = (user?.trip ?? "").isNotEmpty;
                        return Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?u=marcus',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${user?.firstName ?? 'Driver'} ${user?.lastName ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isOnTrip ? "On Trip" : "Idle",
                                    style: TextStyle(
                                      color: isOnTrip
                                          ? Colors.green
                                          : Colors.grey,
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
                        );
                      }),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.withAlpha(50)),
                      const SizedBox(height: 24),

                      // Telemetry
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTelemetryItem(
                            LineIcons.lightningBolt,
                            "84 km/h",
                            "Speed",
                          ),
                          _buildTelemetryItem(LineIcons.gasPump, "62%", "Fuel"),
                          _buildTelemetryItem(
                            LineIcons.clock,
                            "14 min",
                            "Arrival",
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Start/Stop Logic
                      Obx(() {
                        final user = _userController.user.value;
                        final isOnTrip = (user?.trip ?? "").isNotEmpty;

                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  isOnTrip ? LineIcons.stop : LineIcons.play,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  isOnTrip ? "Stop Trip" : "Start Trip",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOnTrip
                                      ? Colors.red
                                      : Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  if (isOnTrip) {
                                    _handleTripAction(false);
                                  } else {
                                    _showStartTripDialog();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showStartTripDialog() {
    _timeController.clear();
    _fuelController.clear();

    Get.defaultDialog(
      title: "Start Trip",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const Text(
              "Enter estimates to begin tracking",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Estimated Time (min)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _fuelController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Current Fuel Level (%)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      textCancel: "Cancel",
      textConfirm: "Start",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () {
        if (_timeController.text.isEmpty || _fuelController.text.isEmpty) {
          Toaster.showError("Please fill all fields");
          return;
        }
        Get.back();
        _handleTripAction(true);
      },
    );
  }

  Future<void> _handleTripAction(bool starting) async {
    final response = await _userController.startTrip(
      data: {
        "startTime": (DateTime.now().toIso8601String()),
        if (starting) "estimatedTime": _timeController.text,
        if (starting) "startFuelLevel": _fuelController.text,
      },
    );

    if (response) {
      Toaster.showSuccess(
        starting ? "Trip started successfully" : "Trip stopped",
      );
      setState(() {});
      _userController.user.refresh();
    }
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
          const Icon(LineIcons.car, color: Colors.white, size: 24),
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

  void _openSetupCurrentVehicle(VehicleModel item) {
    Get.defaultDialog(
      title: "Set As Current",
      middleText: "Set ${item.carModel} as vehicle for your current trip?",
      textCancel: "Close",
      textConfirm: "Yes",
      onConfirm: () async {
        Get.back();
        final response = await _userController.updateMyStatus(
          data: {
            ..._userController.user.value!.toJSON(),
            "currentVehicle": item.id,
          },
          id: _userController.user.value!.id!,
          updateCurrent: true,
        );
        if (response && mounted) {
          Toaster.showSuccess("Vehicle updated");
          _vehicleController.vehicles.refresh();
          _userController.user.refresh();
        }
      },
    );
  }
}
