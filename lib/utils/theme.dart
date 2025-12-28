import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GTheme {
  static Color surface() {
    return Get.isDarkMode
        ? const Color.fromARGB(255, 30, 30, 30)
        : const Color(0xFFF4F7FE);
  }

  //Returns actual Color : White or Black depending on context
  static Color color() {
    return Get.isDarkMode
        ? const Color.fromARGB(255, 20, 20, 20)
        : Colors.white;
  }

  static Color reverse() {
    return Get.isDarkMode ? Colors.white : Colors.black;
  }
}
