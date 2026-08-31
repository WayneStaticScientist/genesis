import 'dart:async';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:exui/material.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:line_icons/line_icons.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/utils/string_utils.dart';
import 'package:genesis/utils/screen_sizes.dart';
import 'package:genesis/utils/vehicle_utlis.dart';
import 'package:genesis/screens/chats/chat_screen.dart';
import 'package:genesis/screens/trips/vehicle_trips_screen.dart' as genesis;
import 'package:genesis/models/populated_trip_model.dart';
import 'package:genesis/models/live_track_model.dart';
import 'package:genesis/widgets/actions/pinging_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as Geo;
import 'package:genesis/services/network_adapter.dart';

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
    with TickerProviderStateMixin {
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

  final Rx<LatLng?> _animatedPosition = Rx<LatLng?>(null);
  final Rx<double?> _animatedRotation = Rx<double?>(null);
  AnimationController? _vehicleAnimController;
  Animation<LatLng>? _positionAnimation;
  Animation<double>? _rotationAnimation;

  // Replay State variables
  final RxList<LatLng> _replayPath = <LatLng>[].obs;
  final RxBool _isReplaying = false.obs;
  final RxBool _isReplayPlaying = false.obs;
  final RxInt _replayIndex = 0.obs;
  final RxDouble _replaySpeed = 1.0.obs;
  final Rx<LatLng?> _replayPosition = Rx<LatLng?>(null);
  Timer? _replayTimer;

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
        final newPosition = LatLng(data.lat, data.lng);
        final newRotation = data.rotation;

        if (_animatedPosition.value == null) {
          _animatedPosition.value = newPosition;
          _animatedRotation.value = (newRotation as num?)?.toDouble() ?? 0.0;
        } else {
          _vehicleAnimController?.dispose();
          _vehicleAnimController = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 3), // Match duration to ping interval
          );

          _positionAnimation = LatLngTween(
            begin: _animatedPosition.value!,
            end: newPosition,
          ).animate(CurvedAnimation(parent: _vehicleAnimController!, curve: Curves.linear))
            ..addListener(() {
              _animatedPosition.value = _positionAnimation!.value;
            });

          double oldRot = _animatedRotation.value ?? 0.0;
          double newRotNum = (newRotation as num?)?.toDouble() ?? 0.0;
          
          // Shortest path for rotation to prevent spinning backward
          double diff = newRotNum - oldRot;
          if (diff > 180) {
            newRotNum -= 360;
          } else if (diff < -180) {
            newRotNum += 360;
          }

          _rotationAnimation = Tween<double>(
            begin: oldRot,
            end: newRotNum,
          ).animate(CurvedAnimation(parent: _vehicleAnimController!, curve: Curves.linear))
            ..addListener(() {
              // Normalize back to 0-360 for consistent reading if needed
              double currentRot = _rotationAnimation!.value;
              if (currentRot < 0) currentRot += 360;
              if (currentRot >= 360) currentRot -= 360;
              _animatedRotation.value = currentRot;
            });

          _vehicleAnimController!.forward();
        }

        if (_automaticTracking) {
          final controller = await _mapController.future;
          controller.animateCamera(
            CameraUpdate.newLatLng(newPosition),
          );
        }
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
    _replayTimer?.cancel();
    _vehicleAnimController?.dispose();
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
              'reachedAt': dest.reachedAt?.toIso8601String(),
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
      reachedAt: DateTime.now(),
    );
    await _updateTripDestinations(trip, updated);

    // Auto-end trip if all destinations are reached
    final allReached = updated.every((dest) => dest.reached);
    if (allReached) {
      final res = await _userController.endTrip(
        data: {"endTime": DateTime.now().toIso8601String()},
      );
      if (res) {
        Toaster.showSuccess("Trip Completed Successfully");
        _userController.user.refresh();
      }
    }
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
            final listenId = _socketController.listenId.value;
            final isOnTrip = trip?.status == "Active" || trip?.status == "Pending";
            
            final hasHardwarePing = liveData != null && 
                                    liveData.state != 'not-found';
            
            final shouldShowMap = isOnTrip || hasHardwarePing;

            if (!shouldShowMap || listenId.isEmpty) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LineIcons.parking,
                        size: 80,
                        color: Colors.grey.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 24),
                    "Vehicle is Parked".text(
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    "No active trip or live GPS signal detected".text(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 150), // space for bottom sheet
                  ],
                ),
              );
            }

            final destinations = trip?.destinations ?? [];
            final destination = trip?.location;
            final origin = trip?.locationOrigin;
            final hasData = liveData != null && liveData.lat != 0 && liveData.lng != 0;
            final currentPos = _animatedPosition.value ?? (hasData
                ? LatLng(liveData.lat, liveData.lng)
                : _defaultLocation);
            final currentRot = _animatedRotation.value ?? (hasData ? (liveData.rotation as num?)?.toDouble() ?? 0.0 : 0.0);
                
            // Cache the very first position so initialCameraPosition never changes on rebuilds!
            // This prevents the map from constantly zooming out and stuttering when panned.
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _defaultLocation,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                if (hasData)
                  controller.moveCamera(CameraUpdate.newLatLng(currentPos));
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              polylines: {
                if (_isReplaying.value && _replayPath.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('replay_path_line'),
                    points: _replayPath,
                    color: Colors.blueAccent,
                    width: 5,
                    jointType: JointType.round,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                  ),
              },
              markers: _isReplaying.value
                  ? {
                      if (_replayPosition.value != null)
                        Marker(
                          markerId: const MarkerId('replay_vehicle'),
                          position: _replayPosition.value!,
                          anchor: const Offset(0.5, 0.5),
                          icon: vehicleIcon ?? BitmapDescriptor.defaultMarker,
                        ),
                      if (_replayPath.isNotEmpty) ...[
                        Marker(
                          markerId: const MarkerId('replay_start'),
                          position: _replayPath.first,
                          infoWindow: const InfoWindow(title: 'Start Location'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        ),
                        Marker(
                          markerId: const MarkerId('replay_end'),
                          position: _replayPath.last,
                          infoWindow: const InfoWindow(title: 'End Location'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                      ]
                    }
                  : {
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
                          rotation: currentRot, // Animated Bearing
                          anchor: const Offset(0.5, 0.5),
                          icon: vehicleIcon ?? BitmapDescriptor.defaultMarker,
                          onTap: () {
                            _showVehicleDetailsDialog(liveData);
                          },
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
                child: Container(
                  decoration: BoxDecoration(
                    color: GTheme.surface(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _automaticTracking
                          ? GTheme.primary(context)
                          : Colors.grey.withAlpha(50),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _automaticTracking = !_automaticTracking;
                      });
                    },
                    icon: Icon(
                      Icons.videocam_rounded,
                      color: _automaticTracking
                          ? GTheme.primary(context)
                          : GTheme.reverse(context).withAlpha(120),
                    ),
                    tooltip: 'Toggle Camera Follow',
                  ),
                ),
              ),
            ),
          ),
          // 3. ACTIVE ASSETS CAROUSEL (Simplified)

          // 4. DRAGGABLE BOTTOM SHEET
          Obx(() {
            if (_isReplaying.value) {
              return Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: GTheme.surface(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            "Replay Mode".text(style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _stopReplay,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(_isReplayPlaying.value ? Icons.pause : Icons.play_arrow),
                              onPressed: () {
                                if (_isReplayPlaying.value) {
                                  _pauseReplay();
                                } else {
                                  _startReplayAnimation();
                                }
                              },
                            ),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: (_replayPath.length - 1).toDouble() > 0 ? (_replayPath.length - 1).toDouble() : 1.0,
                                value: _replayIndex.value.toDouble(),
                                onChanged: _replayPath.isNotEmpty ? (val) {
                                  _replayIndex.value = val.toInt();
                                  _replayPosition.value = _replayPath[_replayIndex.value];
                                } : null,
                              ),
                            ),
                            "${_replayIndex.value + 1}/${_replayPath.length}".text(),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSpeedButton(1.0),
                            _buildSpeedButton(2.0),
                            _buildSpeedButton(5.0),
                            _buildSpeedButton(10.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final hasTrip = _socketController.liveTrackDriver.value?.trip?.status == "Active";
            return DraggableScrollableSheet(
              initialChildSize: hasTrip ? 0.5 : 0.23,
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
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: GTheme.isDark(context)
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Driver Info
                      Obx(() {
                        final user = _socketController.liveTrackDriver.value;
                        final liveData = _socketController.liveTrackModel.value;
                        final listenId = _socketController.listenId.value;
                        final isOnTrip = (user?.trip?.status == "Active");

                        if (listenId.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: GTheme.surface(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  LineIcons.mapMarked,
                                  size: 40,
                                  color: Colors.grey.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                "No active tracking session".text(
                                  style: TextStyle(
                                    color: Colors.grey.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final currentVehicle = _socketController.currentVehicle.value;
                        if (currentVehicle == null && user == null) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: GTheme.surface(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                "Initializing tracking...".text(
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        Duration? difference;
                        if (liveData != null) {
                          difference = DateTime.now().difference(
                            liveData.timestamp,
                          );
                        }
                        return Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  (user != null ? ("Driver".from(
                                    user.firstName,
                                    user.lastName,
                                  ))[0] : (currentVehicle?.carModel ?? "T")[0]).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user != null ? "Driver".from(
                                      user.firstName,
                                      user.lastName,
                                    ) : (currentVehicle?.carModel ?? "Hardware Tracker"),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: GTheme.reverse(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isOnTrip
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isOnTrip.lorc(Colors.green, Colors.grey),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
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
                                            user == null ? "Hardware Tracked" : "Idle",
                                          ),
                                          style: TextStyle(
                                            color: isOnTrip.lorc(
                                              Colors.green,
                                              Colors.grey,
                                            ),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (user != null)
                              IconButton(
                                onPressed: () =>
                                    Get.to(() => ChatScreen(user: user)),
                                icon: Icon(
                                  LineIcons.commentAlt,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        );
                      }),

                      const SizedBox(height: 20),
                      // Telemetry Cards Grid Row 1 (Speed, Fuel, Status)
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final liveData = _socketController.liveTrackModel.value;
                              Duration? difference;
                              if (liveData != null) {
                                difference = DateTime.now().difference(liveData.timestamp);
                              }
                              final speedVal = (difference == null).lors(
                                VehicleUtlis.speedToStandardUnits(0),
                                ((difference?.inMinutes ?? 0) > 2).lors(
                                  VehicleUtlis.speedToStandardUnits(0),
                                  "${VehicleUtlis.speedToStandardUnits(_socketController.liveTrackModel.value?.speed)}",
                                ),
                              );
                              return _buildTelemetryCard(
                                icon: LineIcons.lightningBolt,
                                value: speedVal,
                                label: "Speed",
                              );
                            }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(
                              () => _buildTelemetryCard(
                                icon: LineIcons.gasPump,
                                value: "${_socketController.currentVehicle.value?.fuelLevel ?? 0}%",
                                label: "Fuel",
                                onTap: _showFuelManagementOptions,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(() {
                              final date = _socketController.liveTrackModel.value?.timestamp;
                              bool online = false;
                              String label = "Offline";
                              if (date != null) {
                                final difference = DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
                                if (difference < 5000 * 60) {
                                  online = true;
                                }
                                if (difference < 1000 * 60 * 60) {
                                  label = "${difference ~/ (1000 * 60)}m ago";
                                } else if (difference < 1000 * 60 * 60 * 24) {
                                  label = "${difference ~/ (1000 * 60 * 60)}h ago";
                                } else {
                                  label = "offTrip";
                                }
                              }
                              return _buildTelemetryCard(
                                icon: LineIcons.clock,
                                value: online ? "online" : label,
                                label: "Status",
                                iconColor: online ? Colors.green : Colors.grey,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Telemetry Cards Grid Row 2 (Mileage, Today's Distance)
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final liveData = _socketController.liveTrackModel.value;
                              final currentVehicle = _socketController.currentVehicle.value;
                              final mileage = liveData?.mileage ?? currentVehicle?.mileage ?? 0.0;
                              return _buildTelemetryCard(
                                icon: LineIcons.route,
                                value: "${mileage.toStringAsFixed(1)} km",
                                label: "Mileage",
                              );
                            }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(() {
                              final liveData = _socketController.liveTrackModel.value;
                              final todayDist = liveData?.todayDistance ?? 0.0;
                              return _buildTelemetryCard(
                                icon: LineIcons.mapSigns,
                                value: "${todayDist.toStringAsFixed(1)} km",
                                label: "Today's Dist",
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons Row (Replay Today & View Trip History)
                      Obx(() {
                        final currentVehicle = _socketController.currentVehicle.value;
                        if (currentVehicle == null) return const SizedBox.shrink();
                        return Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                                icon: Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                                label: Text(
                                  "Replay Today",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                onPressed: () => _fetchAndStartReplay(currentVehicle.id ?? "", DateTime.now()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.history_rounded, size: 20),
                                label: const Text("Trip History", style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  final result = await Get.to(() => genesis.VehicleTripsScreen(
                                    vehicleId: currentVehicle.id ?? "",
                                    carModel: currentVehicle.carModel,
                                  ));
                                  if (result != null && result is DateTime) {
                                    _fetchAndStartReplay(currentVehicle.id ?? "", result);
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),

                      // === ANIMATED TRIP BUTTON ===
                      Obx(() {
                        final currentUser = _userController.user.value;
                        if (currentUser?.role != 'driver' ||
                            currentUser?.trip == null)
                          return const SizedBox.shrink();

                        final isOnTrip =
                            (currentUser?.trip?.status == 'Active');
                        final tripCompleted =
                            (currentUser?.trip?.status == "Completed");
                        if (tripCompleted) return const SizedBox.shrink();

                        final allReached = _allDestinationsReached(
                          currentUser!.trip!,
                        );

                        return Column(
                          children: [
                            if (isOnTrip && !allReached)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withAlpha(100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        "Reach all destinations to complete trip",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            PingingStopButton(
                              isLoading: _userController.processingTrip.value,
                              isOnTrip: isOnTrip,
                              animationOnly:
                                  isOnTrip, // Always animation only if on trip
                              pingAnimation: _pingController,
                              onPressed: () {
                                if (!isOnTrip) {
                                  _showStartTripDialog();
                                }
                              },
                            ),
                          ],
                        );
                      }),
                      Obx(() {
                        final user = _socketController.liveTrackDriver.value;
                        if (user == null || user.trip == null) return 0.gapHeight;
                        
                        final isOnTrip =
                            (user.trip!.status == 'Active' ||
                            user.trip!.status == "Completed");
                            
                        if (!isOnTrip) return 0.gapHeight;

                        return [
                              if (user.trip!.destinations.isNotEmpty) ...[
                                _buildTripDestinationsSection(user.trip!),
                                const SizedBox(height: 20),
                              ],
                              ListTile(
                                title:
                                    (_getCurrentDestination(user.trip!)?.name ??
                                            user.trip!.destination)
                                        .empty("No destination Specified")
                                        .text(),
                                subtitle: 'Destination'.text(),
                                leading: const Icon(Icons.location_city),
                              ),
                              ListTile(
                                title: (user.trip!.origin)
                                    .empty("No Origin Specified")
                                    .text(),
                                subtitle: 'from'.text(),
                                leading: const Icon(Icons.route_outlined),
                              ),
                            ]
                            .column(mainAxisSize: MainAxisSize.min);
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
            );
          }),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildTelemetryCard({
    required IconData icon,
    required String value,
    required String label,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final primary = iconColor ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primary, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7) ?? Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: GTheme.reverse(context),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: child,
      );
    }
    return child;
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
                    AnimatedBuilder(
                      animation: _pingController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isCurrent
                              ? 1.0 + (0.15 * _pingController.value)
                              : 1.0,
                          child: Icon(
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
                        );
                      },
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
                                ? "Reached at ${GenesisDate.getHour(dest.reachedAt)}"
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
          _userController.user.value?.currentVehicle?.id ?? '';
    }
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

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Geo.Placemark> placemarks = await Geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final Geo.Placemark pos = placemarks.first;
        final street = pos.street ?? '';
        final subLocality = pos.subLocality ?? '';
        final city = pos.locality ?? '';
        final parts = [if (street.isNotEmpty) street, if (subLocality.isNotEmpty) subLocality, if (city.isNotEmpty) city];
        return parts.join(", ");
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    return "Unknown Address";
  }

  void _showVehicleDetailsDialog(LiveTrackModel data) async {
    final address = RxString("Loading address...");
    _getAddressFromLatLng(data.lat, data.lng).then((addr) => address.value = addr);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GTheme.surface(Get.context!),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Vehicle Telemetry".text(
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    "Live Updates".text(style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => address.value.text(
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPopupDetailItem(
                  icon: Icons.speed,
                  title: "Speed",
                  value: "${(data.speed * 3.6).toStringAsFixed(1)} km/h",
                ),
                _buildPopupDetailItem(
                  icon: Icons.power,
                  title: "ACC Status",
                  value: data.acc == null ? "N/A" : (data.acc! ? "ON" : "OFF"),
                  valueColor: data.acc == null
                      ? Colors.grey
                      : (data.acc! ? Colors.green : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPopupDetailItem(
                  icon: Icons.battery_charging_full,
                  title: "Voltage",
                  value: data.voltage != null
                      ? "${data.voltage!.toStringAsFixed(1)} V"
                      : (data.battery != null ? "${data.battery!.toInt()}%" : "N/A"),
                ),
                _buildPopupDetailItem(
                  icon: Icons.access_time,
                  title: "Last Update",
                  value: "${DateTime.now().difference(data.timestamp).inMinutes} min ago",
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GTheme.primary(Get.context!),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.replay),
                label: "Replay History".text(),
                onPressed: () {
                  Get.back();
                  _showReplayDatePicker(data.car);
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPopupDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title.text(style: const TextStyle(color: Colors.grey, fontSize: 12)),
              value.text(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReplayDatePicker(String vehicleId) {
    Get.defaultDialog(
      title: "Replay Route",
      content: Column(
        children: [
          "Select a period to replay".text(),
          const SizedBox(height: 16),
          ListTile(
            title: "Today".text(),
            leading: const Icon(Icons.today),
            onTap: () {
              Get.back();
              _fetchAndStartReplay(vehicleId, DateTime.now());
            },
          ),
          ListTile(
            title: "Yesterday".text(),
            leading: const Icon(Icons.history),
            onTap: () {
              Get.back();
              _fetchAndStartReplay(vehicleId, DateTime.now().subtract(const Duration(days: 1)));
            },
          ),
          ListTile(
            title: "Pick custom date".text(),
            leading: const Icon(Icons.calendar_month),
            onTap: () async {
              Get.back();
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                _fetchAndStartReplay(vehicleId, picked);
              }
            },
          ),
        ],
      ),
    );
  }

  void _fetchAndStartReplay(String vehicleId, DateTime date) async {
    final dateString = date.toIso8601String().split("T")[0];
    Toaster.showInfo("Fetching history for $dateString...");
    
    final response = await Net.get("/vehicle/$vehicleId/history", queryParameters: {"date": dateString});
    if (response.hasError) {
      Toaster.showError("Failed to load history: ${response.response}");
      return;
    }
    
    final pointsList = (response.body['points'] as List?) ?? [];
    if (pointsList.isEmpty) {
      Toaster.showError("No movement logs found for this vehicle on $dateString.");
      return;
    }
    
    final path = pointsList.map((p) => LatLng(
      (p['lat'] as num).toDouble(),
      (p['lng'] as num).toDouble(),
    )).toList();
    
    _stopReplay(); // Clean up if already running
    
    _replayPath.assignAll(path);
    _isReplaying.value = true;
    _replayIndex.value = 0;
    _replayPosition.value = path.first;
    
    // Zoom/Move camera to start of path
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(path.first, 15));
    
    _startReplayAnimation();
  }

  void _startReplayAnimation() {
    _replayTimer?.cancel();
    _isReplayPlaying.value = true;
    _animateToNextPoint();
  }

  void _animateToNextPoint() async {
    if (!_isReplayPlaying.value) return;
    if (_replayIndex.value >= _replayPath.length - 1) {
      _isReplayPlaying.value = false;
      Toaster.showSuccess("Replay finished.");
      return;
    }

    final startPoint = _replayPath[_replayIndex.value];
    final endPoint = _replayPath[_replayIndex.value + 1];

    final intervalMs = (1500 / _replaySpeed.value).round();
    
    // Dispose previous controller if exists
    _vehicleAnimController?.dispose();
    
    _vehicleAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: intervalMs),
    );

    _positionAnimation = LatLngTween(begin: startPoint, end: endPoint).animate(_vehicleAnimController!)
      ..addListener(() {
        _replayPosition.value = _positionAnimation!.value;
      })
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          _replayIndex.value++;
          
          // Pan camera gently every few points to avoid crashing/stuttering
          if (_replayIndex.value % 5 == 0) {
            final controller = await _mapController.future;
            controller.animateCamera(CameraUpdate.newLatLng(_replayPosition.value!));
          }
          
          _animateToNextPoint();
        }
      });

    _vehicleAnimController!.forward();
  }

  void _pauseReplay() {
    _isReplayPlaying.value = false;
    _vehicleAnimController?.stop();
    _replayTimer?.cancel();
  }

  void _stopReplay() {
    _isReplaying.value = false;
    _isReplayPlaying.value = false;
    _vehicleAnimController?.dispose();
    _vehicleAnimController = null;
    _replayTimer?.cancel();
    _replayPath.clear();
    _replayPosition.value = null;
    _replayIndex.value = 0;
  }

  Widget _buildSpeedButton(double speed) {
    return Obx(() {
      final isSelected = _replaySpeed.value == speed;
      return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? GTheme.primary(context) : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : GTheme.reverse(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          _replaySpeed.value = speed;
          if (_isReplayPlaying.value) {
            _startReplayAnimation(); // restart timer with new interval
          }
        },
        child: "${speed.toInt()}x".text(),
      );
    });
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    final b = begin;
    final e = end;
    if (b == null || e == null) return b ?? e ?? const LatLng(0, 0);
    final lat = b.latitude + (e.latitude - b.latitude) * t;
    final lng = b.longitude + (e.longitude - b.longitude) * t;
    return LatLng(lat, lng);
  }
}
