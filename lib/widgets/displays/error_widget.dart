import 'package:exui/exui.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class MaterialErrorWidget extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onRetry;
  const MaterialErrorWidget({
    super.key,
    required this.label,
    this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return [
      icon ??
          Iconify(
            Bx.error_alt,
            color: Get.isDarkMode ? Colors.white : Colors.black,
            size: 45,
          ),
      14.gapHeight,
      label.text(),
      if (onRetry != null) ...[
        20.gapHeight,
        IconButton(
          onPressed: onRetry!,
          icon: Iconify(
            Bx.refresh,
            color: Get.isDarkMode ? Colors.white : Colors.black,
            size: 24,
          ),
        ),
      ],
    ].column(mainAxisSize: MainAxisSize.min);
  }
}
