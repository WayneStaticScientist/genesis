import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/vehicle_controller.dart'; // Ensure this exists
import 'package:genesis/controllers/maintainance_controller.dart';

class AdminAddMaintenance extends StatefulWidget {
  const AdminAddMaintenance({super.key});

  @override
  State<AdminAddMaintenance> createState() => _AdminAddMaintenanceState();
}

class _AdminAddMaintenanceState extends State<AdminAddMaintenance> {
  final _formKey = GlobalKey<FormState>();
  final _mantainanceController = Get.find<MaintainanceController>();
  final _vehicleController = Get.find<VehicleControler>();

  // Form State
  String _issue = "";
  String _urgency = "Routine";
  double _cost = 0.0;
  double _health = 85.0;
  int _daysLeft = 14;
  String? _selectedLicencePlate;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLicencePlate == null) {
        Toaster.showError("Please select a vehicle");
        return;
      }
      _formKey.currentState!.save();

      final newTask = {
        "urgenceLevel": _urgency,
        "dueDate": DateTime.now()
            .add(Duration(days: _daysLeft))
            .toIso8601String(),
        "issueDetails": _issue,
        "estimatedCosts": _cost,
        "currentHealth": _health,
        "licencePlate": _selectedLicencePlate,
      };

      final response = await _mantainanceController.addMantainance(newTask);
      if (response) {
        Get.back();
        Toaster.showSuccess("Maintenance task added");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
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
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: _mantainanceController.addingMaintainance.value
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _mantainanceController.addingMaintainance.value
                    ? const SizedBox.shrink()
                    : const Icon(Icons.add_task_rounded, size: 18),
                label: _mantainanceController.addingMaintainance.value
                    ? WhiteLoader()
                    : "Create".text(
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
              _sectionHeader("Target Vehicle"),

              // === SEARCHABLE PAGINATED DROPDOWN ===
              _buildVehicleSelector(),

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSaved: (val) => _cost = double.tryParse(val ?? "0") ?? 0.0,
              ),

              const SizedBox(height: 40),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: ListTile(
        onTap: _showVehicleSearchSheet,
        leading: Icon(
          Icons.directions_car_filled_outlined,
          color: Colors.blueAccent.withAlpha(210),
        ),
        title: (_selectedLicencePlate ?? "Select Vehicle").text(
          style: TextStyle(
            color: _selectedLicencePlate == null
                ? Colors.white.withAlpha(100)
                : Colors.white,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white54,
        ),
      ),
    );
  }

  void _showVehicleSearchSheet() {
    _vehicleController.fetchAllVehicles();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            "Search Vehicle".text(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (val) => _vehicleController.fetchAllVehicles(
                search: val,
              ), // Implement debounced search in controller
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter Licence Plate...",
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (_vehicleController.loadingVehicles.value &&
                    _vehicleController.vehicles.isEmpty) {
                  return Center(child: WhiteLoader());
                }
                return ListView.builder(
                  itemCount:
                      _vehicleController.vehicles.length +
                      (_vehicleController.totalPages.value >
                              _vehicleController.currentPage.value
                          ? 1
                          : 0),
                  itemBuilder: (context, index) {
                    if (index == _vehicleController.vehicles.length) {
                      _vehicleController.fetchAllVehicles(
                        page: _vehicleController.currentPage.value + 1,
                      ); // Trigger next page
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: WhiteLoader(),
                        ),
                      );
                    }
                    final vehicle = _vehicleController.vehicles[index];
                    return ListTile(
                      title: vehicle.licencePlate.text(
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: "${vehicle.carModel} ${vehicle.licencePlate}"
                          .text(
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                      onTap: () {
                        setState(
                          () => _selectedLicencePlate = vehicle.licencePlate,
                        );
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: title.toUpperCase().text(
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.blueAccent.withAlpha(230),
          letterSpacing: 1.2,
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
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
    );
  }
}
