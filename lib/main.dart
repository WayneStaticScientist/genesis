import 'package:genesis/controllers/maintainance_controller.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/screens/main/main_screen.dart';
import 'package:genesis/screens/auth/login_screen.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/controllers/vehicle_controller.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = User.fromStorage();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(UserController());
        Get.put(StatsController());
        Get.put(VehicleControler());
        Get.put(MaintainanceController());
      }),
      title: 'Genesis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(primary: Colors.blue),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: user != null ? const MainScreen() : const LoginScreen(),
    );
  }
}
