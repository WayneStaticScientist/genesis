import 'package:exui/exui.dart';
import 'package:flutter/material.dart';

class AdminAddMaintenance extends StatefulWidget {
  const AdminAddMaintenance({super.key});

  @override
  State<AdminAddMaintenance> createState() => _AdminAddMaintenanceState();
}

class _AdminAddMaintenanceState extends State<AdminAddMaintenance> {
  final _formKey = GlobalKey<FormState>();

  // Form State
  String _issue = "";
  String _urgency = "Routine";
  double _cost = 0.0;
  double _health = 85.0; // Default health for a vehicle needing maintenance
  int _daysLeft = 14;
  String _model = "";
  String _id = "";

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newTask = {
        "model": _model,
        "id": _id,
        "issue": _issue,
        "urgency": _urgency,
        "cost": _cost,
        "health": _health.toInt(),
        "daysLeft": _daysLeft,
        "color": _urgency == "Critical"
            ? Colors.red
            : _urgency == "Due Soon"
            ? Colors.orange
            : Colors.blue,
      };

      Navigator.pop(context, newTask);
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
        title: "Log New Service".text(
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: "Create".text(
                style: const TextStyle(fontWeight: FontWeight.bold),
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
              // Vehicle Selection Section
              _sectionHeader("Target Vehicle"),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: Column(
                  children: [
                    _buildField(
                      label: "Vehicle Model",
                      hint: "e.g. Ford Transit",
                      icon: Icons.directions_car_filled_outlined,
                      onSaved: (val) => _model = val ?? "",
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: "Vehicle ID / Plate",
                      hint: "e.g. GH-1102-M",
                      icon: Icons.pin_outlined,
                      onSaved: (val) => _id = val ?? "",
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionHeader("Issue Details"),
              _buildField(
                label: "Diagnosis / Issue",
                hint: "e.g. 10k Mile Service",
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
                      label: "Due In (Days)",
                      initialValue: "14",
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      onSaved: (val) =>
                          _daysLeft = int.tryParse(val ?? "0") ?? 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _sectionHeader("Status & Estimates"),

              // Health Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "Current Health".text(
                        style: TextStyle(
                          color: Colors.white.withAlpha(210),
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
                hint: "0.00",
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (val) => _cost = double.tryParse(val ?? "0") ?? 0.0,
              ),

              const SizedBox(height: 40),

              // Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          "This task will be immediately assigned to the maintenance queue."
                              .text(
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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
      child: title.toUpperCase().text(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.blueAccent.withAlpha(230),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    String? hint,
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
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withAlpha(30)),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: Colors.blueAccent.withAlpha(210),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: TextStyle(
            color: Colors.white.withAlpha(100),
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
            color: Colors.white.withAlpha(100),
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
