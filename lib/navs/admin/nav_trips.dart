import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/layouts/trip_card.dart';
import 'package:genesis/controllers/trips_controller.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:genesis/screens/trips/trips_details_screen.dart';

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
  final _tripsController = Get.find<TripsController>();
  final List<String> _statuses = [
    "All",
    "Active",
    "Pending",
    "Completed",
    "Cancelled",
  ];

  @override
  void initState() {
    super.initState();
    _tripsController.fetchTrips();
  }
  // Mock data representing the models provided

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
            child: Obx(() {
              if (_tripsController.trips.isEmpty &&
                  _tripsController.loadingTrips.value) {
                return MaterialLoader().center();
              }
              if (_tripsController.trips.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tripsController.trips.length,
                itemBuilder: (context, index) {
                  return TripCard(trip: _tripsController.trips[index]).onTap(
                    () => Get.to(
                      () => TripDetailsScreen(
                        tripId: _tripsController.trips[index].vehicle.id,
                      ),
                    ),
                  );
                },
              );
            }),
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
