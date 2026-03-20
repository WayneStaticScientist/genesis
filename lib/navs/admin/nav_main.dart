import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/utils/screen_sizes.dart';
import 'package:genesis/utils/theme.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart'; // REQUIRED: Add fl_chart to pubspec.yaml

// --- 1. MOCK MODELS & CONTROLLER (Replace with your actual Genesis logic) ---

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
  // Light mode background
  initState() {
    super.initState();
    _statsController.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildDashboardContent(context));
  }

  Widget _buildDashboardContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(), _buildMainSection()],
        ),
      ),
    );
  }

  Widget _buildMainSection() {
    return Obx(() {
      if (_statsController.isLoading.value) {
        return [CircularProgressIndicator(color: Color(0xFF6C5DD3))]
            .row(mainAxisAlignment: MainAxisAlignment.center)
            .padding(EdgeInsets.only(top: 40));
      }
      if (_statsController.errorState.value.isNotEmpty ||
          _statsController.stats.value == null) {
        return Column(
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
        ).sizedBox(width: double.infinity).padding(EdgeInsets.only(top: 40));
      }
      return [
        const SizedBox(height: 30),
        _buildQuickStatsGrid(_statsController.stats.value!),
        const SizedBox(height: 30),
        _buildAnalyticsSection(_statsController.stats.value!),
      ].column(mainAxisSize: MainAxisSize.min);
    });
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
            color: GTheme.cardColor(context),
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
            color: Get.isDarkMode ? Colors.white : Colors.black87,
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
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GTheme.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: Get.isDarkMode ? Colors.white : Colors.black87,
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
              "Total Vehicles",
              Icons.directions_car_filled,
              const Color(0xFF6C5DD3), // Purple
              _statsController.sevenDaysTotals
                  .map((e) => e.newVehicles.toDouble())
                  .toList(),
            ),
            _buildSophisticatedCard(
              "Active Drivers",
              data.totalDriversInSystem.toString(),
              "Total Drivers",
              Icons.person_pin_circle_rounded,
              const Color(0xFF33D69F), // Green
              _statsController.sevenDaysTotals
                  .map((e) => e.newDrivers.toDouble())
                  .toList(),
            ),
            _buildSophisticatedCard(
              "Maintenance",
              NumberUtils.formatCurrency(data.totalMaintainanceCost),
              "Maintenance",
              Icons.build_circle_rounded,
              const Color(0xFFFF8F6B), // Orange
              _statsController.sevenDaysTotals
                  .map((e) => e.maintenanceCost.toDouble())
                  .toList(),
            ),
            _buildSophisticatedCard(
              "Total Revenue",
              NumberUtils.formatCurrency(data.totalRevenue),
              "Revenue",
              Icons.monetization_on_rounded,
              const Color(0xFF4CA6EA), // Blue
              _statsController.sevenDaysTotals
                  .map((e) => e.revenue.toDouble())
                  .toList(),
            ),
            _buildSophisticatedCard(
              "Total Expenses",
              NumberUtils.formatCurrency(
                NumberUtils.getStatsTotalExpenses(data),
              ),
              "Expenses",
              Icons.monetization_on_rounded,
              Colors.red,
              null,
              fillColor: Colors.red,
            ),
            _buildSophisticatedCard(
              "Gross Profit",
              NumberUtils.formatCurrency(
                data.totalRevenue -
                    NumberUtils.getStatsTotalExpenses(data) -
                    data.totalMaintainanceCost,
              ),
              "Gross Profit",
              Icons.monetization_on_rounded,
              Colors.green,
              null,
              fillColor: Colors.green,
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
                  color: GTheme.cardColor(context),
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
                            color: GTheme.cardColor(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "This Week",
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
                  color: GTheme.cardColor(context),
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

  // --- Sub-Widgets & Helpers ---

  Widget _buildSophisticatedCard(
    String title,
    String value,
    String subtext,
    IconData icon,
    Color color,
    List<double>? chartData, {
    Color? fillColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
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
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: fillColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 12,
                  color: fillColor ?? Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Tiny sparkline
              if (chartData != null)
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
                return SideTitleWidget(
                  meta: meta,
                  child: Text("${value.toInt()}", style: style),
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
                  NumberUtils.formatCurrency(value), // Scale back for labels
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
              reservedSize: 32,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 7,
        minY: 0,
        lineBarsData: [
          // Expenses Line
          LineChartBarData(
            spots: _statsController.sevenDaysTotals
                .map(
                  (e) => FlSpot(
                    _statsController.sevenDaysTotals.indexOf(e).toDouble(),
                    e.maintenanceCost.toDouble() / 1000, // Scale for demo
                  ),
                )
                .toList(),
            isCurved: true,
            color: const Color(0xFF6C5DD3),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6C5DD3).withAlpha(30),
            ),
          ),
          // Revenue Line
          LineChartBarData(
            spots: _statsController.sevenDaysTotals
                .map(
                  (e) => FlSpot(
                    _statsController.sevenDaysTotals.indexOf(e).toDouble(),
                    e.revenue.toDouble() / 1000, // Scale for demo
                  ),
                )
                .toList(),
            isCurved: true,
            color: const Color(0xFF4CA6EA),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4CA6EA).withAlpha(30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(MainStatsModel data) {
    final total =
        data.activeVehicles + data.inServiceVehicles + data.idleVehicles;
    if (total == 0) {
      return Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              "No fleet data available",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: const Color(0xFF33D69F),
            value:
                ((_statsController.stats.value?.activeVehicles.toDouble() ??
                        0) /
                    total) *
                100,
            title:
                _statsController.stats.value?.activeVehicles.toString() ?? "0",
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFFFF8F6B),
            value:
                ((_statsController.stats.value?.inServiceVehicles.toDouble() ??
                        0) /
                    total) *
                100,
            title:
                _statsController.stats.value?.inServiceVehicles.toString() ??
                "0",
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFF4CA6EA),
            value:
                ((_statsController.stats.value?.idleVehicles.toDouble() ?? 0) /
                    total) *
                100,
            title: _statsController.stats.value?.idleVehicles.toString() ?? "0",
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
        _legendItem(
          const Color(0xFF33D69F),
          "Active ${"(${_statsController.stats.value?.activeVehicles.toInt() ?? 0})"}",
        ),
        const SizedBox(height: 8),
        _legendItem(
          const Color(0xFFFF8F6B),
          "Maintenance ${"(${_statsController.stats.value?.inServiceVehicles.toInt() ?? 0})"}",
        ),
        const SizedBox(height: 8),
        _legendItem(
          const Color(0xFF4CA6EA),
          "Idle / Garage ${"(${_statsController.stats.value?.idleVehicles.toInt() ?? 0})"}",
        ),
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
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
