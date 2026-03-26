import 'package:genesis/utils/pdf_marker/genesis_printer.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/utils/screen_sizes.dart';
import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/widgets/layouts/modern_date_range.dart';
import 'package:genesis/controllers/notifications_controller.dart';
import 'package:genesis/screens/notifications/notification_list.dart';

class AdminNavMain extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavMain({super.key, this.triggerKey});

  @override
  State<AdminNavMain> createState() => _AdminNavMainState();
}

class _AdminNavMainState extends State<AdminNavMain> {
  // Inject controller if not already in memory
  final _statsController = Get.find<StatsController>();
  final _notificationsController = Get.find<NotificationsController>();
  DateTimeRange? selectedDateRange;
  bool _isPrinting = false;
  // Colors
  final Color primaryColor = const Color(0xFF2A2D3E);
  final Color secondaryColor = const Color(0xFF212332);
  final Color accentColor = const Color(0xFF6C5DD3);

  @override
  void initState() {
    super.initState();
    refresh();
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
          children: [
            _buildHeader(),
            20.gapHeight,
            ModernDateRangeDisplay(
              startDate: selectedDateRange?.start,
              endDate: selectedDateRange?.end,
              onTap: _pickDate,
            ),
            _buildMainSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSection() {
    return Obx(() {
      if (_statsController.isLoading.value) {
        return [const CircularProgressIndicator(color: Color(0xFF6C5DD3))]
            .row(mainAxisAlignment: MainAxisAlignment.center)
            .padding(const EdgeInsets.only(top: 40));
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
                  onPressed: () => refresh(),
                  child: const Text("Retry"),
                ),
              ],
            )
            .sizedBox(width: double.infinity)
            .padding(const EdgeInsets.only(top: 40));
      }
      return [
        const SizedBox(height: 30),
        _buildQuickStatsGrid(_statsController.stats.value!),
        const SizedBox(height: 30),
        _buildExpenseBreakdownSection(
          _statsController.stats.value!,
        ), // NEW SECTION
        const SizedBox(height: 30),
        _buildAnalyticsSection(_statsController.stats.value!),
      ].column(mainAxisSize: MainAxisSize.min);
    });
  }

  // --- NEW: Detailed Expense Breakdown Section ---
  Widget _buildExpenseBreakdownSection(MainStatsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Expense Breakdown",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ).padding(const EdgeInsets.only(bottom: 16)),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1100
                ? 3
                : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildExpenseTile(
                  "Fuel",
                  data.fuelExpense,
                  Icons.local_gas_station_rounded,
                  Colors.orange,
                ),
                _buildExpenseTile(
                  "Tollgate",
                  data.tolgateExpense,
                  Icons.toll_rounded,
                  Colors.blue,
                ),
                _buildExpenseTile(
                  "TruckStop",
                  data.truckShopExpense,
                  Icons.handyman_rounded,
                  Colors.red,
                ),
                _buildExpenseTile(
                  "Food/Subsistence",
                  data.foodExpense,
                  Icons.restaurant_rounded,
                  Colors.green,
                ),
                _buildExpenseTile(
                  "Fines",
                  data.finesExpense,
                  Icons.gavel_rounded,
                  Colors.purple,
                ),
                _buildExpenseTile(
                  "Extras",
                  data.extrasExpense,
                  Icons.more_horiz_rounded,
                  Colors.blueGrey,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpenseTile(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  NumberUtils.formatCurrency(amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        const Column(
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
        const Spacer(),
        Obx(
          () => IconButton(
            icon: _isPrinting.lord(MaterialLoader(), const Icon(Icons.print)),
            onPressed: () async {
              if (_isPrinting) return;
              setState(() {
                _isPrinting = true;
              });
              await GenisisPrinter.printMainStatsReports(
                _statsController.stats.value!,
              );
              setState(() {
                _isPrinting = false;
              });
            },
          ).visibleIf(_statsController.stats.value != null),
        ),
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
          child: Obx(
            () => (_notificationsController.notificationSize.value > 0).lord(
              Badge.count(
                count: _notificationsController.notificationSize.value,
                child: Icon(
                  Icons.notifications_outlined,
                  color: Get.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Icon(
                Icons.notifications_outlined,
                color: Get.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ).onTap(() => Get.to(() => NotificationListScreen())),
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
        bool isWide = constraints.maxWidth > 900;

        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ).constrained(maxWidth: 180),
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
              if (chartData != null)
                SizedBox(
                  width: 60,
                  height: 30,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
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
                          dotData: const FlDotData(show: false),
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
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
                  NumberUtils.formatCurrency(value * 1000), // Scale back
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
              reservedSize: 45,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: _statsController.sevenDaysTotals
                .asMap()
                .entries
                .map(
                  (e) => FlSpot(
                    e.key.toDouble(),
                    e.value.maintenanceCost.toDouble() / 1000,
                  ),
                )
                .toList(),
            isCurved: true,
            color: const Color(0xFF6C5DD3),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6C5DD3).withAlpha(30),
            ),
          ),
          LineChartBarData(
            spots: _statsController.sevenDaysTotals
                .asMap()
                .entries
                .map(
                  (e) => FlSpot(
                    e.key.toDouble(),
                    e.value.revenue.toDouble() / 1000,
                  ),
                )
                .toList(),
            isCurved: true,
            color: const Color(0xFF4CA6EA),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
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
      return SizedBox(
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
            value: (data.activeVehicles / total) * 100,
            title: data.activeVehicles.toInt().toString(),
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFFFF8F6B),
            value: (data.inServiceVehicles / total) * 100,
            title: data.inServiceVehicles.toInt().toString(),
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFF4CA6EA),
            value: (data.idleVehicles / total) * 100,
            title: data.idleVehicles.toInt().toString(),
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
    final stats = _statsController.stats.value;
    return Column(
      children: [
        _legendItem(
          const Color(0xFF33D69F),
          "Active (${stats?.activeVehicles.toInt() ?? 0})",
        ),
        const SizedBox(height: 8),
        _legendItem(
          const Color(0xFFFF8F6B),
          "Maintenance (${stats?.inServiceVehicles.toInt() ?? 0})",
        ),
        const SizedBox(height: 8),
        _legendItem(
          const Color(0xFF4CA6EA),
          "Idle / Garage (${stats?.idleVehicles.toInt() ?? 0})",
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

  void _pickDate() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      refresh();
    }
  }

  void refresh() {
    _statsController.fetchStats(selectedDateRange);
  }
}
