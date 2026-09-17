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

  final ScrollController _scrollController = ScrollController();

  // Filter States
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchRouteSummary();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_loading && _currentPage < _totalPages) {
          _fetchRouteSummary(page: _currentPage + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    if (_startDate != null && _endDate != null) {
      queryParams["startDate"] = _startDate!.toIso8601String();
      queryParams["endDate"] = _endDate!.toIso8601String();
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
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _summaries.length + (_currentPage < _totalPages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _summaries.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
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
          // Pagination Footer removed for infinite scroll
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    String dateText = "All Time";
    if (_startDate != null && _endDate != null) {
      dateText = "${GenesisDate.formatNormalDate(_startDate!)} - ${GenesisDate.formatNormalDate(_endDate!)}";
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: GTheme.surface(context),
      child: InkWell(
        onTap: () async {
          final DateTimeRange? picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            initialDateRange: _startDate != null && _endDate != null 
                ? DateTimeRange(start: _startDate!, end: _endDate!)
                : null,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: GTheme.primary(context),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            setState(() {
              _startDate = picked.start;
              // Set end date to end of day to include all logs for that day
              _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
            });
            _fetchRouteSummary(page: 1);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: GTheme.primary(context)),
                  const SizedBox(width: 12),
                  Text(
                    dateText,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              if (_startDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    _fetchRouteSummary(page: 1);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.route_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
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
    final totalIdleTimeSecs = (widget.summary['totalIdleTime'] as num?)?.toInt() ?? 0;
    final totalIdleMins = totalIdleTimeSecs ~/ 60;
    
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            totalIdleMins >= 60 ? '${totalIdleMins ~/ 60}h ${totalIdleMins % 60}m' : '$totalIdleMins min',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GTheme.primary(context).withValues(alpha: 0.1),
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
                      color: Colors.grey.withValues(alpha: 0.3),
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
                          Row(
                            children: [
                              "Started from".text(style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (widget.summary['startLocation']?['timestamp'] != null)
                                Builder(builder: (context) {
                                  final dtStr = widget.summary['startLocation']['timestamp'];
                                  final dt = DateTime.tryParse(dtStr.toString())?.toLocal();
                                  if (dt == null) return const SizedBox.shrink();
                                  return " (${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')})".text(
                                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
                                  );
                                }),
                            ],
                          ),
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
                          Row(
                            children: [
                              "Stopped at".text(style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (widget.summary['endLocation']?['timestamp'] != null)
                                Builder(builder: (context) {
                                  final dtStr = widget.summary['endLocation']['timestamp'];
                                  final dt = DateTime.tryParse(dtStr.toString())?.toLocal();
                                  if (dt == null) return const SizedBox.shrink();
                                  return " (${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')})".text(
                                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
                                  );
                                }),
                            ],
                          ),
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
