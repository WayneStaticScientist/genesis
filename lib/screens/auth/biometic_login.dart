import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/theme.dart';
import 'package:local_auth/local_auth.dart';
import 'package:genesis/screens/auth/login_screen.dart';
import 'package:genesis/screens/main/main_screen.dart';

class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  late AnimationController _scanController;

  String _authState = 'idle'; // 'idle', 'scanning', 'success', 'error'
  bool _isFingerprint = true;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() => _authState = 'scanning');

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access Genesis ERP',
        biometricOnly: true,
      );
      if (didAuthenticate) {
        Get.to(() => MainScreen());
        Toaster.showSuccess2("Authorization", "authorization was succefull");
      } else {
        setState(() => _authState = 'error');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _authState = 'idle');
        });
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      setState(() => _authState = 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: _BlurCircle(color: Colors.cyan.withAlpha(30)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22D3EE), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "GENESIS ERP",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    "VEHICLE MANAGEMENT SYSTEM",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: GTheme.emmense(context),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "User",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "Authorize session",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            _ToggleSwitch(
                              isFingerprint: _isFingerprint,
                              onToggle: (val) =>
                                  setState(() => _isFingerprint = val),
                            ),
                            IconButton(
                              onPressed: () => Get.to(() => LoginScreen()),
                              icon: Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Biometric Button
                        GestureDetector(
                          onTap: _authState == 'scanning'
                              ? null
                              : _authenticate,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _AnimatedRing(
                                isScanning: _authState == 'scanning',
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _authState == 'error'
                                      ? Colors.red.withAlpha(30)
                                      : Colors.grey.withAlpha(40),
                                  border: Border.all(
                                    color: _authState == 'error'
                                        ? Colors.red.withAlpha(124444444448)
                                        : Colors.white12,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  _isFingerprint
                                      ? Icons.fingerprint
                                      : Icons.face,
                                  size: 60,
                                  color: _authState == 'error'
                                      ? Colors.redAccent
                                      : null,
                                ),
                              ),
                              if (_authState == 'scanning')
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: AnimatedBuilder(
                                    animation: _scanController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: ScanLinePainter(
                                          _scanController.value,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ).constrained(maxHeight: 70),

                        const SizedBox(height: 30),
                        Text(
                          _authState == 'scanning'
                              ? "Scanning..."
                              : "Tap to Scan",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ).constrained(maxHeight: 300),

                  const SizedBox(height: 40),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Success Overlay
          if (_authState == 'success')
            Container(
              color: const Color(0xFF0A0E14),
              width: double.infinity,
              height: double.infinity,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.greenAccent,
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Identity Verified",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Loading Fleet Management...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ScanLinePainter extends CustomPainter {
  final double progress;
  ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22D3EE)
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    double y = size.height * progress;
    canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), paint);
  }

  @override
  bool shouldRepaint(covariant ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  const _BlurCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool isFingerprint;
  final Function(bool) onToggle;

  const _ToggleSwitch({required this.isFingerprint, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            active: isFingerprint,
            icon: Icons.fingerprint,
            onTap: () => onToggle(true),
          ),
          _ToggleBtn(
            active: !isFingerprint,
            icon: Icons.face,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.active,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF22D3EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: active ? Colors.black : null),
      ),
    );
  }
}

class _AnimatedRing extends StatefulWidget {
  final bool isScanning;
  const _AnimatedRing({required this.isScanning});

  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isScanning) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _AnimatedRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.isScanning ? _controller.repeat() : _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 120 + (widget.isScanning ? _controller.value * 40 : 0),
          height: 120 + (widget.isScanning ? _controller.value * 40 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF22D3EE).withAlpha(
                widget.isScanning
                    ? 255 - (_controller.value * 255).toInt()
                    : 20,
              ),
            ),
          ),
        );
      },
    );
  }
}
