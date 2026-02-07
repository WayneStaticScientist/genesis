import 'dart:async';
import 'dart:io';

import 'package:genesis/models/user_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketController extends GetxController {
  late IO.Socket socket;
  Timer? _statusTimer;
  @override
  void onInit() {
    super.onInit();
    initConnection();
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
      print('Connected to Bun backend');
      _startStatusCheck();
    });
    socket.on('message', (data) => print('New Message: $data'));
    socket.onDisconnect((_) {
      _statusTimer?.cancel(); // 5. Stop checking if disconnected
    });
  }

  void transmitMessage({required String channel, required Map data}) {
    if (socket.connected) {
      socket.emit(channel, data);
    }
  }

  void _startStatusCheck() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (socket.connected) {
        _checkRouteConfigurations();
      }
    });
  }

  Future<void> _checkRouteConfigurations() async {
    final user = User.fromStorage();

    if (user == null || user.trip == null) return;
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
        'timestamp': DateTime.now().toIso8601String(),
      };

      transmitMessage(channel: 'user-location-update', data: data);
    } catch (e) {
      print('Error getting location: $e');
    }
  }
}
