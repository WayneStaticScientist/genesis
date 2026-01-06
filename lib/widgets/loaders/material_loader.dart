import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MaterialLoader extends StatelessWidget {
  const MaterialLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: Get.theme.colorScheme.primary,
      strokeWidth: 1,
    ).sizedBox(width: 20, height: 20);
  }
}
