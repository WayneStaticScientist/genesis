import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/maintainance_controller.dart';
import 'package:genesis/models/maintainance_model.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:get/get.dart';

class AdminEditMaintenance extends StatefulWidget {
  final MaintainanceModel task;
  const AdminEditMaintenance({super.key, required this.task});

  @override
  State<AdminEditMaintenance> createState() => _AdminEditMaintenanceState();
}

class _AdminEditMaintenanceState extends State<AdminEditMaintenance> {
  final _formKey = GlobalKey<FormState>();
  final _maintainanceController = Get.find<MaintainanceController>();
  late String _issue;
  late String _urgency;
  late double _cost;
  late double _health;
  late int _daysLeft;
  // Read-only fields

  @override
  void initState() {
    super.initState();
    _issue = widget.task.issueDetails;
    _urgency = widget.task.urgenceLevel;
    _cost = widget.task.estimatedCosts;
    _health = widget.task.currentHealth;
    _daysLeft = widget.task.dueDays;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedTask = {
        "issueDetails": _issue,
        "urgenceLevel": _urgency,
        "estimatedCosts": _cost,
        "currentHealth": _health.toInt(),
        "dueDays": _daysLeft,
      };
      final response = await _maintainanceController.updateMantainance(
        updatedTask,
        widget.task.id ?? '',
      );
      if (response) {
        Toaster.showSuccess("mantainance updated success");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Matches Maintenance Vault bg
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: "Update Service".text(
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.save_as_rounded, size: 18).visibleIfNot(
                  _maintainanceController.addingMaintainance.value,
                ),
                label: _maintainanceController.addingMaintainance.value
                    ? WhiteLoader()
                    : "Save".text(
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
              // Vehicle ID Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car_filled,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (widget.task.carModel ?? '').text(
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        "LP: ${widget.task.licencePlate}".text(
                          style: TextStyle(
                            color: Colors.white.withAlpha(128),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionHeader("Issue Details"),
              _buildField(
                label: "Diagnosis / Issue",
                initialValue: _issue,
                icon: Icons.build_circle_outlined,
                onSaved: (val) => _issue = val ?? "",
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: "Urgency Level",
                      value: _urgency,
                      items: ["Routine", "Due Soon", "Critical"],
                      onChanged: (val) => setState(() => _urgency = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      label: "Est. Days Left",
                      initialValue: _daysLeft.toString(),
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      onSaved: (val) =>
                          _daysLeft = int.tryParse(val ?? "0") ?? 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _sectionHeader("Status & Cost"),

              // Health Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "Vehicle Health".text(
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 14,
                        ),
                      ),
                      "${_health.toInt()}%".text(
                        style: TextStyle(
                          color: _health < 30
                              ? Colors.red
                              : (_health < 70 ? Colors.orange : Colors.green),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _health < 30
                          ? Colors.red
                          : (_health < 70 ? Colors.orange : Colors.green),
                      inactiveTrackColor: Colors.white10,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withAlpha(30),
                    ),
                    child: Slider(
                      value: _health,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (val) => setState(() => _health = val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildField(
                label: "Estimated Cost (\$)",
                initialValue: _cost.toStringAsFixed(2),
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (val) => _cost = double.tryParse(val ?? "0") ?? 0.0,
              ),

              const SizedBox(height: 40),

              // Delete Action
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Handle delete logic
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withAlpha(210),
                  ),
                  label: "Mark as Completed / Archive".text(
                    style: TextStyle(color: Colors.red.withAlpha(210)),
                  ),
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
      child: title.toUpperCase().text(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.blueAccent.withAlpha(210),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    String? initialValue,
    required IconData icon,
    TextInputType? keyboardType,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: 20,
            color: Colors.blueAccent.withAlpha(200),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: TextStyle(
            color: Colors.white.withAlpha(110),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: TextStyle(
            color: Colors.white.withAlpha(110),
            fontSize: 14,
          ),
        ),
        dropdownColor: const Color(0xFF1E293B),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white.withAlpha(128)),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: e.text()))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
