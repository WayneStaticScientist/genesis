import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:line_icons/line_icons.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/utils/genesis_settings.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/screens/auth/profile_screen.dart';
import 'package:genesis/controllers/company_controller.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';

class AdminSettingsScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminSettingsScreen({super.key, this.triggerKey});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _userController = Get.find<UserController>();
  final _companyController = Get.find<CompanyController>();
  @override
  Widget build(BuildContext context) {
    final settings = GenesisSettings.readSettings();
    return Scaffold(
      backgroundColor: GTheme.surface(context),
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
              color: Colors.pink,
              title: "System Theme Mode",
              subtitle: "use system dark/light mode",
              trailing: Switch.adaptive(
                value: settings.isSystemThemeMode,
                activeThumbColor: GTheme.primary(context),
                onChanged: (val) {
                  settings.isSystemThemeMode = val;
                  settings.writeSettings();
                  _recalculateThemeSettings(settings);
                  setState(() {});
                },
              ),
            ),
            _buildSettingCard(
              icon: LineIcons.moon,
              color: Colors.purple,
              title: "Dark Theme",
              subtitle: "Adjust the interface for low light",
              trailing: Switch.adaptive(
                value: settings.isDarkMode,
                activeThumbColor: GTheme.primary(context),
                onChanged: (val) {
                  settings.isDarkMode = val;
                  settings.writeSettings();
                  _recalculateThemeSettings(settings);
                  setState(() {});
                },
              ),
            ).visibleIfNot(settings.isSystemThemeMode),
            if (_userController.user.value!.role != "driver" &&
                _companyController.company.value?.settings != null) ...[
              const SizedBox(height: 25),
              _buildSectionHeader("Operations & Automation"),
              _buildSettingCard(
                icon: LineIcons.tools,
                color: Colors.orange,
                title: "Auto-Approve Maintenance",
                subtitle: "Approve routine requests automatically",
                trailing: Obx(
                  () => _companyController.updatingCompanySettings.value
                      ? MaterialLoader()
                      : Switch.adaptive(
                          value: _companyController
                              .company
                              .value!
                              .settings
                              .autoApproveMaintainances,
                          activeThumbColor: GTheme.primary(context),
                          onChanged: (val) {
                            final map = _companyController
                                .company
                                .value!
                                .settings
                                .toJson();
                            map['autoApproveMaintainances'] = val;
                            _companyController.updateCompanySettings(map);
                            _companyController.company.value!.saveToStorage();
                            setState(() {});
                          },
                        ),
                ),
              ),
              _buildSettingCard(
                icon: LineIcons.userAlt,
                color: Colors.green,
                title: "Driver managed Maintainances",
                subtitle:
                    "Allow driver add maintainances issue to his/her vehicle",
                trailing: Obx(
                  () => _companyController.updatingCompanySettings.value
                      ? MaterialLoader()
                      : Switch.adaptive(
                          value: _companyController
                              .company
                              .value!
                              .settings
                              .driverManagedMaintainances,
                          activeThumbColor: GTheme.primary(context),
                          onChanged: (val) {
                            final map = _companyController
                                .company
                                .value!
                                .settings
                                .toJson();
                            map['driverManagedMaintainances'] = val;
                            _companyController.updateCompanySettings(map);
                            _companyController.company.value!.saveToStorage();
                            setState(() {});
                          },
                        ),
                ),
              ),
            ],

            const SizedBox(height: 25),
            _buildSectionHeader("User Adjustments"),
            // _buildAdjustmentSlider(),
            _buildSettingCard(
              icon: LineIcons.fingerprint,
              color: Colors.teal,
              title: "Biometric Login",
              subtitle: "Use FaceID or Fingerprint",
              trailing: Switch.adaptive(
                value: settings.biometricLockScreen,
                activeThumbColor: GTheme.primary(context),
                onChanged: (val) {
                  settings.biometricLockScreen = val;
                  settings.writeSettings();
                  _recalculateThemeSettings(settings);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionHeader("Account"),
            _buildSettingCard(
              icon: LineIcons.alternateSignOut,
              color: Colors.redAccent,
              title: "Account Management",
              subtitle: "view your account",
              onTap: () {
                Get.to(() => ProfileScreen());
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
        color: GTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
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
            color: color.withAlpha(30),
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

  void _recalculateThemeSettings(GenesisSettings settings) {
    if (settings.isSystemThemeMode) {
      Get.changeThemeMode(ThemeMode.system);
      return;
    }
    Get.changeThemeMode(
      settings.isDarkMode.lord(ThemeMode.dark, ThemeMode.light),
    );
    return;
  }

  // Widget _buildAdjustmentSlider() {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.02),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text(
  //               "Search Radius",
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //             ),
  //             Text(
  //               "${_radiusAdjustment.toInt()} km",
  //               style: TextStyle(
  //                 color: GTheme.primary(context),
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           "Adjust the maximum distance for job matching",
  //           style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
  //         ),
  //         Slider.adaptive(
  //           value: _radiusAdjustment,
  //           min: 1,
  //           max: 50,
  //           activeColor: GTheme.primary(context),
  //           inactiveColor: Colors.grey.shade100,
  //           onChanged: (val) => setState(() => _radiusAdjustment = val),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
