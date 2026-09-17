import 'package:flutter/material.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart' as Geo;

class SpeedingReportsScreen extends StatefulWidget {
  final String vehicleId;
  final String vehicleName;

  const SpeedingReportsScreen({
    Key? key,
    required this.vehicleId,
    required this.vehicleName,
  }) : super(key: key);

  @override
  State<SpeedingReportsScreen> createState() => _SpeedingReportsScreenState();
}

class _SpeedingReportsScreenState extends State<SpeedingReportsScreen> {
  bool _isLoading = true;
  List<dynamic> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    final response = await Net.get("/vehicle/${widget.vehicleId}/speeding-reports");
    if (!response.hasError) {
      setState(() {
        _reports = response.body['list'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Speeding Reports",
          style: GoogleFonts.plusJakartaSans(
            color: GTheme.reverse(context),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: GTheme.reverse(context), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: WhiteLoader(color: GTheme.reverse(context)))
          : _reports.isEmpty
              ? Center(
                  child: Text(
                    "No speeding reports found.",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    return _SpeedingReportCard(report: _reports[index]);
                  },
                ),
    );
  }
}

class _SpeedingReportCard extends StatefulWidget {
  final dynamic report;
  const _SpeedingReportCard({Key? key, required this.report}) : super(key: key);

  @override
  State<_SpeedingReportCard> createState() => _SpeedingReportCardState();
}

class _SpeedingReportCardState extends State<_SpeedingReportCard> {
  String _locationName = "Loading location...";

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final lat = (widget.report['lat'] as num?)?.toDouble();
      final lng = (widget.report['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        List<Geo.Placemark> placemarks = await Geo.placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final Geo.Placemark pos = placemarks.first;
          final parts = [pos.subLocality, pos.locality, pos.administrativeArea]
              .where((e) => e != null && e.isNotEmpty)
              .toList();
          setState(() {
            _locationName = parts.isNotEmpty ? parts.join(", ") : "Unknown Location";
          });
          return;
        }
      }
      setState(() {
        _locationName = "Unknown Location";
      });
    } catch (e) {
      setState(() {
        _locationName = "Location unavailable";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final speed = widget.report['speed']?.toStringAsFixed(1) ?? '0';
    final limit = widget.report['speedLimit']?.toString() ?? '0';
    final dateStr = widget.report['createdAt'];
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.speed, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$speed km/h",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      "Limit: $limit km/h",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _locationName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
