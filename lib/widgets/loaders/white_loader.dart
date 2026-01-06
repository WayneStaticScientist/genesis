import 'package:exui/exui.dart';
import 'package:flutter/material.dart';

class WhiteLoader extends StatelessWidget {
  const WhiteLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: Colors.white,
      strokeWidth: 1,
    ).sizedBox(width: 20, height: 20);
  }
}
