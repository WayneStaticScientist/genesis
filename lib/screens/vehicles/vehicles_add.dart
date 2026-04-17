import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:exui/material.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/licence_model.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/vehicle_controller.dart';

class AdminAddVehicle extends StatefulWidget {
  const AdminAddVehicle({super.key});

  @override
  State<AdminAddVehicle> createState() => _AdminAddVehicleState();
}

class _AdminAddVehicleState extends State<AdminAddVehicle> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleController = Get.find<VehicleControler>();
  // Form State
  String _model = "";
  String _plate = "";
  String _status = "Active";
  String _type = "Electric";
  String _engineNumber = "";
  String _vinNumber = "";
  final TextEditingController _licenceNumber = TextEditingController();
  final TextEditingController _licenceClass = TextEditingController();
  final TextEditingController _expiryDate = TextEditingController();
  DateTime? expiryDate;
  double _fuelRatio = 0.0;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      int? licenceClass = int.tryParse(_licenceClass.text);
      if (licenceClass == null && expiryDate != null) {
        Toaster.showError("Invalide licence class Number , Valid are 1-5");
      }
      String licenceNumber = _licenceNumber.text.trim().toLowerCase();
      if (licenceNumber.isEmpty && expiryDate != null) {
        return Toaster.showError(
          "Invalid licence number , it should not be empty",
        );
      }
      final newVehicle = {
        "usage": 0, // Initial usage
        "type": _type,
        "status": _status,
        "carModel": _model,
        "engineType": _type,
        "engineNumber": _engineNumber.trim(),
        "vinNumber": _vinNumber.trim(),
        "licencePlate": _plate,
        "fuelRatio": _fuelRatio,
      };
      final response = await _vehicleController.registerVehicle(
        newVehicle,
        expiryDate != null
            ? LicenceModel(
                expiryDate: expiryDate!,
                licenceClass: licenceClass!,
                licenceNumber: licenceNumber,
              ).toJson()
            : null,
      );
      if (mounted && response) {
        Get.back();
        Toaster.showSuccess("vehicle registered success");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTheme.color(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: GTheme.reverse(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: "New Vehicle".text(
          style: TextStyle(
            color: GTheme.reverse(context),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Obx(
                () => _vehicleController.registeringVehicle.value
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
              // Hero Illustration/Icon
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_road_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    "Add to Fleet".text(
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionHeader("Identification"),
              _buildField(
                label: "Model",
                hint: "e.g. Ford F-150 Lightning",
                icon: Icons.directions_car_filled_rounded,
                onSaved: (val) => _model = val ?? "",
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              _buildField(
                label: "Engine Number",
                hint: "Enter engine number",
                icon: Icons.settings_input_component,
                onSaved: (val) => _engineNumber = val ?? "",
              ),
              _buildField(
                label: "Chassis (VIN) Number",
                hint: "Enter VIN number",
                icon: Icons.pin,
                onSaved: (val) => _vinNumber = val ?? "",
              ),

              const SizedBox(height: 24),
              _sectionHeader("Configuration"),
              [
                Expanded(
                  child: _buildDropdown(
                    label: "Engine Type",
                    value: _type,
                    items: ["Electric", "Diesel", "Petrol", "Hybrid"],
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    label: "FuelRatio per KM",
                    hint: "0.00",
                    icon: Icons.gas_meter,
                    keyboardType: TextInputType.number,
                    onSaved: (val) =>
                        _fuelRatio = double.tryParse(val ?? "0") ?? 0.0,
                  ),
                ),
              ].row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              ),

              const SizedBox(height: 16),
              _buildDropdown(
                label: "Initial Status",
                value: _status,
                items: ["Active", "In Service", "Idle"],
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),
              _sectionHeader("Licence Information"),
              _buildField(
                label: "Licence Number",
                hint: "16digit number",
                controller: _licenceNumber,
                icon: Icons.shield,
              ),
              _buildField(
                label: "Licence Class",
                hint: "1-5",
                controller: _licenceClass,
                icon: Icons.numbers,
              ),
              _buildField(
                label: "Expiry Date",
                hint: "Tap to select",
                editable: false,
                controller: _expiryDate,
                icon: Icons.calendar_month,
                ontap: () => selectDate(context),
              ),
              if (expiryDate != null) ...[
                "Revoke Licence"
                    .text()
                    .elevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(side: BorderSide.none),
                      ),
                      onPressed: () {
                        setState(() {
                          expiryDate = null;
                          _licenceClass.text = '';
                          _licenceNumber.text = '';
                          _expiryDate.text = '';
                        });
                      },
                    )
                    .sizedBox(width: double.infinity),
              ],

              const SizedBox(height: 40),
              // Tips card
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
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          "New vehicles are automatically logged in the audit trail."
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
          color: GTheme.reverse(context).withAlpha(128),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    bool editable = true,
    TextInputType? keyboardType,
    TextEditingController? controller,
    VoidCallback? ontap,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GTheme.reverse(context).withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        readOnly: !editable,
        controller: controller,
        onTap: () => ontap?.call(),
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(color: GTheme.reverse(context)),
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
            color: GTheme.reverse(context).withAlpha(100),
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
            color: GTheme.reverse(context).withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              labelStyle: const TextStyle(fontSize: 14),
            ),
            dropdownColor: GTheme.color(context),
            style: TextStyle(color: GTheme.reverse(context), fontSize: 14),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: e.text()))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _expiryDate.text = GenesisDate.formatNormalDateN(picked);
        expiryDate = picked;
      });
    }
  }
}
