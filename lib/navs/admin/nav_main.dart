import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/utils/screen_sizes.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart'; // REQUIRED: Add fl_chart to pubspec.yaml

// --- 1. MOCK MODELS & CONTROLLER (Replace with your actual Genesis logic) ---

class Vehicle {
  final String id;
  final String model;
  final String driverName;
  final String status; // 'Active', 'Maintenance', 'Idle'
  final String plateNumber;
  final double fuelLevel;

  Vehicle(
    this.id,
    this.model,
    this.driverName,
    this.status,
    this.plateNumber,
    this.fuelLevel,
  );
}

class DashboardStats {
  final int totalFleet;
  final int activeDrivers;
  final int maintenanceCount;
  final double totalRevenue;
  final List<double> weeklyRevenue; // For sparklines
  final List<Vehicle> vehicles;

  DashboardStats({
    required this.totalFleet,
    required this.activeDrivers,
    required this.maintenanceCount,
    required this.totalRevenue,
    required this.weeklyRevenue,
    required this.vehicles,
  });
}

// --- 2. MAIN DASHBOARD SCREEN ---

class AdminNavMain extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavMain({super.key, this.triggerKey});

  @override
  State<AdminNavMain> createState() => _AdminNavMainState();
}

class _AdminNavMainState extends State<AdminNavMain> {
  // Inject controller if not already in memory
  final _statsController = Get.find<StatsController>();

  // Colors
  final Color primaryColor = const Color(0xFF2A2D3E);
  final Color secondaryColor = const Color(0xFF212332);
  final Color accentColor = const Color(0xFF6C5DD3);
  final Color bgColor = const Color(0xFFF5F6FA); // Light mode background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(() {
        if (_statsController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C5DD3)),
          );
        }
        if (_statsController.errorState.value.isNotEmpty ||
            _statsController.stats.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 10),
                Text("Error: ${_statsController.errorState.value}"),
                TextButton(
                  onPressed: () => _statsController.fetchStats(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        return _buildDashboardContent(context, _statsController.stats.value!);
      }),
    );
  }

  Widget _buildDashboardContent(BuildContext context, MainStatsModel data) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildQuickStatsGrid(data),
            const SizedBox(height: 30),
            _buildAnalyticsSection(data),
            const SizedBox(height: 30),
            _buildRecentFleetActivity(data),
          ],
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    final isDeskop = MediaQuery.of(context).size.width > ScreenSizes.DESKTOP_W;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DrawerButton(
            onPressed: () => widget.triggerKey?.currentState?.openDrawer(),
          ),
        ).visibleIfNot(isDeskop),
        12.gapWidth,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Genesis",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // --- Top Grid ---
  Widget _buildQuickStatsGrid(MainStatsModel data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 700
            ? 2
            : 1;
        double aspectRatio = crossAxisCount == 4 ? 1.4 : 1.6;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: aspectRatio,
          children: [
            _buildSophisticatedCard(
              "Total Fleet",
              data.totalVehiclesInSystem.toString(),
              "+12% vs last month",
              Icons.directions_car_filled,
              const Color(0xFF6C5DD3), // Purple
              [3, 5, 4, 6, 5, 8, 7],
            ),
            _buildSophisticatedCard(
              "Active Drivers",
              data.totalDriversInSystem.toString(),
              "92% Utilization",
              Icons.person_pin_circle_rounded,
              const Color(0xFF33D69F), // Green
              [8, 8, 7, 9, 8, 9, 9],
            ),
            _buildSophisticatedCard(
              "Maintenance",
              data.totalMaintainanceCost.toString(),
              "4 Critical Repairs",
              Icons.build_circle_rounded,
              const Color(0xFFFF8F6B), // Orange
              [2, 3, 2, 4, 2, 1, 2],
            ),
            _buildSophisticatedCard(
              "Total Revenue",
              "\$${(34566 / 1000).toStringAsFixed(1)}k",
              "+8.4% Growth",
              Icons.monetization_on_rounded,
              const Color(0xFF4CA6EA), // Blue
              [2, 3, 566, 776, 234, 53, 6],
            ),
          ],
        );
      },
    );
  }

  // --- Analytics (Graph Section) ---
  Widget _buildAnalyticsSection(MainStatsModel data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive switch for graph layout
        bool isWide = constraints.maxWidth > 900;

        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Line Chart
            Expanded(
              flex: isWide ? 2 : 0,
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Operations & Expenses",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ).constrained(maxWidth: 120),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "This Year",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Expanded(child: _buildLineChart()),
                  ],
                ),
              ),
            ),
            if (isWide)
              const SizedBox(width: 24)
            else
              const SizedBox(height: 24),
            // Donut Chart
            Expanded(
              flex: isWide ? 1 : 0,
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fleet Health",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(child: _buildPieChart(data)),
                    const SizedBox(height: 20),
                    _buildPieLegend(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- List Section ---
  Widget _buildRecentFleetActivity(MainStatsModel data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Live Vehicle Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.vehicleDetails.length,
            separatorBuilder: (ctx, i) =>
                Divider(color: Colors.grey.withAlpha(40)),
            itemBuilder: (context, index) {
              final vehicle = data.vehicleDetails[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getStatusColor(vehicle.status).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.local_shipping_rounded,
                        color: _getStatusColor(vehicle.status),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.model,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${vehicle.model} • ${vehicle.driverName}",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildFuelIndicator(/*vehicle.fuelLevel*/ 34),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(vehicle.status).withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(vehicle.status).withAlpha(60),
                        ),
                      ),
                      child: Text(
                        vehicle.status,
                        style: TextStyle(
                          color: _getStatusColor(vehicle.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Sub-Widgets & Helpers ---

  Widget _buildSophisticatedCard(
    String title,
    String value,
    String subtext,
    IconData icon,
    Color color,
    List<double> chartData,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Icon(Icons.more_horiz, color: Colors.grey[400]),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2A2D3E),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Tiny sparkline
              SizedBox(
                width: 60,
                height: 30,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: color,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withAlpha(40),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1.5,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey[100]!, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'JAN';
                    break;
                  case 2:
                    text = 'MAR';
                    break;
                  case 4:
                    text = 'MAY';
                    break;
                  case 6:
                    text = 'JUL';
                    break;
                  case 8:
                    text = 'SEP';
                    break;
                  case 10:
                    text = 'NOV';
                    break;
                  default:
                    return Container();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}0k',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
              reservedSize: 32,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          // Expenses Line
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(2.6, 2),
              FlSpot(4.9, 5),
              FlSpot(6.8, 3.1),
              FlSpot(8, 4),
              FlSpot(9.5, 3),
              FlSpot(11, 4),
            ],
            isCurved: true,
            color: const Color(0xFF6C5DD3),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6C5DD3).withOpacity(0.15),
            ),
          ),
          // Revenue Line
          LineChartBarData(
            spots: const [
              FlSpot(0, 1.5),
              FlSpot(2.6, 1.8),
              FlSpot(4.9, 1.3),
              FlSpot(6.8, 2.5),
              FlSpot(8, 2.2),
              FlSpot(9.5, 3.8),
              FlSpot(11, 3.2),
            ],
            isCurved: true,
            color: const Color(0xFF33D69F),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(MainStatsModel data) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: const Color(0xFF33D69F),
            value: 65,
            title: '65%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFFFF8F6B),
            value: 20,
            title: '20%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFF4CA6EA),
            value: 15,
            title: '15%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieLegend() {
    return Column(
      children: [
        _legendItem(const Color(0xFF33D69F), "Active"),
        const SizedBox(height: 8),
        _legendItem(const Color(0xFFFF8F6B), "Maintenance"),
        const SizedBox(height: 8),
        _legendItem(const Color(0xFF4CA6EA), "Idle / Garage"),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFuelIndicator(double level) {
    return Column(
      children: [
        const Icon(
          Icons.local_gas_station_rounded,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 40,
          child: LinearProgressIndicator(
            value: level,
            backgroundColor: Colors.grey[200],
            color: level < 0.3 ? Colors.red : Colors.blue,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF33D69F);
      case 'maintenance':
        return const Color(0xFFFF8F6B);
      default:
        return Colors.grey;
    }
  }
}
