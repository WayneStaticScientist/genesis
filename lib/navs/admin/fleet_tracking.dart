import 'dart:async';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/utils/screen_sizes.dart';
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
import 'package:genesis/utils/toast.dart';

class FleetTrackingScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const FleetTrackingScreen({super.key, this.triggerKey});

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
  late User? user;
  @override
  void initState() {
    super.initState();
    user = User.fromStorage();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    if (user?.role == "driver") {
      _vehicleController.fetchAllVehicles(
        driverId: _userController.user.value?.id ?? "---",
      );
    }

    _locationWorker = ever(_socketController.liveTrackModel, (data) async {
      if (data != null) {
        final controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newLatLng(LatLng(data.lat, data.lng)),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((e) {
      if (user?.trip?.status == "Pending" && user?.role == "driver") {
        _alartPendingTrip();
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
    _socketController.listenId.value = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDeskop = MediaQuery.of(context).size.width > ScreenSizes.DESKTOP_W;
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
                        onPressed: () {
                          widget.triggerKey?.currentState?.openDrawer();
                        },
                        style: ButtonStyle(
                          iconColor: WidgetStateProperty.all(Colors.black87),
                          backgroundColor: WidgetStateProperty.all(
                            Colors.white,
                          ),
                        ),
                      )
                      .decoratedBox(
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
                      )
                      .visibleIf(widget.triggerKey != null && !isDeskop),
            ),
          ),

          // 3. ACTIVE ASSETS CAROUSEL (Simplified)

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
                        final user = _socketController.liveTrackDriver.value;
                        final isOnTrip = (user?.trip?.status == "Active");
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
                        ).visibleIf(
                          _socketController.liveTrackDriver.value != null,
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
                            child: Obx(
                              () => _buildTelemetryItem(
                                LineIcons.gasPump,
                                "${_socketController.liveTrackModel.value != null ? _socketController.liveTrackModel.value?.fuelLevel ?? 0 : _socketController.currentVehicle.value?.fuelLevel ?? 0}%",
                                "Fuel (Tap)",
                              ),
                            ),
                          ),
                          Obx(() {
                            final date = _socketController
                                .liveTrackModel
                                .value
                                ?.timestamp;
                            bool online = false;
                            String label = "Offline";
                            if (date != null) {
                              final difference =
                                  DateTime.now().millisecondsSinceEpoch -
                                  date.millisecondsSinceEpoch;
                              if (difference < 5000 * 60) {
                                online = true;
                              }
                              if (difference < 1000 * 60 * 60) {
                                label = "${difference ~/ (1000 * 60)} mins ago";
                              } else if (difference < 1000 * 60 * 60 * 24) {
                                label =
                                    "${difference ~/ (1000 * 60 * 60)} hrs ago";
                              } else {
                                label = "offTrip";
                              }
                            }
                            return _buildTelemetryItem(
                              LineIcons.clock,
                              online ? "online" : label,
                              "status",
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // === ANIMATED TRIP BUTTON ===
                      Obx(() {
                        final user = _userController.user.value;
                        final isOnTrip = (user?.trip?.status == 'Active');
                        return PingingStopButton(
                          isLoading: _userController.processingTrip.value,
                          isOnTrip: isOnTrip,
                          pingAnimation: _pingController,
                          onPressed: () => isOnTrip
                              ? _showEndTripDialog()
                              : _showStartTripDialog(),
                        ).visibleIf(
                          user?.role == 'driver' && user?.trip != null,
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
      textCancel: "close",
      onConfirm: () async {
        final fuelValue = double.tryParse(_refuelLevelController.text);
        double? costs = 0;
        if (fuelValue == null || fuelValue < 0 || fuelValue > 100) {
          return Toaster.showError(
            "invalid number , number should be between 0 and 100%",
          );
        }
        if (isRefuel) {
          costs = double.tryParse(_refuelCostController.text);
          if (costs == null) {
            return Toaster.showError("invalid costs number ");
          }
        }
        Get.back();
        final vehicle = !isRefuel
            ? await _vehicleController.updateFuelLevel(fuelValue)
            : await _vehicleController.refuelVehicle(
                level: fuelValue,
                cost: costs,
              );
        if (vehicle != null) {
          _socketController.currentVehicle.value = vehicle;
        }
      },
    );
  }

  void _showStartTripDialog() {
    if (_socketController.currentVehicle.value == null) {
      return Toaster.showError("wait vehicle still inititializing please wait");
    }
    Get.defaultDialog(
      title: "Start Trip",
      content:
          "start trip with vehicle ${_socketController.currentVehicle.value?.carModel}"
              .text(),
      textCancel: "close",
      onConfirm: () {
        Get.back();
        _handleTripAction(true);
      },
    );
  }

  Future<void> _handleTripAction(bool starting) async {
    final res = await _userController.confirmStartTrip();
    if (res) {
      Toaster.showSuccess("Tracking started");
      _socketController.listenId.value =
          _userController.user.value?.currentVehicle?.carModel ?? '';
    }
  }

  _showEndTripDialog() {
    if (_socketController.currentVehicle.value == null) {
      return Toaster.showError("wait vehicle still inititializing please wait");
    }
    Get.defaultDialog(
      title: "End Trip",
      content:
          "End trip with vehicle ${_socketController.currentVehicle.value?.carModel}"
              .text(),
      onConfirm: () async {
        Get.back();
        final res = await _userController.endTrip(
          data: {"endTime": DateTime.now().toIso8601String()},
        );
        if (res) {
          Toaster.showSuccess("Trip Stopped");
          _userController.user.refresh();
        }
      },
    );
  }

  void _alartPendingTrip() {
    Get.defaultDialog(
      title: "Pending Trip",
      content:
          "You have been assigned a trip to go to , Confirm the trip when you are ready to go"
              .text(),
      textCancel: "Close",
      textConfirm: "Confirm",
      onConfirm: () {
        Get.back();
        _handleTripAction(true);
      },
    );
  }
}

// === CUSTOM COMPONENT: PINGING STOP BUTTON ===
