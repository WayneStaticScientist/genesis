import 'package:flutter/material.dart';
import 'package:exui/exui.dart';
import 'package:get/get.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:geocoding/geocoding.dart' as Geo;
import 'package:genesis/utils/date_utils.dart';

class VehicleTripsScreen extends StatefulWidget {
  final String vehicleId;
  final String carModel;

  const VehicleTripsScreen({
    super.key,
    required this.vehicleId,
    required this.carModel,
  });

  @override
  State<VehicleTripsScreen> createState() => _VehicleTripsScreenState();
}

class _VehicleTripsScreenState extends State<VehicleTripsScreen> {
  final List<Map<String, dynamic>> _summaries = [];
  bool _loading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  // Filter States
  String? _selectedMonth; // "All Months", "Jan", etc.
  String? _selectedYear; // "All Years", "2024", etc.

  final List<String> _months = [
    "All Months", "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  
  final List<String> _years = [
    "All Years", "2024", "2025", "2026", "2027"
  ];

  @override
  void initState() {
    super.initState();
    _fetchRouteSummary();
  }

  Future<void> _fetchRouteSummary({int page = 1}) async {
    setState(() {
      _loading = true;
      if (page == 1) _summaries.clear();
    });

    final queryParams = <String, dynamic>{
      "page": page,
      "limit": 12,
    };

    if (_selectedMonth != null && _selectedMonth != "All Months") {
      final index = _months.indexOf(_selectedMonth!);
      if (index > 0) {
        queryParams["month"] = index.toString();
      }
    }

    if (_selectedYear != null && _selectedYear != "All Years") {
      queryParams["year"] = _selectedYear;
    }

    final response = await Net.get(
      "/vehicle/${widget.vehicleId}/route-summary",
      queryParameters: queryParams,
    );

    setState(() {
      _loading = false;
    });

    if (response.hasError) {
      Toaster.showError("Failed to load logs: ${response.response}");
      return;
    }

    final List list = (response.body['list'] as List?) ?? [];
    setState(() {
      _currentPage = response.body['page'] ?? page;
      _totalPages = response.body['totalPages'] ?? 1;
      _totalCount = response.body['totalCount'] ?? 0;
      _summaries.addAll(list.map((e) => Map<String, dynamic>.from(e)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTheme.primary(context),
        title: Text(
          "History: ${widget.carModel}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Header Card
          _buildFilterHeader(),
          // List View
          Expanded(
            child: _loading && _summaries.isEmpty
                ? const MaterialLoader().center()
                : _summaries.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _fetchRouteSummary(page: 1),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _summaries.length,
                          itemBuilder: (context, index) {
                            final summary = _summaries[index];
                            return RouteSummaryCard(
                              summary: summary,
                              onPlay: () {
                                final dateStr = summary['date'];
                                if (dateStr != null) {
                                  DateTime? date = DateTime.tryParse(dateStr);
                                  if (date != null) {
                                    Get.back(result: date); // Return the selected date to FleetTrackingScreen
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
          // Pagination Footer
          if (_summaries.isNotEmpty) _buildPaginationFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: GTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: _selectedMonth ?? "All Months",
                items: _months,
                onChanged: (val) {
                  setState(() {
                    _selectedMonth = val;
                  });
                  _fetchRouteSummary(page: 1);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                value: _selectedYear ?? "All Years",
                items: _years,
                onChanged: (val) {
                  setState(() {
                    _selectedYear = val;
                  });
                  _fetchRouteSummary(page: 1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: _currentPage > 1 && !_loading
                ? () => _fetchRouteSummary(page: _currentPage - 1)
                : null,
          ),
          Text(
            "Page $_currentPage of $_totalPages ($_totalCount days)",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            onPressed: _currentPage < _totalPages && !_loading
                ? () => _fetchRouteSummary(page: _currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.route_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 16),
        "No logs found".text(style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        "Try selecting a different filter range".text(style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    ).center();
  }
}

class RouteSummaryCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final VoidCallback onPlay;

  const RouteSummaryCard({
    super.key,
    required this.summary,
    required this.onPlay,
  });

  @override
  State<RouteSummaryCard> createState() => _RouteSummaryCardState();
}

class _RouteSummaryCardState extends State<RouteSummaryCard> {
  String _startAddress = "Loading start location...";
  String _endAddress = "Loading end location...";

  @override
  void initState() {
    super.initState();
    _resolveAddresses();
  }

  Future<void> _resolveAddresses() async {
    final startLoc = widget.summary['startLocation'];
    final endLoc = widget.summary['endLocation'];

    if (startLoc != null) {
      final lat = (startLoc['lat'] as num).toDouble();
      final lng = (startLoc['lng'] as num).toDouble();
      _getAddressFromLatLng(lat, lng).then((addr) {
        if (mounted) setState(() => _startAddress = addr);
      });
    } else {
      if (mounted) setState(() => _startAddress = "No starting location");
    }

    if (endLoc != null) {
      final lat = (endLoc['lat'] as num).toDouble();
      final lng = (endLoc['lng'] as num).toDouble();
      _getAddressFromLatLng(lat, lng).then((addr) {
        if (mounted) setState(() => _endAddress = addr);
      });
    } else {
      if (mounted) setState(() => _endAddress = "No ending location");
    }
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Geo.Placemark> placemarks = await Geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final Geo.Placemark pos = placemarks.first;
        final subLocality = pos.subLocality ?? '';
        final city = pos.locality ?? pos.subAdministrativeArea ?? '';
        final parts = [if (subLocality.isNotEmpty) subLocality, if (city.isNotEmpty) city];
        return parts.isNotEmpty ? parts.join(", ") : "Unknown Area";
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    return "Unknown Address";
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.summary['date'] ?? '';
    final totalDist = (widget.summary['totalDistance'] as num?)?.toDouble() ?? 0.0;
    
    // Format date nicely
    DateTime? dt = DateTime.tryParse(dateStr);
    String formattedDate = dt != null ? GenesisDate.formatNormalDate(dt) : dateStr;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: GTheme.emmense(context),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Date & Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GTheme.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: "${totalDist.toStringAsFixed(1)} km".text(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: GTheme.primary(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Start/Stop Timeline
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.radio_button_checked, color: Colors.blueAccent, size: 18),
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "Started from".text(style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 2),
                          _startAddress.text(
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "Stopped at".text(style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 2),
                          _endAddress.text(
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GTheme.primary(context),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: "Play Replay".text(style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: widget.onPlay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
