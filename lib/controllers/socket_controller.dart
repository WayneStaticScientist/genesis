import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/models/live_track_model.dart';
import 'package:genesis/services/network_adapter.dart';
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

  void transmitMessage({required String channel, required Map data}) {
    if (socket.connected) {
      socket.emit(channel, data);
    } else {
      socket.connect();
    }
  }

  void _startStatusCheck() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (socket.connected) {
        _checkRouteConfigurations();
        _checkAdminConfiguration();
      }
    });
  }

  Future<void> _checkRouteConfigurations() async {
    final user = User.fromStorage();
    if (user?.role == "driver") {
      liveTrackDriver.value = user;
    }
    if (user == null || user.trip == null || user.currentVehicle == null) {
      if (user?.currentVehicle != null &&
          (currentVehicle.value == null ||
              currentVehicle.value!.id != user!.currentVehicle!)) {
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
          distanceFilter: 10,
          intervalDuration: const Duration(seconds: 30),
        );
      } else if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          pauseLocationUpdatesAutomatically: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        );
      }

      // 4. Get Current Position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      // 5. Emit Data
      final data = {
        'user': user.id,
        'status': 'active',
        'lat': position.latitude,
        'lng': position.longitude,
        "car": user.currentVehicle,
        "fuelLevel": currentVehicle.value?.fuelLevel ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
      };
      if (listenId.value != user.currentVehicle) {
        listenId.value = user.currentVehicle!.id;
      }
      transmitMessage(channel: 'user-location-update', data: data);
    } catch (e) {
      print('Error getting location: $e');
    }
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

      findDriver(vehicle.driver?.id ?? '');
    }
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
