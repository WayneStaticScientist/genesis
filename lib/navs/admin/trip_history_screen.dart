import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:genesis/utils/theme.dart';

import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/utils/toast.dart';
import 'package:line_icons/line_icons.dart';

class TripHistoryScreen extends StatefulWidget {
  final String vehicleId;
  const TripHistoryScreen({super.key, required this.vehicleId});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _historyList = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final response = await Net.get("/vehicle/${widget.vehicleId}/route-summary", queryParameters: {
      "limit": "30" // Fetch up to 30 days
    });
    
    if (response.hasError) {
      Toaster.showError("Failed to fetch history");
    } else {
      _historyList = response.body['list'] ?? [];
    }
    
    setState(() => _isLoading = false);
  }

  void _replayDay(String dateStr) {
    Get.back(result: DateTime.parse(dateStr));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Trip History"),
        backgroundColor: GTheme.surface(context),
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _historyList.isEmpty 
          ? const Center(child: Text("No trip history found for this vehicle."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                final item = _historyList[index];
                final dateStr = item['date'] ?? '';
                final distance = (item['totalDistance'] as num?)?.toDouble() ?? 0.0;
                final idleTimeSecs = (item['totalIdleTime'] as num?)?.toInt() ?? 0;
                final idleMins = idleTimeSecs ~/ 60;
                
                // Format locations
                final startLoc = item['startLocation'];
                final endLoc = item['endLocation'];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: GTheme.surface(context),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${distance.toStringAsFixed(1)} km",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const Divider(height: 24),
                        if (startLoc != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Start: ${startLoc['lat'].toStringAsFixed(4)}, ${startLoc['lng'].toStringAsFixed(4)}",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        if (endLoc != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "End: ${endLoc['lat'].toStringAsFixed(4)}, ${endLoc['lng'].toStringAsFixed(4)}",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LineIcons.clock, color: Colors.orange, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "Idled: $idleMins mins",
                                  style: const TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => _replayDay(dateStr),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("Replay on Map"),
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
