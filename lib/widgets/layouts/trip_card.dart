import 'package:flutter/material.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/utils/theme.dart';

/// --- TRIP CARD COMPONENT ---

class TripCard extends StatelessWidget {
  final TripModel trip;

  const TripCard({super.key, required this.trip});

  Color _getStatusColor(String status) {
    switch (status) {
      case "Active":
        return GTheme.primary;
      case "Completed":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(trip.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Top Section: ID and Status
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: statusColor.withAlpha(35),
                        radius: 18,
                        child: Icon(
                          Icons.local_shipping,
                          size: 18,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.vehicle.carModel,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "ID: ${trip.vehicle.id.toUpperCase()}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _statusChip(trip.status, statusColor),
                ],
              ),
            ),

            // Middle Section: Logistics Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _logisticsInfo("Weight", "${trip.loadWeight.toInt()} kg"),
                    const VerticalDivider(indent: 5, endIndent: 5),
                    _logisticsInfo("Type", trip.loadType),
                    const VerticalDivider(indent: 5, endIndent: 5),
                    _logisticsInfo(
                      "Payout",
                      "\$${trip.tripPayout.toStringAsFixed(2)}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Route Section
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF1F4F8).withAlpha(128),
              child: Column(
                children: [
                  _locationRow(
                    Icons.radio_button_checked,
                    "Origin",
                    "Dispatch Center",
                    GTheme.primary,
                  ),
                  _locationConnector(),
                  _locationRow(
                    Icons.location_on,
                    "Destination",
                    trip.destination,
                    Colors.redAccent,
                  ),
                ],
              ),
            ),

            // Footer Section: Fuel and Dates
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (trip.startFuelLevel != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.local_gas_station,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${(trip.startFuelLevel! * 100).toInt()}% Fuel",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  Text(
                    trip.startTime != null
                        ? "Started: ${_formatDate(trip.startTime!)}"
                        : "Scheduled",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _logisticsInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _locationRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _locationConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.5),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            width: 1,
            height: 4,
            color: Colors.grey.withAlpha(77),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
