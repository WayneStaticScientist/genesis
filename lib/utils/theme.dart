import 'package:flutter/material.dart';

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
}
