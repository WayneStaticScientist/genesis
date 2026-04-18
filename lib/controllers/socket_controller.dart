import 'dart:io';
import 'dart:async';
import 'package:exui/exui.dart';
import 'package:get/get.dart';
import 'package:genesis/utils/toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/models/live_track_model.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketController extends GetxController {
  late IO.Socket socket;
  Timer? _statusTimer;
  String? _previousListenId;
  RxString listenId = "".obs;
  RxDouble fuelLevel = 0.0.obs;
  Rx<User?> liveTrackDriver = Rx<User?>(null);
  Rx<VehicleModel?> currentVehicle = Rx<VehicleModel?>(null);
  Rx<LiveTrackModel?> liveTrackModel = Rx<LiveTrackModel?>(null);
  @override
  void onInit() {
    super.onInit();
    initConnection();
    ever(listenId, (String newId) {
      liveTrackDriver.value = null;
      _updateSocketListener(newId);
    });
  }

  @override
  void onClose() {
    _statusTimer?.cancel(); // 3. IMPORTANT: Cancel timer when controller dies
    socket.dispose();
    super.onClose();
  }

  void initConnection() {
    socket = IO.io(
      Net.url,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.connect();
    socket.onConnect((_) {
      _startStatusCheck();
    });
    socket.onDisconnect((_) {
      _statusTimer?.cancel(); // 5. Stop checking if disconnected
    });
  }

  void listenToUserSocket() {
    final user = User.fromStorage();
    if (user == null) return;
    socket.on("${user.id}_trip_start", (data) {
      Get.defaultDialog(
        title: "Start Trip",
        content: "Start A Given trip".text(),
        textCancel: "close",
        onConfirm: () {
          Get.back();
          _handleTripAction(true);
        },
      );
    });
  }

  Future<void> _handleTripAction(bool starting) async {
    final _userController = Get.find<UserController>();
    final res = await _userController.confirmStartTrip();
    if (res) {
      Toaster.showSuccess("Tracking started");
      listenId.value =
          _userController.user.value?.currentVehicle?.carModel ?? '';
    }
  }

  void transmitMessage({required String channel, required Map data}) {
    if (socket.connected) {
      socket.emit(channel, data);
    } else {
      socket.connect();
    }
  }

  void _startStatusCheck() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (socket.connected) {
        _checkRouteConfigurations();
        _checkAdminConfiguration();
      }
    });
  }

  StreamSubscription<Position>? _positionStreamSubscription;
  Future<void> _checkRouteConfigurations() async {
    final user = User.fromStorage();
    if (_positionStreamSubscription != null && user?.trip == null) {
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      return;
    }
    if (_positionStreamSubscription != null) return;
    if (user == null ||
        user.trip == null ||
        user.currentVehicle == null ||
        user.trip?.status == "Pending") {
      if (user?.currentVehicle != null &&
          (currentVehicle.value == null ||
              currentVehicle.value!.id != user!.currentVehicle?.id)) {
        findVehicle(id: user!.currentVehicle!.id, update: true);
      }

      return;
    }
    try {
      // 2. Handle Permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // 3. Define modern LocationSettings (Avoids Deprecation)
      LocationSettings locationSettings;

      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          intervalDuration: const Duration(seconds: 3), // Or every 3 seconds
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "Tracking your trip...",
            notificationTitle: "Genesis Live",
          ),
        );
      } else if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          pauseLocationUpdatesAutomatically: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        );
      }
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position position) {
            // This block runs EVERY time the user moves
            final data = {
              'user': user.id,
              'status': 'active',
              "speed": position.speed,
              'lat': position.latitude,
              'lng': position.longitude,
              'rotation': position.heading,
              "car": user.currentVehicle?.id,
              'timestamp': DateTime.now().toIso8601String(),
              "location": user.trip?.location?.toJson(),
              "startPostion": user.trip?.location?.toJson(),
              "fuelLevel": currentVehicle.value?.fuelLevel ?? 0,
            };
            if (listenId.value != user.currentVehicle) {
              listenId.value = user.currentVehicle!.id;
            }

            transmitMessage(channel: 'user-location-update', data: data);
          });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _updateSocketListener(String newId) {
    if (newId.isEmpty) return;

    // 2. Remove the listener from the old channel to prevent memory leaks/duplicate logs
    if (_previousListenId != null) {
      socket.off(_previousListenId!);
    }

    // 3. Register the new listener
    socket.on(newId, (data) {
      liveTrackModel.value = LiveTrackModel.fromJSON(data);
      if (currentVehicle.value != null) {
        currentVehicle.value!.fuelLevel = liveTrackModel.value?.fuelLevel ?? 0;
      }
    });

    _previousListenId = newId;
    findVehicle(id: newId, update: true);
  }

  Future<VehicleModel?> findVehicle({
    required String id,
    required bool update,
  }) async {
    final response = await Net.get("/vehicle/$id");
    if (response.hasError) {
      return null;
    }
    final vehicle = VehicleModel.fromJSON(response.body);
    if (update) {
      currentVehicle.value = vehicle;
    }
    findDriver(vehicle.driver?.id ?? '');
    return vehicle;
  }

  void _checkAdminConfiguration() {
    final user = User.fromStorage();
    if (user == null || listenId.value.isEmpty) {
      return;
    }
    if (liveTrackModel.value == null) {
      return broadcastFind();
    }
    final difference =
        DateTime.now().millisecondsSinceEpoch -
        (liveTrackModel.value!.timestamp.millisecondsSinceEpoch);
    if (difference > 1000 * 60 * 10) {
      broadcastFind();
    }
  }

  void broadcastFind() {
    final user = User.fromStorage();
    transmitMessage(
      channel: 'where-is-the-car',
      data: {"companyId": user!.companyId, "vehicleId": listenId.value},
    );
  }

  void findDriver(String id) async {
    if (id.isEmpty) return;
    final response = await Net.get("/user/$id");
    if (response.hasError) {
      return;
    }
    liveTrackDriver.value = User.fromJSON(response.body);
  }
}
