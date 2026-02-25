import 'package:flutter/material.dart';
import 'package:genesis/models/current_vehicle_model.dart';
import 'package:genesis/models/populated_location_model.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/layouts/trip_card.dart';

/// --- MODELS (Included here for self-containment) ---

/// --- MAIN SCREEN ---

class NavTrips extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;

  const NavTrips({super.key, this.triggerKey});

  @override
  State<NavTrips> createState() => _NavTripsState();
}

class _NavTripsState extends State<NavTrips> {
  // State for filtering
  String _searchQuery = "";
  String _selectedStatus = "All";
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statuses = [
    "All",
    "Active",
    "Pending",
    "Completed",
    "Cancelled",
  ];

  // Mock data representing the models provided
  final List<TripModel> _allTrips = [
    TripModel(
      status: "Active",
      loadType: "Heavy Machinery",
      loadWeight: 12500,
      tripPayout: 2450.00,
      destination: "Nairobi, Kenya",
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: null,
      startFuelLevel: 0.85,
      endFuelLevel: null,
      estimatedEndTime: DateTime.now().add(const Duration(hours: 6)),
      vehicle: CurrentVehicleModel(id: "v1", carModel: "Scania R500"),
      location: PopulatedLocationModel(lat: -1.28, lng: 36.82),
    ),
    TripModel(
      status: "Pending",
      loadType: "Perishables",
      loadWeight: 4200,
      tripPayout: 850.50,
      destination: "Mombasa Port",
      startTime: DateTime.now().add(const Duration(days: 1)),
      endTime: null,
      startFuelLevel: 1.0,
      endFuelLevel: null,
      estimatedEndTime: null,
      vehicle: CurrentVehicleModel(id: "v2", carModel: "Volvo FH16"),
      location: null,
    ),
    TripModel(
      status: "Completed",
      loadType: "Construction Materials",
      loadWeight: 18000,
      tripPayout: 3100.00,
      destination: "Kampala, Uganda",
      startTime: DateTime.now().subtract(const Duration(days: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 5)),
      startFuelLevel: 0.9,
      endFuelLevel: 0.2,
      estimatedEndTime: null,
      vehicle: CurrentVehicleModel(id: "v3", carModel: "Mercedes Actros"),
      location: null,
    ),
  ];

  List<TripModel> get _filteredTrips {
    return _allTrips.where((trip) {
      final matchesSearch =
          trip.destination.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          trip.vehicle.carModel.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          trip.loadType.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _selectedStatus == "All" || trip.status == _selectedStatus;

      bool matchesDate = true;
      if (_selectedDateRange != null && trip.startTime != null) {
        matchesDate =
            trip.startTime!.isAfter(_selectedDateRange!.start) &&
            trip.startTime!.isBefore(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTheme.surface(),
        leading: DrawerButton(
          onPressed: () {
            widget.triggerKey?.currentState?.openDrawer();
          },
        ),
        elevation: 0,
        title: const Text(
          "Trip Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilterHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Recent Trips",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _filteredTrips.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTrips.length,
                    itemBuilder: (context, index) {
                      return TripCard(trip: _filteredTrips[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: GTheme.surface(),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search destination, vehicle or load...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
              filled: true,
              fillColor: GTheme.cardColor(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Chips and Date Picker
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statuses.map((status) {
                      final isSelected = _selectedStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (val) =>
                              setState(() => _selectedStatus = status),
                          backgroundColor: Colors.transparent,
                          selectedColor: GTheme.primary.withOpacity(0.1),
                          checkmarkColor: GTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? GTheme.primary
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? GTheme.primary
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Date Range Picker Button
              IconButton(
                onPressed: _pickDateRange,
                icon: Icon(
                  Icons.calendar_month,
                  color: _selectedDateRange != null
                      ? GTheme.primary
                      : Colors.grey,
                ),
                tooltip: "Filter by Date",
              ),
            ],
          ),
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: GTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}",
                          style: TextStyle(
                            fontSize: 12,
                            color: GTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDateRange = null),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: GTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      saveText: "Apply",
    );
    if (result != null) {
      setState(() => _selectedDateRange = result);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No trips found",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = "";
                _selectedStatus = "All";
                _selectedDateRange = null;
                _searchController.clear();
              });
            },
            child: const Text("Clear all filters"),
          ),
        ],
      ),
    );
  }
}
