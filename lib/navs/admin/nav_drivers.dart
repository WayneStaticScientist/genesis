import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/screens/pilots/drivers_add.dart';
import 'package:genesis/widgets/layouts/driver_card.dart';
import 'package:genesis/widgets/layouts/quick_stats.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bx.dart';

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
              child: Iconify(Bx.group, color: Colors.white.withAlpha(30)),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Get.to(() => AdminAddDriver()),
              icon: Icon(Icons.add),
            ),
          ],
        ),

        // === QUICK STATS BAR ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GQuickStats(label: "Active", value: "12", color: Colors.green),
                GQuickStats(label: "Resting", value: "05", color: Colors.blue),
                GQuickStats(
                  label: "Top Rated",
                  value: "08",
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),

        // === DRIVERS LIST ===
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => GDriverCard(driver: drivers[index]),
              childCount: drivers.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
  }
}
