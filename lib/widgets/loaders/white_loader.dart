import 'package:exui/exui.dart';
import 'package:flutter/material.dart';

class WhiteLoader extends StatelessWidget {
  final Color? color;
  const WhiteLoader({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color ?? Colors.white,
      strokeWidth: 1,
    ).sizedBox(width: 20, height: 20);
  }
}

class AdaptiveLoader extends StatelessWidget {
  const AdaptiveLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      strokeWidth: 1,
    ).sizedBox(width: 20, height: 20);
  }
}
