import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/widgets/actions/deduction_tile.dart';
import 'package:genesis/widgets/actions/section_header.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:exui/material.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/licence_model.dart';
import 'package:genesis/utils/vehicle_utlis.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/controllers/user_controller.dart';
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
  late DateTime? expiryDate = widget.vehicle.licence?.expiryDate;
  late bool _initialUserInitiliazed = widget.vehicle.driver == null;
  // Added state for driver
  User? _assignedDriver;
  late TextEditingController _licenceNumber = TextEditingController(
    text: widget.vehicle.licence?.licenceNumber ?? '',
  );
  late TextEditingController _licenceClass = TextEditingController(
    text: widget.vehicle.licence?.licenceClass.toString() ?? '',
  );
  late TextEditingController _expiryDate = TextEditingController(
    text: GenesisDate.formatNormalDateN(widget.vehicle.licence?.expiryDate),
  );
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
    final updatedVehicle = {
      "carModel": _modelController.text,
      "licencePlate": _plateController.text,
      "status": _selectedStatus,
      "engineType": _selectedType,
      "fuelRatio": _fuelRation,
      // Add driver ID if selected
      "insurances": widget.vehicle.insurances.map(((e) => e.toJson())).toList(),
      "driver": _assignedDriver?.id,
      "licence": expiryDate != null
          ? LicenceModel(
              expiryDate: expiryDate!,
              licenceClass: licenceClass!,
              licenceNumber: licenceNumber,
            ).toJson()
          : null,
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
    _driversController.fetchDrivers();
    showModalBottomSheet(
      context: context,
      backgroundColor: GTheme.color(context),
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
                      color: GTheme.reverse(context),
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.remove, color: GTheme.reverse(context)),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _assignedDriver = null;
                      });
                    },
                    label: "remove".text(),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: GTheme.reverse(context)),
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
                                color: GTheme.reverse(context),
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
      backgroundColor: GTheme.color(context),
      appBar: AppBar(
        systemOverlayStyle: GTheme.copyOverlay(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: GTheme.reverse(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Edit Vehicle".text(
          style: TextStyle(
            color: GTheme.reverse(context),
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
                  color: GTheme.reverse(context).withAlpha(10),
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
                                      ? GTheme.reverse(context)
                                      : GTheme.reverse(context).withAlpha(128),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                    ),
                    Icon(Icons.arrow_drop_down, color: GTheme.reverse(context)),
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
            const SizedBox(height: 16),
            _buildLabel("Licence Information"),
            _buildTextField(
              label: "Licence Number",
              controller: _licenceNumber,
              icon: Icons.shield,
            ),
            _buildTextField(
              label: "Licence Class",
              controller: _licenceClass,
              icon: Icons.numbers,
            ),
            _buildTextField(
              label: "Expiry Date",
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

            const SizedBox(height: 20),
            SectionHeader(
              title: "Insurance",
              icon: Icons.security,
              onAdd: () {
                _addDeduction();
              },
            ),
            ...widget.vehicle.insurances.map(
              (i) => DeductionTile(
                item: i,
                onRemove: () {
                  setState(() {
                    widget.vehicle.insurances.remove(i);
                  });
                },
              ),
            ),
            // Delete Action
            const SizedBox(height: 40),

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
    bool editable = true,
    VoidCallback? ontap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GTheme.reverse(context).withAlpha(10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        readOnly: !editable,
        onTap: () => ontap?.call(),
        controller: controller,
        initialValue: initialValue,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(color: GTheme.reverse(context)),
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
        color: GTheme.reverse(context).withAlpha(10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: GTheme.color(context),
          style: TextStyle(color: GTheme.reverse(context)),
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
    final response = await _driversController.fetchUser(
      widget.vehicle.driver!.id,
    );
    setState(() {
      _initialUserInitiliazed = true;
      _assignedDriver = response;
    });
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

  void _addDeduction() {
    final nameController = TextEditingController();
    final valController = TextEditingController();
    DeductionType selectedType = DeductionType.percentage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text("New Deduction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name (e.g. VAT)"),
              ),
              TextField(
                controller: valController,
                decoration: const InputDecoration(labelText: "Value"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              SegmentedButton<DeductionType>(
                segments: const [
                  ButtonSegment(value: DeductionType.fixed, label: Text("\$")),
                ],
                selected: {selectedType},
                onSelectionChanged: (set) =>
                    setInnerState(() => selectedType = set.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.vehicle.insurances.add(
                    DeductionItem(
                      name: nameController.text,
                      value: double.tryParse(valController.text) ?? 0,
                      deductionType: DeductionType.fixed,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
