import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/models/user_model.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/vehicle_utlis.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/controllers/vehicle_controller.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';

class AdminEditVehicle extends StatefulWidget {
  final VehicleModel vehicle;

  const AdminEditVehicle({super.key, required this.vehicle});

  @override
  State<AdminEditVehicle> createState() => _AdminEditVehicleState();
}

class _AdminEditVehicleState extends State<AdminEditVehicle> {
  final _driversController = Get.find<UserController>();
  final _vehicleController = Get.find<VehicleControler>();
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late String _selectedStatus;
  late String? _selectedType;
  late double _fuelRation;
  late bool _initialUserInitiliazed = widget.vehicle.driver == null;
  // Added state for driver
  User? _assignedDriver;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController(text: widget.vehicle.carModel);
    _plateController = TextEditingController(text: widget.vehicle.licencePlate);
    _selectedStatus = widget.vehicle.status;
    _selectedType = widget.vehicle.engineType.isEmpty
        ? VehicleUtlis.engineTypes[0]
        : widget.vehicle.engineType;
    _fuelRation = widget.vehicle.fuelRatio;
    WidgetsBinding.instance.addPostFrameCallback((tick) {
      _getDriver();
    });
    // Initialize driver if your vehicle model has driver info
    // if (widget.vehicle.driverId != null) { ... }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _saveVehicle() async {
    // Logic to update the vehicle object or send to API
    final updatedVehicle = {
      "carModel": _modelController.text,
      "licencePlate": _plateController.text,
      "status": _selectedStatus,
      "engineType": _selectedType,
      "fuelRatio": _fuelRation,
      // Add driver ID if selected
      "driver": _assignedDriver?.id,
    };

    final data = await _vehicleController.updateVehicle(
      updatedVehicle,
      widget.vehicle.id ?? '',
    );
    if (data) {
      Toaster.showSuccess("vehicle updated succefully");
    }
  }

  // New function to show driver selection
  void _showAssignDriverSheet() {
    // MOCK DATA: Replace with your actual DriverController list
    _driversController.fetchDrivers();

    showModalBottomSheet(
      context: context,
      backgroundColor: GTheme.color(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Assign Driver".text(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: GTheme.reverse(),
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.remove, color: GTheme.reverse()),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _assignedDriver = null;
                      });
                    },
                    label: "remove".text(),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: GTheme.reverse()),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    itemCount: _driversController.drivers.length,
                    separatorBuilder: (c, i) =>
                        Divider(color: Colors.grey.withAlpha(50)),
                    itemBuilder: (context, index) {
                      final driver = _driversController.drivers[index];
                      final isSelected = _assignedDriver?.id == driver.id;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(30),
                          child: Text(
                            driver.firstName[0],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        title: "${driver.firstName} ${driver.lastName}"
                            .toString()
                            .text(
                              style: TextStyle(
                                color: GTheme.reverse(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        subtitle: driver.status.toString().text(
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _assignedDriver = driver;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
            child: Obx(
              () => _vehicleController.registeringVehicle.value
                  ? MaterialLoader()
                  : "Save".text(
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ).padding(EdgeInsets.only(right: 12)),
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
            _buildLabel("Fleet Management"),

            // --- NEW: ASSIGN DRIVER BUTTON ---
            GestureDetector(
              onTap: _showAssignDriverSheet,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: GTheme.reverse().withAlpha(10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_pin_circle_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          (_assignedDriver != null
                                  ? "${_assignedDriver!.firstName} ${_assignedDriver!.lastName}"
                                  : "Assign Driver (Tap to select)")
                              .toString()
                              .text(
                                style: TextStyle(
                                  color: _assignedDriver != null
                                      ? GTheme.reverse()
                                      : GTheme.reverse().withAlpha(128),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                    ),
                    Icon(Icons.arrow_drop_down, color: GTheme.reverse()),
                  ],
                ),
              ),
            ).visibleIf(_initialUserInitiliazed),
            "Loading Assigned Driver".text().visibleIf(
              !_initialUserInitiliazed,
            ),
            [MaterialLoader()]
                .row(mainAxisAlignment: MainAxisAlignment.center)
                .margin(EdgeInsets.symmetric(vertical: 10))
                .visibleIf(!_initialUserInitiliazed),
            // ---------------------------------
            _buildDropdown(
              value: _selectedStatus,
              items: VehicleUtlis.vehicleStatuses,
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
                    items: VehicleUtlis.engineTypes,
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: "Cost/KM (\$)",
                    initialValue: _fuelRation.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        _fuelRation = double.tryParse(val) ?? 0.0,
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
    required String? value,
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

  void _getDriver() async {
    if (widget.vehicle.driver == null) return;
    final response = await _driversController.fetchUser(widget.vehicle.driver!);
    setState(() {
      _initialUserInitiliazed = true;
      _assignedDriver = response;
    });
  }
}
