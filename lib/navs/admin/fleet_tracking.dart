import 'dart:async';
import 'package:exui/material.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:line_icons/line_icons.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/utils/string_utils.dart';
import 'package:genesis/utils/screen_sizes.dart';
import 'package:genesis/utils/vehicle_utlis.dart';
import 'package:genesis/screens/chats/chat_screen.dart';
import 'package:genesis/models/populated_trip_model.dart';
import 'package:genesis/widgets/actions/pinging_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project specific imports
import 'package:genesis/utils/toast.dart';
import 'package:genesis/controllers/socket_controller.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/controllers/vehicle_controller.dart';

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
      if (data != null && _automaticTracking) {
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
    loadCustomMarker();
  }

  void loadCustomMarker() async {
    vehicleIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/car.png', // Path to your car image
    );
  }

  BitmapDescriptor? vehicleIcon;
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

  Destinations? _getCurrentDestination(PopulatedTripModel trip) {
    for (var dest in trip.destinations) {
      if (!dest.reached) {
        return dest;
      }
    }
    return trip.destinations.isNotEmpty ? trip.destinations.last : null;
  }

  bool _allDestinationsReached(PopulatedTripModel trip) {
    return trip.destinations.isEmpty ||
        trip.destinations.every((dest) => dest.reached);
  }

  Future<void> _updateTripDestinations(
    PopulatedTripModel trip,
    List<Destinations> destinations,
  ) async {
    final response = await Get.dialog(
      AlertDialog(
        title: "Update".text(),
        content: "Are you sure to update trip".text(),
        actions: [
          "No".text().textButton(onPressed: () => Get.back(result: false)),
          "Yes".text().textButton(onPressed: () => Get.back(result: true)),
        ],
      ),
    );
    if (!response) {
      return;
    }
    final success = await _userController.updateTripDestinations(
      tripId: trip.id,
      destinations: destinations
          .map(
            (dest) => {
              'name': dest.name,
              'reached': dest.reached,
              'location': dest.location?.toJson(),
            },
          )
          .toList(),
    );
    if (!success) return;
    final liveUser = _socketController.liveTrackDriver.value;
    if (liveUser != null && liveUser.trip?.id == trip.id) {
      liveUser.trip?.destinations.clear();
      liveUser.trip?.destinations.addAll(destinations);
      _socketController.liveTrackDriver.refresh();
    }

    if (_userController.user.value?.trip?.id == trip.id) {
      _userController.user.value?.trip?.destinations.clear();
      _userController.user.value?.trip?.destinations.addAll(destinations);
      _userController.user.refresh();
    }
  }

  Future<void> _markDestinationCompleted(
    PopulatedTripModel trip,
    int index,
  ) async {
    if (trip.destinations[index].reached) return;
    final updated = trip.destinations
        .map(
          (dest) => Destinations(
            name: dest.name,
            reached: dest.reached,
            location: dest.location,
          ),
        )
        .toList();
    updated[index] = Destinations(
      name: updated[index].name,
      reached: true,
      location: updated[index].location,
    );
    await _updateTripDestinations(trip, updated);
  }

  Future<void> _reorderDestination(
    PopulatedTripModel trip,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex) return;
    final updated = trip.destinations
        .map(
          (dest) => Destinations(
            name: dest.name,
            reached: dest.reached,
            location: dest.location,
          ),
        )
        .toList();
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    await _updateTripDestinations(trip, updated);
  }

  bool _automaticTracking = true;
  @override
  Widget build(BuildContext context) {
    final isDeskop = MediaQuery.of(context).size.width > ScreenSizes.DESKTOP_W;
    return Scaffold(
      body: Stack(
        children: [
          // 1. GOOGLE MAP LAYER
          Obx(() {
            final liveData = _socketController.liveTrackModel.value;
            final trip = _socketController.liveTrackDriver.value?.trip;
            final destinations = trip?.destinations ?? [];
            final destination = trip?.location;
            final origin = trip?.locationOrigin;
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
                if (destinations.isNotEmpty)
                  ...destinations
                      .asMap()
                      .entries
                      .map((entry) {
                        final idx = entry.key;
                        final dest = entry.value;
                        if (dest.location == null) return null;
                        return Marker(
                          markerId: MarkerId('destination_$idx'),
                          position: LatLng(
                            dest.location!.lat,
                            dest.location!.lng,
                          ),
                          infoWindow: InfoWindow(
                            title: 'Stop ${idx + 1}: ${dest.name}',
                            snippet: dest.reached ? 'Reached' : 'Pending',
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            dest.reached
                                ? BitmapDescriptor.hueGreen
                                : BitmapDescriptor.hueAzure,
                          ),
                        );
                      })
                      .whereType<Marker>()
                      .toSet(),
                if (destinations.isEmpty && destination != null)
                  Marker(
                    markerId: const MarkerId('green_marker_1'),
                    position: LatLng(destination.lat, destination.lng),
                    infoWindow: InfoWindow(
                      title: 'destination',
                      snippet: (trip?.destination).empty("not specified"),
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                if (origin != null)
                  Marker(
                    markerId: const MarkerId('red_marker_1'),
                    position: LatLng(origin.lat, origin.lng),
                    infoWindow: InfoWindow(
                      title: 'origin',
                      snippet: (trip?.origin).empty("not specified"),
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                if (hasData)
                  Marker(
                    markerId: const MarkerId('live_vehicle'),
                    position: currentPos,
                    rotation:
                        liveData.rotation, // Bearing from your GPS data (0-360)
                    anchor: const Offset(0.5, 0.5),
                    icon: vehicleIcon ?? BitmapDescriptor.defaultMarker,
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
          Positioned(
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _automaticTracking = !_automaticTracking;
                        });
                      },
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.all(Colors.black87),
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      icon: Icon(
                        Icons.camera,
                        color: _automaticTracking ? Colors.green : null,
                      ),
                    ).decoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: BoxBorder.all(
                          width: 4,
                          color: _automaticTracking
                              ? Colors.green
                              : Colors.transparent,
                        ),
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
          ),
          // 3. ACTIVE ASSETS CAROUSEL (Simplified)

          // 4. DRAGGABLE BOTTOM SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: GTheme.surface(context),
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
                        final liveData = _socketController.liveTrackModel.value;
                        final isOnTrip = (user?.trip?.status == "Active");
                        Duration? difference;
                        if (liveData != null) {
                          difference = DateTime.now().difference(
                            liveData.timestamp,
                          );
                        }
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              child: ("Driver".from(
                                user?.firstName,
                                user?.lastName,
                              ))[0].text(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Driver".from(
                                      user?.firstName,
                                      user?.lastName,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isOnTrip.lors(
                                      (liveData == null).lors(
                                        "Searching....",
                                        (liveData?.state == 'not-found').lors(
                                          "Idle",
                                          ((difference?.inMinutes ?? 0) < 2)
                                              .lors("Active", "Offline"),
                                        ),
                                      ),
                                      "Idle",
                                    ),
                                    style: TextStyle(
                                      color: isOnTrip.lorc(
                                        Colors.green,
                                        Colors.grey,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Get.to(() => ChatScreen(user: user!)),
                              icon: Icon(
                                LineIcons.commentAlt,
                                color: Theme.of(context).colorScheme.primary,
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
                          Obx(() {
                            final liveData =
                                _socketController.liveTrackModel.value;
                            Duration? difference;
                            if (liveData != null) {
                              difference = DateTime.now().difference(
                                liveData.timestamp,
                              );
                            }
                            return _buildTelemetryItem(
                              LineIcons.lightningBolt,
                              (difference == null).lors(
                                VehicleUtlis.speedToStandardUnits(0),
                                ((difference?.inMinutes ?? 0) > 2).lors(
                                  VehicleUtlis.speedToStandardUnits(0),
                                  "${VehicleUtlis.speedToStandardUnits(_socketController.liveTrackModel.value?.speed)}",
                                ),
                              ),
                              "Speed",
                            );
                          }),
                          GestureDetector(
                            onTap: _showFuelManagementOptions,
                            child: Obx(
                              () => _buildTelemetryItem(
                                LineIcons.gasPump,
                                "${_socketController.currentVehicle.value?.fuelLevel ?? 0}%",
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
                        final currentUser = _userController.user.value;
                        final isOnTrip =
                            (currentUser?.trip?.status == 'Active');
                        final canStop =
                            currentUser != null &&
                            currentUser.trip != null &&
                            _allDestinationsReached(currentUser.trip!);
                        return PingingStopButton(
                          isLoading: _userController.processingTrip.value,
                          isOnTrip: isOnTrip,
                          pingAnimation: _pingController,
                          onPressed: () => isOnTrip
                              ? _showEndTripDialog()
                              : _showStartTripDialog(),
                        ).visibleIf(
                          currentUser?.role == 'driver' &&
                              currentUser?.trip != null &&
                              currentUser?.trip?.status != "Completed" &&
                              (!isOnTrip || canStop),
                        );
                      }),
                      Obx(() {
                        final user = _socketController.liveTrackDriver.value;
                        if (user == null) return 0.gapHeight;
                        final isOnTrip =
                            (user.trip?.status == 'Active' ||
                            user.trip?.status == "Completed");
                        return [
                              if (user.trip?.destinations.isNotEmpty ??
                                  false) ...[
                                _buildTripDestinationsSection(user.trip!),
                                SizedBox(height: 20),
                              ],
                              ListTile(
                                title:
                                    (_getCurrentDestination(user.trip!)?.name ??
                                            user.trip?.destination)
                                        .empty("No destination Specified")
                                        .text(),
                                subtitle: 'Destination'.text(),
                                leading: Icon(Icons.location_city),
                              ),
                              ListTile(
                                title: (user.trip?.origin)
                                    .empty("No Origin Specified")
                                    .text(),
                                subtitle: 'from'.text(),
                                leading: Icon(Icons.route_outlined),
                              ),
                            ]
                            .column(mainAxisSize: MainAxisSize.min)
                            .visibleIf(isOnTrip);
                      }),
                      "Under Review "
                          .text(textAlign: TextAlign.center)
                          .padding(
                            EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                          )
                          .decoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(50),
                              border: Border.all(
                                color: Colors.orange.withAlpha(100),
                              ),
                            ),
                          )
                          .sizedBox(width: double.infinity)
                          .constrained(maxWidth: ScreenSizes.DESKTOP_W * 0.75)
                          .visibleIf(user?.trip?.status == "Completed"),
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
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTripDestinationsSection(PopulatedTripModel trip) {
    final currentDest = _getCurrentDestination(trip);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        15.gapHeight,
        Text(
          "Trip Destinations",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...trip.destinations.asMap().entries.map((entry) {
          final index = entry.key;
          final dest = entry.value;
          final isCurrent = currentDest == dest;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dest.reached
                  ? Colors.green.withAlpha(20)
                  : isCurrent
                  ? Theme.of(context).colorScheme.primary.withAlpha(20)
                  : GTheme.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dest.reached
                    ? Colors.green.withAlpha(120)
                    : isCurrent
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withAlpha(50),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      dest.reached
                          ? Icons.check_circle
                          : isCurrent
                          ? Icons.location_on
                          : Icons.location_on_outlined,
                      color: dest.reached
                          ? Colors.green
                          : isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Stop ${index + 1}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dest.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dest.reached
                                ? "Reached"
                                : isCurrent
                                ? "Current Route"
                                : "Pending",
                            style: TextStyle(
                              fontSize: 12,
                              color: dest.reached
                                  ? Colors.green
                                  : isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                          if (dest.location != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              "${dest.location!.lat.toStringAsFixed(4)}, ${dest.location!.lng.toStringAsFixed(4)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        if (!dest.reached)
                          IconButton(
                            onPressed: () =>
                                _markDestinationCompleted(trip, index),
                            icon: Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: 'Mark completed',
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index > 0)
                              IconButton(
                                onPressed: () =>
                                    _reorderDestination(trip, index, index - 1),
                                icon: const Icon(Icons.arrow_upward),
                              ),
                            if (index < trip.destinations.length - 1)
                              IconButton(
                                onPressed: () =>
                                    _reorderDestination(trip, index, index + 1),
                                icon: const Icon(Icons.arrow_downward),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
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
      textCancel: "close",
      content:
          "End trip with vehicle ${_socketController.currentVehicle.value?.carModel}"
              .text(),
      onConfirm: () async {
        Get.back();
        final res = await _userController.endTrip(
          data: {"endTime": DateTime.now().toIso8601String()},
        );
        if (res) {
          Toaster.showSuccess("Trip Stopped -> waiting for approval");
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
