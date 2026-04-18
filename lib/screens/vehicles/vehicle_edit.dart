import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:exui/material.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/licence_model.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/utils/vehicle_utlis.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/widgets/actions/section_header.dart';
import 'package:genesis/widgets/actions/deduction_tile.dart';
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
  late TextEditingController _engineNumberController;
  late TextEditingController _vinNumberController;
  late String _selectedStatus;
  late String? _selectedType;
  late String _selectedLoadType;
  late double _fuelRation;
  late double _emptyFuelRatio;
  late double _loadedFuelRatio;
  late DateTime? expiryDate = widget.vehicle.licence?.expiryDate;
  late bool _initialUserInitiliazed = widget.vehicle.driver == null;
  // Added state for driver
  User? _assignedDriver;
  late List<Map<String, dynamic>> _serviceReminders;
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
    _engineNumberController = TextEditingController(
      text: widget.vehicle.engineNumber ?? '',
    );
    _vinNumberController = TextEditingController(
      text: widget.vehicle.vinNumber ?? '',
    );
    _selectedStatus = widget.vehicle.status;
    _selectedType = widget.vehicle.engineType.isEmpty
        ? VehicleUtlis.engineTypes[0]
        : widget.vehicle.engineType;
    _selectedLoadType = "Standard";
    _fuelRation = widget.vehicle.fuelRatio;
    _emptyFuelRatio = 0.0;
    _loadedFuelRatio = widget.vehicle.fuelRatio;
    _serviceReminders = widget.vehicle.serviceReminders
        .map((e) => e.toJson())
        .toList();
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
    _engineNumberController.dispose();
    _vinNumberController.dispose();
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
      "engineNumber": _engineNumberController.text.trim(),
      "vinNumber": _vinNumberController.text.trim(),
      "status": _selectedStatus,
      "engineType": _selectedType,
      "loadType": _selectedLoadType,
      "fuelRatio": _selectedLoadType == "Loader"
          ? _loadedFuelRatio
          : _fuelRation,
      if (_selectedLoadType == "Loader") ...{
        "emptyRatio": _emptyFuelRatio,
        "loadedFuelRatio": _loadedFuelRatio,
      },
      "serviceReminders": _serviceReminders,
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
            _buildTextField(
              controller: _engineNumberController,
              label: "Engine Number",
              icon: Icons.settings_input_component,
            ),
            _buildTextField(
              controller: _vinNumberController,
              label: "Chassis (VIN) Number",
              icon: Icons.pin,
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
                  child: _buildDropdown(
                    label: "Vehicle Load Type",
                    value: _selectedLoadType,
                    items: ["Standard", "Loader"],
                    onChanged: (val) =>
                        setState(() => _selectedLoadType = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedLoadType != "Loader")
              _buildTextField(
                label: "Fuel Ratio per KM",
                initialValue: _fuelRation.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) => _fuelRation = double.tryParse(val) ?? 0.0,
                icon: Icons.attach_money,
              )
            else ...[
              _buildTextField(
                label: "Empty Ratio per KM",
                initialValue: _emptyFuelRatio.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) =>
                    _emptyFuelRatio = double.tryParse(val) ?? 0.0,
                icon: Icons.airline_stops,
              ),
              _buildTextField(
                label: "Loaded Ratio per KM",
                initialValue: _loadedFuelRatio.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) =>
                    _loadedFuelRatio = double.tryParse(val) ?? 0.0,
                icon: Icons.local_shipping,
              ),
            ],
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

            _buildLabel("Service Reminders"),
            ..._serviceReminders.map(
              (reminder) => _buildReminderTile(reminder),
            ),
            ElevatedButton.icon(
              onPressed: _addServiceReminder,
              icon: Icon(Icons.add),
              label: Text("Add Reminder"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ).sizedBox(width: double.infinity),

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

  Widget _buildReminderTile(Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GTheme.reverse(context).withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${reminder['type']}: ${reminder['type'] == 'date' ? GenesisDate.formatNormalDate(DateTime.parse(reminder['date'])) : '${reminder['mileage']}'}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _serviceReminders.remove(reminder);
              });
            },
          ),
        ],
      ),
    );
  }

  void _addServiceReminder() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    String selectedType = "mileage";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text("Add Service Reminder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Reminder Name (e.g., Tyre Change)",
                ),
              ),
              DropdownButton<String>(
                value: selectedType,
                items: [
                  DropdownMenuItem(value: "mileage", child: Text("By Mileage")),
                  DropdownMenuItem(value: "date", child: Text("By Date")),
                ],
                onChanged: (val) => setInnerState(() => selectedType = val!),
              ),
              if (selectedType == "mileage")
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: "Mileage (e.g., 1000km)",
                  ),
                  keyboardType: TextInputType.number,
                )
              else
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(labelText: "Date"),
                  readOnly: true,
                  onTap: () => _selectReminderDate(context, valueController),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  setState(() {
                    _serviceReminders.add({
                      "name": nameController.text,
                      "type": selectedType,
                      if (selectedType == 'date') "date": valueController.text,
                      if (selectedType == 'mileage')
                        "mileage": valueController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectReminderDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String();
    }
  }
}
