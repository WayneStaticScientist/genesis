import 'package:flutter/material.dart';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:genesis/utils/bool_utils.dart';

class GTheme {
  static Color primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color surface(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.dark)
        ? const Color.fromARGB(255, 30, 30, 30)
        : const Color(0xFFF4F7FE);
  }

  static Color cardColor(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.dark)
        ? const Color.fromARGB(255, 20, 20, 20)
        : Colors.white;
  }

  //Returns actual Color : White or Black depending on context
  static Color color(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.dark)
        ? const Color.fromARGB(255, 20, 20, 20)
        : Colors.white;
  }

  static Color reverse(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : Colors.black;
  }

  static SystemUiOverlayStyle? copyOverlay(BuildContext context) {
    return SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Optional: makes status bar transparent
      statusBarIconBrightness: (Theme.of(context).brightness == Brightness.dark)
          .lord(Brightness.light, Brightness.dark), // For Android (dark icons)
      statusBarBrightness: (Theme.of(context).brightness == Brightness.dark)
          .lord(Brightness.light, Brightness.dark), // For iOS (dark icons)
    );
  }

  static SystemUiOverlayStyle? materialOverlay(BuildContext context) {
    return SystemUiOverlayStyle(
      statusBarColor: Theme.of(
        context,
      ).colorScheme.primary, // Optional: makes status bar transparent
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    );
  }
}
