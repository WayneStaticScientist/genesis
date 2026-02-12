import 'package:exui/exui.dart';
import 'package:flutter/widgets.dart';

class InfoLayout extends StatelessWidget {
  final String label;
  final Widget? icon;
  const InfoLayout({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return [
      icon ?? 0.gapHeight,
      14.gapHeight.visibleIfNull(icon),
      label.text(),
    ].column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
    );
  }
}
