import 'package:exui/exui.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/vehicle_model.dart';
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
  final VehicleControler vehicleController = Get.find<VehicleControler>();
  final TextEditingController _loadTypeController = TextEditingController();
  final TextEditingController _loadWeightController = TextEditingController();
  late final TextEditingController _tripPaymentController =
      TextEditingController(text: '0');
  final TextEditingController _destinationNameController =
      TextEditingController();

  // Controllers for the new pickers
  final TextEditingController _destinationController = TextEditingController();
  final Rx<DateTime> departureDateTime = DateTime.now()
      .add(const Duration(hours: 1))
      .obs;
  final Rx<DateTime> arrivalDateTime = DateTime.now()
      .add(const Duration(hours: 10))
      .obs;
  final Rx<LatLng?> destinationCoords = Rx<LatLng?>(null);

  // Selection State
  final Rx<VehicleModel?> selectedVehicle = Rx<VehicleModel?>(null);

  @override
  void initState() {
    super.initState();
    // Initial fetch
    vehicleController.fetchAllVehicles(page: 1, search: '');

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
    _destinationController.dispose();
    super.dispose();
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

  // Method to open Map Picker
  void _selectLocationOnMap() async {
    final LatLng? result = await Get.to(() => const MapPickerScreen());
    if (result != null) {
      destinationCoords.value = result;
      _destinationController.text =
          "Selected: ${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
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

                // Vehicle Selection Section (Required)
                _buildInputLabel("SELECT VEHICLE *"),
                Obx(() => _buildVehicleSelector()),

                const SizedBox(height: 20),

                // Destination Input
                _buildInputLabel("DESTINATION"),
                TextFormField(
                  controller: _destinationNameController,
                  decoration: _modernInputDecoration(
                    Icons.map,
                    "Enter destination city/depot",
                  ),
                ),
                12.gapHeight,
                TextFormField(
                  controller: _destinationController,
                  readOnly: true,
                  onTap: _selectLocationOnMap,
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
                    child: const Text(
                      "CONFIRM ASSIGNMENT",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildVehicleSelector() {
    return Column(
      children: [
        // Selection Display / Search Trigger
        GestureDetector(
          onTap: () => _showVehicleListBottomSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedVehicle.value != null
                    ? GTheme.color()
                    : Colors.grey[200]!,
                width: selectedVehicle.value != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_filled,
                  color: selectedVehicle.value != null
                      ? GTheme.color()
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
                          ? Colors.black
                          : Colors.grey[600],
                      fontWeight: selectedVehicle.value != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
        decoration: const BoxDecoration(
          color: Colors.white,
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
                  separatorBuilder: (_, __) => const Divider(),
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
                          ? Icon(Icons.check_circle, color: GTheme.color())
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
                const Divider(),
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

  InputDecoration _modernInputDecoration(IconData icon, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[50],
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: GTheme.color(), width: 1.5),
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
    if (tripPrice == null) {
      return Toaster.showErrorTop(
        "Invalid trip Amount",
        "You have entered an invalid number on trip amound",
      );
    }
    final destinationName = _destinationController.text.trim();
    if (destinationName.isEmpty) {
      Toaster.showErrorTop(
        "Destination City required",
        "Please enter destination name before confirming.",
      );
      return;
    }
    final response = await _userController.startTrip(
      data: {
        "loadType": loadType,
        "loadWeight": loadWeight,
        "tripPayout": tripPrice,
        "driver": widget.driver.id,
        "vehicle": selectedVehicle.value?.id,
        "startTime": departureDateTime.value.toIso8601String(),
        "estimatedEndTime": arrivalDateTime.value.toIso8601String(),
        "location": destinationCoords.value != null
            ? {
                "lng": destinationCoords.value!.longitude,
                "lat": destinationCoords.value!.latitude,
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
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GTheme.color(),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () => Get.back(result: _center),
              child: const Text(
                "CONFIRM LOCATION",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
