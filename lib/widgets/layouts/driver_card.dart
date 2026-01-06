import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/screens/pilots/drivers_edit.dart';
import 'package:genesis/utils/theme.dart';
import 'package:get/get.dart';

class GDriverCard extends StatelessWidget {
  final User driver;
  const GDriverCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: GTheme.color(),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          // Top Profile Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue,
                      child: Text(
                        driver.firstName[0],
                        style: TextStyle(
                          color: Colors.blue.withAlpha(30),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.firstName + " " + driver.lastName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver.rating?.toString() ?? '0',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            driver.experience ?? 'no experiencwe',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withAlpha(25),
                  ),
                ),
              ],
            ),
          ),

          // Performance Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(100),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDriverMetric(
                  Icons.directions_car,
                  "Trips",
                  "${driver.trips ?? 0}",
                ),
                _buildDriverMetric(
                  Icons.shield,
                  "Safety",
                  "${driver.safety ?? 0}%",
                ),
                _buildDriverMetric(
                  Icons.timer_outlined,
                  "Status",
                  driver.status ?? 'idle',
                  color: statusColor,
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(() => Get.to(() => AdminEditDriver(driver: driver)));
  }

  Widget _buildDriverMetric(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.black87,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
