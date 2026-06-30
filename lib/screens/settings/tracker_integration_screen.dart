import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:line_icons/line_icons.dart';

class TrackerIntegrationScreen extends StatelessWidget {
  const TrackerIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.surface(context),
      appBar: AppBar(
        title: const Text(
          "Hardware Tracker Integration",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 24),
            const Text(
              "INTEGRATION STEPS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              context,
              stepNumber: "1",
              title: "Assign Tracker to Vehicle",
              description:
                  "Go to the 'Vehicles' section in the Admin Dashboard. Select a vehicle and click 'Add Tracker'. Input the Tracker ID (IMEI) provided by your hardware vendor.",
              icon: LineIcons.satelliteDish,
              color: Colors.blue,
            ),
            _buildStepCard(
              context,
              stepNumber: "2",
              title: "Trip Initialization",
              description:
                  "When a driver initiates a trip, the system automatically binds the trip session to the vehicle's assigned tracker. From that point on, location pings from the hardware tracker will be routed directly to the live tracking map.",
              icon: LineIcons.route,
              color: Colors.purple,
            ),
            _buildStepCard(
              context,
              stepNumber: "3",
              title: "Automatic Phone GPS Fallback",
              description:
                  "If a vehicle is not equipped with a hardware tracker, or if the tracker goes offline (e.g., dead battery, no signal), the Genesis system automatically falls back to the Driver's mobile phone GPS. The mobile app will transmit location data in the background.",
              icon: LineIcons.mobilePhone,
              color: Colors.orange,
            ),
            _buildStepCard(
              context,
              stepNumber: "4",
              title: "API Endpoint Setup (For Vendors)",
              description:
                  "If you are setting up a custom GPS tracking server (e.g., Traccar), configure the webhook to forward location packets to:\n\nPOST https://api.genesiserp.co.zw/webhook/tracker/ping\n\nEnsure the payload includes { 'trackerId': 'IMEI', 'lat': 0.0, 'lng': 0.0, 'speed': 0.0 }.",
              icon: LineIcons.code,
              color: Colors.green,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GTheme.primary(context),
            GTheme.primary(context).withBlue(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: GTheme.primary(context).withAlpha(60),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LineIcons.locationArrow,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Live Tracking Architecture",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Learn how the Genesis platform integrates external GPS hardware with mobile-device fallback for uninterrupted trip monitoring.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
