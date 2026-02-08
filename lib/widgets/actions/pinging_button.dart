import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class PingingStopButton extends StatelessWidget {
  final bool isOnTrip;
  final Animation<double> pingAnimation;
  final VoidCallback onPressed;

  const PingingStopButton({
    super.key,
    required this.isOnTrip,
    required this.pingAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isOnTrip)
          AnimatedBuilder(
            animation: pingAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: PingPainter(pingAnimation.value),
                size: const Size(double.infinity, 55),
              );
            },
          ),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            icon: Icon(
              isOnTrip ? LineIcons.stop : LineIcons.play,
              color: Colors.white,
            ),
            label: Text(
              isOnTrip ? "STOP TRIP" : "START TRIP",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOnTrip
                  ? Colors.red.shade600
                  : Colors.blue.shade700,
              elevation: isOnTrip ? 0 : 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}

class PingPainter extends CustomPainter {
  final double progress;
  PingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withAlpha(((1.0 - progress) * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw 3 concentric expanding rings
    for (int i = 0; i < 3; i++) {
      double currentProgress = (progress + (i * 0.33)) % 1.0;
      double opacity = 1.0 - currentProgress;
      paint.color = Colors.red.withAlpha((opacity * 255).toInt());

      // Expand rings horizontally and vertically
      double horizontalInflation = 50 * currentProgress;
      double verticalInflation = 30 * currentProgress;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            -horizontalInflation,
            -verticalInflation,
            size.width + horizontalInflation,
            size.height + verticalInflation,
          ),
          const Radius.circular(16),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PingPainter oldDelegate) => true;
}
