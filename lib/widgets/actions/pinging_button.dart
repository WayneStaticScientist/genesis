import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:line_icons/line_icons.dart';

class PingingStopButton extends StatelessWidget {
  final bool isOnTrip;
  final bool isLoading;
  final bool animationOnly;
  final Animation<double> pingAnimation;
  final VoidCallback onPressed;

  const PingingStopButton({
    super.key,
    required this.isOnTrip,
    required this.pingAnimation,
    required this.onPressed,
    required this.isLoading,
    this.animationOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isOnTrip && !animationOnly)
          AnimatedBuilder(
            animation: pingAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: PingPainter(pingAnimation.value),
                size: const Size(double.infinity, 55),
              );
            },
          ),
        if (!animationOnly)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon: Icon(
                isOnTrip ? LineIcons.stop : LineIcons.play,
                color: Colors.white,
              ).visibleIfNot(isLoading),
              label: isLoading
                  ? WhiteLoader()
                  : Text(
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
        if (animationOnly)
          Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withAlpha(20)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "TRIP IN PROGRESS",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
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
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      double currentProgress = (progress + (i * 0.25)) % 1.0;
      // Faster decay for a more "energetic" look
      double opacity = 0.4 * (1.0 - currentProgress);
      paint.color = Colors.red.withAlpha((opacity * 255).toInt());

      // Expand outward with a slight easing feel
      double horizontalInflation = (size.width * 0.4) * currentProgress;
      double verticalInflation = (size.height * 0.8) * currentProgress;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            -horizontalInflation,
            -verticalInflation,
            size.width + horizontalInflation,
            size.height + verticalInflation,
          ),
          Radius.circular(20 + (10 * currentProgress)),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PingPainter oldDelegate) => true;
}
