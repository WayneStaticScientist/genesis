import 'package:exui/exui.dart';
import 'package:flutter/material.dart';

class AdminNavDrivers extends StatefulWidget {
  const AdminNavDrivers({super.key});

  @override
  State<AdminNavDrivers> createState() => _AdminNavDriversState();
}

class _AdminNavDriversState extends State<AdminNavDrivers> {
  // Mock Data for the "Wow" factor
  final List<Map<String, dynamic>> drivers = [
    {
      "name": "Marcus Wright",
      "rating": 4.9,
      "status": "On Trip",
      "trips": 1240,
      "safety": 98,
      "experience": "5 Years",
      "avatar": "MW",
      "color": Colors.indigo,
    },
    {
      "name": "Elena Rodriguez",
      "rating": 4.7,
      "status": "Available",
      "trips": 850,
      "safety": 94,
      "experience": "3 Years",
      "avatar": "ER",
      "color": Colors.pink,
    },
    {
      "name": "Samuel L. Jackson",
      "rating": 4.5,
      "status": "Offline",
      "trips": 3200,
      "safety": 91,
      "experience": "12 Years",
      "avatar": "SJ",
      "color": Colors.amber,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // === LUXURY HEADER ===
        SliverAppBar(
          expandedHeight: 140,
          floating: true,
          pinned: true,
          backgroundColor: const Color(0xFF1A1D1E),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            title: const Text(
              "Fleet Pilots",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1D1E), Color(0xFF2C3E50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),

        // === QUICK STATS BAR ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildQuickStat("Active", "12", Colors.green),
                _buildQuickStat("Resting", "05", Colors.blue),
                _buildQuickStat("Top Rated", "08", Colors.orange),
              ],
            ),
          ),
        ),

        // === DRIVERS LIST ===
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildDriverCard(drivers[index]),
              childCount: drivers.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    bool isOnTrip = driver['status'] == 'On Trip';
    bool isAvailable = driver['status'] == 'Available';
    Color statusColor = isOnTrip
        ? Colors.blue
        : (isAvailable ? Colors.green : Colors.grey);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
                      backgroundColor: driver['color'].withOpacity(0.1),
                      child: Text(
                        driver['avatar'],
                        style: TextStyle(
                          color: driver['color'],
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
                        driver['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1D1E),
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
                            "${driver['rating']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            driver['experience'],
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
                    backgroundColor: Colors.blue.withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),

          // Performance Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
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
                  "${driver['trips']}",
                ),
                _buildDriverMetric(
                  Icons.shield,
                  "Safety",
                  "${driver['safety']}%",
                ),
                _buildDriverMetric(
                  Icons.timer_outlined,
                  "Status",
                  driver['status'],
                  color: statusColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
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
