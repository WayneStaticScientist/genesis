import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:get/get_navigation/get_navigation.dart';

class Toaster {
  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      icon: Iconify(Bx.error, color: Colors.white),
      duration: const Duration(seconds: 1),
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showErrorTop(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  static void showSuccess2(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      borderRadius: 10,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      icon: Iconify(Bx.check_circle, color: Colors.white),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
