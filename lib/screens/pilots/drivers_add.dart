import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/controllers/user_controller.dart';

class AdminAddDriver extends StatefulWidget {
  const AdminAddDriver({super.key});

  @override
  State<AdminAddDriver> createState() => _AdminAddDriverState();
}

class _AdminAddDriverState extends State<AdminAddDriver> {
  final _userController = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _safety = TextEditingController(text: '100'); // Default safety score
  final _email = TextEditingController();
  String password = '';
  final _rating = TextEditingController(text: 5.0.toString());
  final _experience = TextEditingController();
  String _status = "Available";

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final filteredName = _name.text.replaceAll(RegExp('\\s{2,}'), ' ');
    final firstName = filteredName.trim().split(" ")[0];
    final lastName = filteredName.trim().split(" ")[1];
    _formKey.currentState!.save();
    final response = await _userController.registerDriver(
      User(
        trips: 0,
        email: _email.text,
        safety: int.tryParse(_safety.text) ?? 0,
        rating: double.tryParse(_rating.text),
        lastName: lastName,
        password: password,
        firstName: firstName,
        experience: _experience.text,
        country: _userController.user.value!.country,
      ),
    );
    if (response && mounted) {
      Get.back();
      Toaster.showSuccess('driver added success');
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.color(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: GTheme.reverse()),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Register Pilot".text(
          style: TextStyle(
            color: GTheme.reverse(),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Obx(
              () => ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _userController.registeringDriver.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : "Register".text(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for Profile Photo Upload
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: GTheme.reverse().withAlpha(25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GTheme.reverse().withAlpha(25),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        size: 32,
                        color: GTheme.reverse().withAlpha(128),
                      ),
                    ),
                    const SizedBox(height: 16),
                    "Upload Driver ID Photo".text(
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionHeader("Onboarding Details"),
              _buildField(
                label: "Full Name",
                hint: "Enter legal name",
                controller: _name,
                icon: Icons.person_add_alt_1_rounded,
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
              ),
              _buildField(
                label: "Eamil",
                hint: "Enter legal name",
                icon: Icons.email,
                controller: _email,
                validator: (String? input) {
                  if (input == null || input.trim().length < 3)
                    return "invalid email";
                  return null;
                },
              ),
              _buildField(
                controller: _experience,
                label: "Experience Level",
                hint: "e.g. 2 Years, Senior, Junior",
                icon: Icons.workspace_premium_rounded,
              ),
              _sectionHeader("Driver Pin"),

              Pinput(
                onCompleted: (pin) => setState(() {
                  password = pin;
                }),
              ),

              const SizedBox(height: 24),
              _sectionHeader("Initial Compliance"),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: "Initial Rating",
                      hint: "5.0",
                      icon: Icons.star_rounded,
                      keyboardType: TextInputType.number,
                      controller: _rating,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      label: "Safety Score",
                      hint: "100",
                      icon: Icons.verified_user_rounded,
                      keyboardType: TextInputType.number,
                      controller: _safety,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildDropdown(
                label: "Initial Duty Status",
                value: _status,
                items: ["Available", "Offline"],
                onChanged: (val) => setState(() => _status = val!),
              ),

              const SizedBox(height: 40),
              // Compliance Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withAlpha(25)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          "New pilots must complete the mandatory safety orientation before their first trip."
                              .text(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: title.text(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: GTheme.reverse().withAlpha(128),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextEditingController? controller,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GTheme.reverse().withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        validator: validator,
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: GTheme.reverse()),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: const TextStyle(fontSize: 14),
          hintStyle: TextStyle(
            color: GTheme.reverse().withAlpha(100),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: GTheme.reverse().withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              labelStyle: const TextStyle(fontSize: 14),
            ),
            dropdownColor: GTheme.color(),
            style: TextStyle(color: GTheme.reverse(), fontSize: 14),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: e.text()))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
