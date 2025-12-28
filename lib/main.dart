import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Genesis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(primary: Colors.blue),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
