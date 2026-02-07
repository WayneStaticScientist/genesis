import 'package:exui/exui.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/screens/auth/login_screen.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/widgets/actions/form_button.dart';
import 'package:genesis/widgets/actions/form_input.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = Get.find<UserController>();

  // Controllers for editable fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with current user data from the controller/model
    final user = _userController.user.value;
    _firstNameController = TextEditingController(text: user?.firstName ?? "");
    _lastNameController = TextEditingController(text: user?.lastName ?? "");
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 500;
    final user = _userController.user.value;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1000 : 500,
            maxHeight: isDesktop ? 750 : double.infinity,
          ),
          margin: const EdgeInsets.all(24),
          decoration: isDesktop
              ? BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                )
              : null,
          child: [
            // Left Side: Status and Statistics (Desktop Only)
            if (isDesktop)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Get.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        "${user?.firstName[0] ?? ''}${user?.lastName[0] ?? ''}"
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    24.gapHeight,
                    "Account Status".text(
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    (user?.status ?? "Active").toUpperCase().text(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    32.gapHeight,
                    _buildStatRow(
                      Icons.directions_car,
                      "Total Trips",
                      "${user?.trips ?? 0}",
                    ),
                    16.gapHeight,
                    _buildStatRow(
                      Icons.star,
                      "Rating",
                      "${user?.rating ?? 0.0}",
                    ),
                    16.gapHeight,
                    _buildStatRow(
                      Icons.verified_user,
                      "Experience",
                      "${user?.experience ?? 'N/A'}",
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "Email Address".text(
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          (user?.email ?? "").text(
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).expanded1,

            // Right Side: Editable Form & Logout
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 16,
                vertical: 32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isDesktop) ...[
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          "${user?.firstName[0] ?? ''}${user?.lastName[0] ?? ''}"
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      12.gapHeight,
                      (user?.status ?? "Active").text(
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      24.gapHeight,
                    ],

                    "My Profile".text(
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    "Update your personal information".text(
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    34.gapHeight,

                    GFormInput(
                      label: "First Name",
                      controller: _firstNameController,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Required" : null,
                    ),
                    20.gapHeight,

                    GFormInput(
                      label: "Last Name",
                      controller: _lastNameController,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Required" : null,
                    ),
                    20.gapHeight,

                    GFormInput(
                      label: "New Password (Leave blank to keep current)",
                      controller: _passwordController,
                      isPasswordField: true,
                    ),
                    32.gapHeight,

                    GFormButton(
                      label: 'Update Profile',
                      onPress: _updateProfile,
                      isLoading: _userController.loading.value,
                    ),

                    40.gapHeight,
                    const Divider(),
                    20.gapHeight,

                    // Logout Section
                    ListTile(
                      onTap: _logout,
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: "Logout".text(
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: "Sign out of your account".text(
                        style: const TextStyle(fontSize: 10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.withAlpha(30)),
                      ),
                      tileColor: Colors.red.withAlpha(27),
                    ),
                  ],
                ),
              ),
            ).expanded1,
          ].row(),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        12.gapWidth,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label.text(
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            value.text(style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  void _updateProfile() async {
    if (_formKey.currentState?.validate() != true) return;

    // Logic to call controller update
    final success = await _userController.updateUser(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      password: _passwordController.text.isEmpty
          ? null
          : _passwordController.text,
    );

    if (success) {
      Toaster.showSuccess("Profile Updated Successfully");
    }
  }

  void _logout() {
    Get.defaultDialog(
      title: "Logout",
      content: "Are you sure to logout".text(),
      textCancel: "no",
      textConfirm: "yes",
      onConfirm: () {
        _userController
            .logout(); // Ensure this calls User.clearStorage() internally
        Toaster.showSuccess("Logged out");
        Get.offAll(() => const LoginScreen());
      },
    );
  }
}
