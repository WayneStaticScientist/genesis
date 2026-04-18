import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:genesis/controllers/vehicle_controller.dart';

class AssignTripModal extends StatefulWidget {
  final User driver;
  const AssignTripModal({super.key, required this.driver});

  @override
  State<AssignTripModal> createState() => _AssignTripModalState();
}

class _AssignTripModalState extends State<AssignTripModal> {
  final _userController = Get.find<UserController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _distanceInKmController = TextEditingController(
    text: "0",
  );
  final VehicleControler vehicleController = Get.find<VehicleControler>();
  final TextEditingController _loadTypeController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController _loadWeightController = TextEditingController();
  late final TextEditingController _tripPaymentController =
      TextEditingController(text: '0');
  final TextEditingController _destinationNameController =
      TextEditingController();
  final TextEditingController _portOfExitController = TextEditingController();
  final TextEditingController _portOfEntryController = TextEditingController();

  // Controllers for the new pickers
  final TextEditingController _originCoordsController = TextEditingController();
  final Rx<DateTime> departureDateTime = DateTime.now()
      .add(const Duration(hours: 1))
      .obs;
  final Rx<DateTime> arrivalDateTime = DateTime.now()
      .add(const Duration(hours: 10))
      .obs;
  final Rx<LatLng?> originCoords = Rx<LatLng?>(null);

  // Multi-destinations
  List<TextEditingController> destinationNameControllers = [];
  List<TextEditingController> destinationCoordControllers = [];
  List<Rx<LatLng?>> destinationCoordsList = [];

  // Tollgate entries
  List<TextEditingController> tollgateNameControllers = [];
  List<TextEditingController> tollgateAmountControllers = [];

  // Selection State
  final Rx<VehicleModel?> selectedVehicle = Rx<VehicleModel?>(null);
  final RxString selectedTripType = "Local".obs;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    vehicleController.fetchAllVehicles(page: 1, search: '');

    // Add first destination
    _addDestination();

    // Infinite scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!vehicleController.loadingVehicles.value &&
            vehicleController.page.value < vehicleController.totalPages.value) {
          vehicleController.fetchAllVehicles(
            page: vehicleController.page.value + 1,
            search: _searchController.text,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _loadTypeController.dispose();
    _loadWeightController.dispose();
    _tripPaymentController.dispose();
    _destinationNameController.dispose();
    _searchController.dispose();
    _portOfExitController.dispose();
    _portOfEntryController.dispose();
    for (var controller in destinationNameControllers) {
      controller.dispose();
    }
    for (var controller in destinationCoordControllers) {
      controller.dispose();
    }
    for (var controller in tollgateNameControllers) {
      controller.dispose();
    }
    for (var controller in tollgateAmountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addDestination() {
    setState(() {
      destinationNameControllers.add(TextEditingController());
      destinationCoordControllers.add(TextEditingController());
      destinationCoordsList.add(Rx<LatLng?>(null));
    });
  }

  void _addTollgate() {
    setState(() {
      tollgateNameControllers.add(TextEditingController());
      tollgateAmountControllers.add(TextEditingController(text: '0'));
    });
  }

  void _removeDestination(int index) {
    setState(() {
      destinationNameControllers[index].dispose();
      destinationCoordControllers[index].dispose();
      destinationNameControllers.removeAt(index);
      destinationCoordControllers.removeAt(index);
      destinationCoordsList.removeAt(index);
    });
  }

  void _removeTollgate(int index) {
    setState(() {
      tollgateNameControllers[index].dispose();
      tollgateAmountControllers[index].dispose();
      tollgateNameControllers.removeAt(index);
      tollgateAmountControllers.removeAt(index);
    });
  }

  void _onSearchChanged(String value) {
    vehicleController.fetchAllVehicles(page: 1, search: value);
  }

  // Helper to pick Date and Time
  Future<void> _pickDateTime(BuildContext context, Rx<DateTime> target) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: target.value,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(target.value),
      );

      if (pickedTime != null) {
        target.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  void _setOriginMap() async {
    final LatLng? result = await Get.to(() => const MapPickerScreen());
    if (result != null) {
      originCoords.value = result;
      _originCoordsController.text =
          "Selected: ${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: GTheme.isDark(context).lord(Colors.grey[900], Colors.white),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "New Trip Assignment",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Assigning to ${widget.driver.firstName}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                _buildInputLabel("TRIP TYPE"),
                _buildTripTypeSelector(),

                Obx(() {
                  if (selectedTripType.value == "Cross-Border") {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputLabel("PORT OF EXIT"),
                                  TextFormField(
                                    controller: _portOfExitController,
                                    decoration: _modernInputDecoration(
                                      Icons.exit_to_app,
                                      "e.g. Beitbridge",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputLabel("PORT OF ENTRY"),
                                  TextFormField(
                                    controller: _portOfEntryController,
                                    decoration: _modernInputDecoration(
                                      Icons.login,
                                      "e.g. Chirundu",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 25),

                // Vehicle Selection Section (Required)
                _buildInputLabel("SELECT VEHICLE *"),
                Obx(() => _buildVehicleSelector()),

                12.gapHeight,
                const SizedBox(height: 20),
                _buildInputLabel("ORIGIN"),
                TextFormField(
                  controller: originController,
                  decoration: _modernInputDecoration(Icons.map, "Enter Origin"),
                ),
                12.gapHeight,

                TextFormField(
                  controller: _originCoordsController,
                  readOnly: true,
                  onTap: _setOriginMap,
                  decoration:
                      _modernInputDecoration(
                        Icons.location_pin,
                        "Cordinates",
                      ).copyWith(
                        suffixIcon: const Icon(
                          Icons.location_searching,
                          size: 20,
                        ),
                      ),
                ),
                const SizedBox(height: 20),

                // Destination Input
                _buildInputLabel("DESTINATION"),
                TextFormField(
                  controller: _receiverController,
                  decoration: _modernInputDecoration(
                    Icons.commute_sharp,
                    "Company Name/Client",
                  ),
                ),
                12.gapHeight,
                _buildMultiDestinationsSection(),
                12.gapHeight,
                _buildTollgatesSection(),
                12.gapHeight,
                _buildInputLabel("Distance In KM"),
                TextFormField(
                  controller: _distanceInKmController,
                  decoration: _modernInputDecoration(
                    Icons.edit_road_sharp,
                    "Distance in Km",
                  ),
                ),
                const SizedBox(height: 20),

                // Schedule Visualizer
                _buildInputLabel("SCHEDULE (DATE & TIME)"),
                Obx(() => _buildScheduleSection()),

                const SizedBox(height: 20),

                // Details Row (Load Type & Weight)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("LOAD TYPE"),
                          TextFormField(
                            controller: _loadTypeController,
                            decoration: _modernInputDecoration(
                              Icons.local_shipping,
                              "Type",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("WEIGHT (KG)"),
                          TextFormField(
                            controller: _loadWeightController,
                            decoration: _modernInputDecoration(
                              Icons.scale,
                              "kgs",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Payment Section
                _buildPaymentSection(),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _initiateNewTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(100),
                    ),
                    child: Obx(
                      () => _userController.processingTrip.value
                          ? WhiteLoader()
                          : const Text(
                              "CONFIRM ASSIGNMENT",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeSelector() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => selectedTripType.value = "Local",
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedTripType.value == "Local"
                      ? GTheme.primary(context).withAlpha(30)
                      : GTheme.emmense(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedTripType.value == "Local"
                        ? GTheme.primary(context)
                        : Colors.grey.withAlpha(50),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      size: 20,
                      color: selectedTripType.value == "Local"
                          ? GTheme.primary(context)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Local",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedTripType.value == "Local"
                            ? GTheme.primary(context)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => selectedTripType.value = "Cross-Border",
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedTripType.value == "Cross-Border"
                      ? GTheme.primary(context).withAlpha(30)
                      : GTheme.emmense(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedTripType.value == "Cross-Border"
                        ? GTheme.primary(context)
                        : Colors.grey.withAlpha(50),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.public,
                      size: 20,
                      color: selectedTripType.value == "Cross-Border"
                          ? GTheme.primary(context)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Cross-Border",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedTripType.value == "Cross-Border"
                            ? GTheme.primary(context)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Column(
      children: [
        // Selection Display / Search Trigger
        GestureDetector(
          onTap: () => _showVehicleListBottomSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedVehicle.value != null
                    ? GTheme.primary(context)
                    : GTheme.emmense(context),
                width: selectedVehicle.value != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_filled,
                  color: selectedVehicle.value != null
                      ? GTheme.primary(context)
                      : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedVehicle.value != null
                        ? "${selectedVehicle.value?.carModel} (${selectedVehicle.value?.licencePlate})"
                        : "Select available vehicle",
                    style: TextStyle(
                      color: selectedVehicle.value != null
                          ? null
                          : Colors.grey[600],
                      fontWeight: selectedVehicle.value != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showVehicleListBottomSheet() {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          color: GTheme.isDark(context).lord(Colors.grey[900], Colors.blue[50]),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text(
              "Select Vehicle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: _modernInputDecoration(
                Icons.search,
                "Search plate, make or model...",
              ),
            ),
            const SizedBox(height: 15),
            // List
            Expanded(
              child: Obx(() {
                if (vehicleController.loadingVehicles.value &&
                    vehicleController.vehicles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vehicleController.vehicles.isEmpty) {
                  return const Center(child: Text("No vehicles found"));
                }

                return ListView.separated(
                  controller: _scrollController,
                  itemCount:
                      vehicleController.vehicles.length +
                      (vehicleController.page.value <
                              vehicleController.totalPages.value
                          ? 1
                          : 0),
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.withAlpha(50)),
                  itemBuilder: (context, index) {
                    if (index == vehicleController.vehicles.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    final vehicle = vehicleController.vehicles[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.local_shipping),
                      ),
                      title: Text("${vehicle.carModel}"),
                      subtitle: Text("Plate: ${vehicle.licencePlate}"),
                      trailing: selectedVehicle.value?.id == vehicle.id
                          ? Icon(Icons.check_circle)
                          : null,
                      onTap: () {
                        selectedVehicle.value = vehicle;
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

  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(50)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              const Icon(Icons.circle, size: 12, color: Colors.blue),
              Container(width: 2, height: 55, color: Colors.grey[300]),
              const Icon(Icons.circle_outlined, size: 12, color: Colors.red),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Departure",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                GestureDetector(
                  onTap: () => _pickDateTime(context, departureDateTime),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          GenesisDate.getInformalDate(departureDateTime.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.calendar_month, size: 18),
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.grey.withAlpha(50)),
                Text(
                  "Est. Arrival",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                GestureDetector(
                  onTap: () => _pickDateTime(context, arrivalDateTime),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          GenesisDate.getInformalDate(arrivalDateTime.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.flag_outlined, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(27),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withAlpha(70)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TRIP PAYMENT",
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              const Text("Per completed trip", style: TextStyle(fontSize: 12)),
            ],
          ),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: _tripPaymentController,
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              decoration: InputDecoration(
                label: "Enter Amount".text(),
                prefixText: "\$ ",
                prefixStyle: TextStyle(color: Colors.green[800], fontSize: 24),
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMultiDestinationsSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: destinationNameControllers.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: destinationNameControllers[index],
                        decoration: _modernInputDecoration(
                          Icons.map,
                          "Enter destination ${index + 1} city/depot",
                        ),
                      ),
                    ),
                    if (destinationNameControllers.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeDestination(index),
                      ),
                  ],
                ),
                12.gapHeight,
                TextFormField(
                  controller: destinationCoordControllers[index],
                  readOnly: true,
                  onTap: () => _selectLocationForDestination(index),
                  decoration:
                      _modernInputDecoration(
                        Icons.location_pin,
                        "Coordinates for destination ${index + 1}",
                      ).copyWith(
                        suffixIcon: const Icon(
                          Icons.location_searching,
                          size: 20,
                        ),
                      ),
                ),
                if (index < destinationNameControllers.length - 1) 12.gapHeight,
              ],
            );
          },
        ),
        12.gapHeight,
        ElevatedButton.icon(
          onPressed: _addDestination,
          icon: Icon(Icons.add),
          label: Text("Add Another Destination"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTollgatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel("TOLLGATES"),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tollgateNameControllers.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: tollgateNameControllers[index],
                        decoration: _modernInputDecoration(
                          Icons.toll,
                          "Tollgate name ${index + 1}",
                        ),
                      ),
                    ),
                    if (tollgateNameControllers.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeTollgate(index),
                      ),
                  ],
                ),
                12.gapHeight,
                TextFormField(
                  controller: tollgateAmountControllers[index],
                  keyboardType: TextInputType.number,
                  decoration: _modernInputDecoration(
                    Icons.currency_exchange,
                    "Amount for tollgate ${index + 1}",
                  ),
                ),
                if (index < tollgateNameControllers.length - 1) 12.gapHeight,
              ],
            );
          },
        ),
        12.gapHeight,
        ElevatedButton.icon(
          onPressed: _addTollgate,
          icon: Icon(Icons.add),
          label: Text("Add Tollgate"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _selectLocationForDestination(int index) async {
    final LatLng? result = await Get.to(() => const MapPickerScreen());
    if (result != null) {
      destinationCoordsList[index].value = result;
      destinationCoordControllers[index].text =
          "Selected: ${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
    }
  }

  InputDecoration _modernInputDecoration(IconData icon, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: GTheme.emmense(context),
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: GTheme.emmense(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: GTheme.color(context), width: 1.5),
      ),
    );
  }

  void _initiateNewTrip() async {
    if (selectedVehicle.value == null) {
      Toaster.showErrorTop(
        "Vehicle Required",
        "Please select a vehicle before confirming.",
      );
      return;
    }
    final loadType = _loadTypeController.text.trim();
    final loadWeight = double.tryParse(_loadWeightController.text.trim());
    final tripPrice = double.tryParse(_tripPaymentController.text.trim());
    final distanceInKm = double.tryParse(_distanceInKmController.text.trim());
    if (tripPrice == null) {
      return Toaster.showErrorTop(
        "Invalid trip Amount",
        "You have entered an invalid number on trip amount",
      );
    }
    if (distanceInKm == null) {
      return Toaster.showErrorTop(
        "Invalid Distance ",
        "You have entered an invalid number on distance",
      );
    }
    final origin = originController.text.trim();
    if (origin.isEmpty) {
      Toaster.showErrorTop(
        "Origin City required",
        "Please enter origin name before confirming.",
      );
      return;
    }

    // Validate destinations
    List<Map<String, dynamic>> destinations = [];
    for (int i = 0; i < destinationNameControllers.length; i++) {
      final name = destinationNameControllers[i].text.trim();
      if (name.isEmpty) {
        Toaster.showErrorTop(
          "Destination required",
          "Please enter name for destination ${i + 1}.",
        );
        return;
      }
      destinations.add({
        "name": name,
        "location": destinationCoordsList[i].value != null
            ? {
                "lng": destinationCoordsList[i].value!.longitude,
                "lat": destinationCoordsList[i].value!.latitude,
              }
            : null,
      });
    }

    // Validate tollgates
    double totalTollgateFees = 0;
    List<Map<String, dynamic>> tollgates = [];
    for (int i = 0; i < tollgateNameControllers.length; i++) {
      final tollName = tollgateNameControllers[i].text.trim();
      final tollAmount = double.tryParse(
        tollgateAmountControllers[i].text.trim(),
      );
      if (tollName.isEmpty) {
        Toaster.showErrorTop(
          "Tollgate required",
          "Please enter name for tollgate ${i + 1}.",
        );
        return;
      }
      if (tollAmount == null) {
        Toaster.showErrorTop(
          "Invalid Tollgate Amount",
          "Please enter a valid amount for tollgate ${i + 1}.",
        );
        return;
      }
      totalTollgateFees += tollAmount;
      tollgates.add({"name": tollName, "amount": tollAmount});
    }

    final response = await _userController.startTrip(
      data: {
        "origin": origin,
        "loadType": loadType,
        "loadWeight": loadWeight,
        "distance": distanceInKm,
        "tripPayout": tripPrice,
        "driver": widget.driver.id,
        "tolgateFees": totalTollgateFees,
        "tollgates": tollgates,
        "destinations": destinations,
        "vehicle": selectedVehicle.value?.id,
        "tripType": selectedTripType.value,
        "portOfExit": selectedTripType.value == "Cross-Border"
            ? _portOfExitController.text.trim()
            : null,
        "portOfEntry": selectedTripType.value == "Cross-Border"
            ? _portOfEntryController.text.trim()
            : null,
        "receiver": _receiverController.text.trim(),
        "startTime": departureDateTime.value.toIso8601String(),
        "estimatedEndTime": arrivalDateTime.value.toIso8601String(),
        "locationOrigin": originCoords.value != null
            ? {
                "lng": originCoords.value!.longitude,
                "lat": originCoords.value!.latitude,
              }
            : null,
      },
    );
    if (response) {
      Get.back();
      Toaster.showSuccess2("Trip", "trip has been succefully initiated");
      _userController.fetchDrivers();
    }
  }
}

// Separate Screen for Map Picking
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _center = const LatLng(-26.2041, 28.0473); // Default Joburg

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Destination"),
        actions: [
          IconButton(
            onPressed: () => Get.back(result: _center),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 12),
            onCameraMove: (pos) => _center = pos.target,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Icon(Icons.location_pin, color: Colors.red, size: 45),
            ),
          ),
        ],
      ),
    );
  }
}
