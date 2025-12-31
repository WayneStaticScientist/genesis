import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class AdminEditVehicle extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const AdminEditVehicle({super.key, required this.vehicle});

  @override
  State<AdminEditVehicle> createState() => _AdminEditVehicleState();
}

class _AdminEditVehicleState extends State<AdminEditVehicle> {
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late String _selectedStatus;
  late String _selectedType;
  late double _cost;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController(text: widget.vehicle['model']);
    _plateController = TextEditingController(text: widget.vehicle['plate']);
    _selectedStatus = widget.vehicle['status'];
    _selectedType = widget.vehicle['type'];
    _cost = widget.vehicle['cost'];
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    // Logic to update the vehicle object or send to API
    final updatedVehicle = {
      ...widget.vehicle,
      "model": _modelController.text,
      "plate": _plateController.text,
      "status": _selectedStatus,
      "type": _selectedType,
      "cost": _cost,
    };

    // In a real app, you'd use a Provider/Bloc here
    Navigator.pop(context, updatedVehicle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.color(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: GTheme.reverse()),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Edit Vehicle".text(
          style: TextStyle(
            color: GTheme.reverse(),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveVehicle,
            child: "Save".text(
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ).paddingOnly(right: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Visual Header
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedType == "Electric"
                      ? Icons.bolt
                      : Icons.directions_car,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            _buildLabel("Vehicle Details"),
            _buildTextField(
              controller: _modelController,
              label: "Model Name",
              icon: Icons.directions_car_filled,
            ),
            _buildTextField(
              controller: _plateController,
              label: "License Plate",
              icon: Icons.badge,
            ),

            const SizedBox(height: 16),
            _buildLabel("Fleet Status"),
            _buildDropdown(
              value: _selectedStatus,
              items: ["Active", "In Service", "Idle", "Out of Action"],
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),

            const SizedBox(height: 16),
            _buildLabel("Operational Details"),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: "Engine Type",
                    value: _selectedType,
                    items: ["Electric", "Diesel", "Petrol", "Hybrid"],
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: "Cost/KM (\$)",
                    initialValue: _cost.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _cost = double.tryParse(val) ?? 0.0,
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Delete Action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {}, // Implementation for deletion
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: "Decommission Vehicle".text(
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: text.text(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GTheme.reverse().withAlpha(10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(color: GTheme.reverse()),
        decoration: InputDecoration(
          labelText: label,
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
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    String? label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: GTheme.reverse().withAlpha(10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: GTheme.color(),
          style: TextStyle(color: GTheme.reverse()),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: e.text()))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
