import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/utils/genesis_settings.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:genesis/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:genesis/utils/database_carrier.dart';
import 'package:genesis/screens/main/main_screen.dart';
import 'package:genesis/screens/auth/login_screen.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/controllers/trips_controller.dart';
import 'package:genesis/controllers/socket_controller.dart';
import 'package:genesis/controllers/vehicle_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:genesis/controllers/payroll_controller.dart';
import 'package:genesis/controllers/messaging_controller.dart';
import 'package:genesis/services/background_message_handler.dart';
import 'package:genesis/controllers/maintainance_controller.dart';
import 'package:genesis/controllers/live_tracking_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  GenesisBackgroundMessageHandler.handleBackgroundMessage(message);
}

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await IsarStatic.init();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // 4. Set Foreground Notification Options (for when app is open)
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = User.fromStorage();
    final settings = GenesisSettings.readSettings();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(UserController());
        Get.put(StatsController());
        Get.put(VehicleControler());
        Get.put(MaintainanceController());
        Get.put(LiveTrackingController());
        Get.put(SocketController());
        Get.put(TripsController());
        Get.put(MessagingController());
        Get.put(PayrollController());
      }),
      title: 'Genesis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(primary: Colors.blue),
        brightness: Brightness.dark,
      ),
      themeMode: settings.isSystemThemeMode.lord(
        ThemeMode.system,
        settings.isDarkMode.lord(ThemeMode.dark, ThemeMode.light),
      ),
      home: user != null ? const MainScreen() : const LoginScreen(),
    );
  }
}
