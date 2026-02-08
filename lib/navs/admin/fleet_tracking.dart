import 'dart:async';
import 'package:genesis/widgets/actions/pinging_button.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:exui/exui.dart';

// Project specific imports
import 'package:genesis/controllers/socket_controller.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/controllers/vehicle_controller.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/utils/toast.dart';

class FleetTrackingScreen extends StatefulWidget {
  const FleetTrackingScreen({super.key});

  @override
  State<FleetTrackingScreen> createState() => _FleetTrackingScreenState();
}

class _FleetTrackingScreenState extends State<FleetTrackingScreen>
    with SingleTickerProviderStateMixin {
  final _userController = Get.find<UserController>();
  final _socketController = Get.find<SocketController>();
  final _vehicleController = Get.find<VehicleControler>();

  final Completer<GoogleMapController> _mapController = Completer();
  Worker? _locationWorker;

  final _timeController = TextEditingController();
  final _fuelController = TextEditingController();
  final _refuelLevelController = TextEditingController();
  final _refuelCostController = TextEditingController();

  // Animation Controller for the "Pinging" effect
  late AnimationController _pingController;

  static const _defaultLocation = LatLng(-17.824858, 31.053028);

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _vehicleController.fetchAllVehicles(
      driverId: _userController.user.value?.id ?? "---",
    );

    _locationWorker = ever(_socketController.liveTrackModel, (data) async {
      if (data != null) {
        final controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newLatLng(LatLng(data.lat, data.lng)),
        );
      }
    });
  }

  @override
  void dispose() {
    _pingController.dispose();
    _locationWorker?.dispose();
    _timeController.dispose();
    _fuelController.dispose();
    _refuelLevelController.dispose();
    _refuelCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. GOOGLE MAP LAYER
          Obx(() {
            final liveData = _socketController.liveTrackModel.value;
            final hasData = liveData != null;
            final currentPos = hasData
                ? LatLng(liveData.lat, liveData.lng)
                : _defaultLocation;

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentPos,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                if (hasData)
                  controller.moveCamera(CameraUpdate.newLatLng(currentPos));
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              markers: {
                if (hasData)
                  Marker(
                    markerId: const MarkerId('live_vehicle'),
                    position: currentPos,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
              },
            );
          }),

          // 2. TOP NAVIGATION
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child:
                  DrawerButton(
                    style: ButtonStyle(
                      iconColor: WidgetStateProperty.all(Colors.black87),
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ).decoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
            ),
          ),

          // 3. ACTIVE ASSETS CAROUSEL (Simplified)
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
                    if (!isCurrent) _openSetupCurrentVehicle(item);
                  });
                },
              ),
            ),
          ),

          // 4. DRAGGABLE BOTTOM SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Handle
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
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                LineIcons.phone,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 24),
                      // Telemetry Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => _buildTelemetryItem(
                              LineIcons.lightningBolt,
                              "${_socketController.liveTrackModel.value?.speed.toStringAsFixed(2) ?? '0'}km/h",
                              "Speed",
                            ),
                          ),
                          GestureDetector(
                            onTap: _showFuelManagementOptions,
                            child: _buildTelemetryItem(
                              LineIcons.gasPump,
                              "${_socketController.liveTrackModel.value?.fuelLevel ?? 0}%",
                              "Fuel (Tap)",
                            ),
                          ),
                          _buildTelemetryItem(
                            LineIcons.clock,
                            "14 min",
                            "Arrival",
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // === ANIMATED TRIP BUTTON ===
                      Obx(() {
                        final user = _userController.user.value;
                        final isOnTrip = (user?.trip ?? "").isNotEmpty;

                        return PingingStopButton(
                          isOnTrip: isOnTrip,
                          pingAnimation: _pingController,
                          onPressed: () => isOnTrip
                              ? _showEndTripDialog()
                              : _showStartTripDialog(),
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

  // --- WIDGET HELPERS ---

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

  Widget _buildActiveAssetTile(String model, String id, bool isSelected) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LineIcons.car, color: Colors.white),
          Text(
            model,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(id, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  // --- LOGIC FUNCTIONS ---

  void _showFuelManagementOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Fuel Management",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _fuelActionCard(
                    icon: LineIcons.edit,
                    label: "Update",
                    color: Colors.orange,
                    onTap: () {
                      Get.back();
                      _showUpdateFuelDialog(false);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _fuelActionCard(
                    icon: LineIcons.gasPump,
                    label: "Refuel",
                    color: Colors.green,
                    onTap: () {
                      Get.back();
                      _showUpdateFuelDialog(true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fuelActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  void _showUpdateFuelDialog(bool isRefuel) {
    Get.defaultDialog(
      title: isRefuel ? "Refuel Cost" : "Update Fuel",
      content: Column(
        children: [
          TextField(
            controller: _refuelLevelController,
            decoration: const InputDecoration(labelText: "Level %"),
          ),
          if (isRefuel)
            TextField(
              controller: _refuelCostController,
              decoration: const InputDecoration(labelText: "Cost \$"),
            ),
        ],
      ),
      onConfirm: () {
        Get.back();
        Toaster.showSuccess("Saved");
      },
    );
  }

  void _showStartTripDialog() {
    Get.defaultDialog(
      title: "Start Trip",
      onConfirm: () {
        Get.back();
        _handleTripAction(true);
      },
    );
  }

  Future<void> _handleTripAction(bool starting) async {
    final res = await _userController.startTrip(
      data: {"startTime": DateTime.now().toIso8601String()},
    );
    if (res) {
      Toaster.showSuccess(starting ? "Tracking started" : "Trip stopped");
      _userController.user.refresh();
    }
  }

  void _openSetupCurrentVehicle(VehicleModel item) {
    Get.defaultDialog(
      title: "Switch Vehicle",
      onConfirm: () {
        Get.back();
        _userController.user.refresh();
      },
    );
  }

  _showEndTripDialog() {
    Get.defaultDialog(
      title: "End Trip",
      content: Column(
        children: [
          TextField(
            controller: _refuelLevelController,
            decoration: const InputDecoration(labelText: "Fuel Level %"),
          ),
        ],
      ),
      onConfirm: () {
        Get.back();
        Toaster.showSuccess("Saved");
      },
    );
  }
}

// === CUSTOM COMPONENT: PINGING STOP BUTTON ===
