import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RowModernLayout extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  const RowModernLayout({super.key, required this.children, this.title});

  @override
  Widget build(BuildContext context) {
    return [
          if (title != null) ...[
            title!.text(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            14.gapHeight,
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: children.row(),
          ),
        ]
        .column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        )
        .paddingZero
        .padding(EdgeInsets.all(12))
        .decoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
          ),
        );
  }
}
