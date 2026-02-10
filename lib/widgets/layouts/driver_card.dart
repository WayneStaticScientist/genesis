import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/models/user_model.dart';

class DriverCard extends StatelessWidget {
  final User user;
  final VoidCallback onAssign;

  const DriverCard({super.key, required this.user, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    bool isAvailable = user.status == 'available';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(27),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    "${user.firstName[0]}${user.lastName[0]}",
                    style: TextStyle(
                      color: GTheme.color(),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[700]),
                          Text(
                            " ${user.rating}  •  Safety: ${user.safety}%",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.currentVehicle == null
                            ? "No Vehicle Assigned"
                            : user.currentVehicle!.carModel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status & Quick Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.withAlpha(30)
                            : Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable ? "Available" : "On Trip",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quick Icon Button for Assignment
                    InkWell(
                      onTap: onAssign,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: GTheme.color().withAlpha(30),
                        child: Icon(
                          Icons.add_road,
                          size: 18,
                          color: GTheme.color(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Button Section (Always visible now, change text based on status)
          GestureDetector(
            onTap: onAssign,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isAvailable
                    ? GTheme.color().withAlpha(26)
                    : Colors.orange.withAlpha(26),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.withAlpha(30)),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAvailable ? Icons.assignment_turned_in : Icons.queue,
                      size: 16,
                      color: isAvailable ? GTheme.color() : Colors.orange[800],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable ? "ASSIGN NEW TRIP" : "QUEUE NEXT TRIP",
                      style: TextStyle(
                        color: isAvailable
                            ? GTheme.color()
                            : Colors.orange[800],
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1.0,
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
}
