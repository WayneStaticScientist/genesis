import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:line_icons/line_icons.dart';

class AdminSettingsScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminSettingsScreen({super.key, this.triggerKey});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // Local state for toggles (In a real app, these would be in a Controller)
  bool _darkMode = false;
  bool _autoApproveMaintenance = true;
  bool _notificationsEnabled = true;
  bool _biometricAuth = false;
  double _radiusAdjustment = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.surface(),
      appBar: AppBar(
        leading: DrawerButton(
          onPressed: () {
            widget.triggerKey?.currentState?.openDrawer();
          },
        ),
        title: const Text(
          "System Settings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Appearance"),
            _buildSettingCard(
              icon: LineIcons.moon,
              color: Colors.purple,
              title: "Dark Theme",
              subtitle: "Adjust the interface for low light",
              trailing: Switch.adaptive(
                value: _darkMode,
                activeColor: GTheme.primary(),
                onChanged: (val) => setState(() => _darkMode = val),
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionHeader("Operations & Automation"),
            _buildSettingCard(
              icon: LineIcons.tools,
              color: Colors.orange,
              title: "Auto-Approve Maintenance",
              subtitle: "Approve routine requests automatically",
              trailing: Switch.adaptive(
                value: _autoApproveMaintenance,
                activeColor: GTheme.primary(),
                onChanged: (val) =>
                    setState(() => _autoApproveMaintenance = val),
              ),
            ),
            _buildSettingCard(
              icon: LineIcons.bell,
              color: Colors.blue,
              title: "Push Notifications",
              subtitle: "Alerts for new trip assignments",
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                activeColor: GTheme.primary(),
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionHeader("User Adjustments"),
            _buildAdjustmentSlider(),
            _buildSettingCard(
              icon: LineIcons.fingerprint,
              color: Colors.teal,
              title: "Biometric Login",
              subtitle: "Use FaceID or Fingerprint",
              trailing: Switch.adaptive(
                value: _biometricAuth,
                activeColor: GTheme.primary(),
                onChanged: (val) => setState(() => _biometricAuth = val),
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionHeader("Account"),
            _buildSettingCard(
              icon: LineIcons.alternateSignOut,
              color: Colors.redAccent,
              title: "Logout",
              subtitle: "End current session safely",
              onTap: () {
                // Handle logout logic
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Genesis v2.4.0 (Stable)",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing:
            trailing ??
            const Icon(LineIcons.angleRight, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildAdjustmentSlider() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Search Radius",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                "${_radiusAdjustment.toInt()} km",
                style: TextStyle(
                  color: GTheme.primary(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Adjust the maximum distance for job matching",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          Slider.adaptive(
            value: _radiusAdjustment,
            min: 1,
            max: 50,
            activeColor: GTheme.primary(),
            inactiveColor: Colors.grey.shade100,
            onChanged: (val) => setState(() => _radiusAdjustment = val),
          ),
        ],
      ),
    );
  }
}
