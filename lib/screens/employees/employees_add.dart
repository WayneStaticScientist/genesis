import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/utils/managers_permissions.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/widgets/inputs/white_formfield.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

// --- MOCK THEME (Consistent with GTheme) ---

class EmployeeAddScreen extends StatefulWidget {
  const EmployeeAddScreen({super.key});

  @override
  State<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'driver'; // Default role
  bool _obscurePassword = true;
  final _userController = Get.find<UserController>();
  List<String> permissions = List.empty(growable: true);
  // Manager Specific Permissions
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.surface(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Add New Employee",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),

              // 1. Profile Information Section
              _buildSectionTitle("Basic Information"),
              WhiteFormfield(
                "Full Name",
                LineIcons.user,
                hint: "John Doe",
                validator: (String? input) {
                  if (input == null) return "This field should not be empty";
                  String filteredName = input.replaceAll(
                    RegExp('\\s{2,}'),
                    ' ',
                  );
                  if (filteredName.trim().split(" ").length < 2)
                    return "please enter full name e.g like John Doe";
                  return null;
                },
                obscurePassword: false,
                controller: fullNameController,
              ),
              const SizedBox(height: 16),
              WhiteFormfield(
                "Email Address",
                LineIcons.envelope,
                hint: "john@genesis.com",
                obscurePassword: false,
                controller: emailController,
                validator: (String? input) {
                  if (input == null || input.trim().length < 3)
                    return "invalid email";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              WhiteFormfield(
                "Password",
                LineIcons.lock,
                hint: "••••••••",
                isPassword: true,
                obscurePassword: _obscurePassword,
                controller: passwordController,
                validator: (String? input) {
                  if (input == null || input.trim().length < 3)
                    return "invalid password";
                  return null;
                },
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? LineIcons.eyeSlash : LineIcons.eye,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 30),

              // 2. Role Selection Section
              _buildSectionTitle("Select System Role"),
              _buildRoleSelector(),

              const SizedBox(height: 20),

              // 3. Conditional Permissions Section (Only for Managers)
              if (_selectedRole == 'manager') ...[
                _buildSectionTitle("Manager Permissions"),
                _buildPermissionsGrid(),
              ],

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GTheme.primary(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 8,
                    shadowColor: GTheme.primary(context).withAlpha(100),
                  ),
                  child: Obx(
                    () => _userController.registeringEmployee.value
                        ? WhiteLoader()
                        : const Text(
                            "Create Employee Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Onboard Talent",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: GTheme.primary(context),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Fill in the credentials to provide system access.",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    final roles = [
      {'id': 'admin', 'label': 'Admin', 'icon': LineIcons.userShield},
      {'id': 'manager', 'label': 'Manager', 'icon': LineIcons.users},
      {'id': 'driver', 'label': 'Driver', 'icon': LineIcons.car},
    ];

    return Row(
      children: roles.map((role) {
        bool isSelected = _selectedRole == role['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRole = role['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected ? GTheme.primary(context) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: GTheme.primary(context).withAlpha(70),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                border: Border.all(
                  color: isSelected
                      ? GTheme.primary(context)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    role['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPermissionsGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo.withAlpha(30)),
      ),
      child: Column(
        children: ManagersPermissions.permissions.map((perm) {
          final hasPermission = permissions.contains(perm);
          return CheckboxListTile(
            value: hasPermission,
            title: Text(
              perm,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            activeColor: GTheme.primary(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onChanged: (val) => setState(() {
              if (hasPermission) {
                permissions.remove(perm);
              } else {
                permissions.add(perm);
              }
            }),
          );
        }).toList(),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      Toaster.showErrorTop(
        "Input Errors",
        "please fill the fields with errors",
      );
      return;
    }
    final filteredName = fullNameController.text.replaceAll(
      RegExp('\\s{2,}'),
      ' ',
    );
    final firstName = filteredName.trim().split(" ")[0];
    final lastName = filteredName.trim().split(" ")[1];
    final response = await _userController.registerEmployee({
      "trips": 0,
      "email": emailController.text.replaceAll(" ", '').toLowerCase(),
      "lastName": lastName,
      "password": passwordController.text,
      "firstName": firstName,
      "role": _selectedRole,
      "country": _userController.user.value!.country,
      "permissions": _selectedRole == "manager" ? permissions : [],
    });
    if (response && mounted) {
      _userController.findChats();
      Get.back();
      Toaster.showSuccess('Employee added success');
    }
  }
}
