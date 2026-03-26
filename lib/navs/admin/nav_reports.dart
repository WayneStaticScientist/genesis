import 'package:genesis/widgets/actions/default_dropdown.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/screens/stats/driver_stats.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/screens/stats/vehicle_stats.dart';
import 'package:genesis/controllers/vehicle_controller.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/utils/pdf_marker/genesis_printer.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:genesis/widgets/layouts/modern_date_range_2.dart';

// --- MAIN SCREEN ---

class AdminNavReports extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavReports({super.key, required this.triggerKey});

  @override
  State<AdminNavReports> createState() => _AdminNavReportsState();
}

class _AdminNavReportsState extends State<AdminNavReports> {
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isPrinting = false;
  String _plan = 'monthly';
  final _navReports = Get.find<StatsController>();
  final _vehicleController = Get.find<VehicleControler>();
  @override
  void initState() {
    super.initState();
    filter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          Obx(() {
            if (_navReports.fetchingTripStatus.value) {
              return SliverFillRemaining(child: MaterialLoader().center());
            }
            if (_navReports.fetchingTripStatsError.value.isNotEmpty ||
                _navReports.tripsStatModel.value == null) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Error: ${_navReports.fetchingTripStatsError.value}",
                      ),
                      TextButton(onPressed: filter, child: const Text("Retry")),
                    ],
                  ),
                ),
              );
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildModernKPIs(),
                    const SizedBox(height: 32),
                    _buildChartSurface(),
                    const SizedBox(height: 32),
                    _buildActivitySection(),
                    const SizedBox(height: 32),
                    _buildDriverActivitySection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 1. Modern Sliver Header with Glass Range Selector ---
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      leading: DrawerButton(
        color: Colors.white,
        onPressed: () {
          widget.triggerKey?.currentState?.openDrawer();
        },
      ).visibleIf(widget.triggerKey != null),
      backgroundColor: GTheme.primary(context),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [GTheme.primary(context), Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Performance Insights",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDateRangeSelector(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: _isPrinting.lord(WhiteLoader(), Icon(Icons.print)),
            onPressed: () async {
              if (_isPrinting) return;
              setState(() {
                _isPrinting = true;
              });
              await GenisisPrinter.printFinancialReports(
                _navReports.tripsStatModel.value!,
              );
              setState(() {
                _isPrinting = false;
              });
            },
          ).visibleIf(_navReports.tripsStatModel.value != null),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ModernDateRange2(
          selectedDateRange: selectedDateRange,
          onSelect: _openTimeSelectRange,
        ),
      ).expanded1,
    ].row(mainAxisAlignment: MainAxisAlignment.center);
  }

  // --- 2. Integrated KPI Row (Non-Card Style) ---
  Widget _buildModernKPIs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMinimalStat(
            "Revenue",
            NumberUtils.formatCurrency(
              _navReports.tripsStatModel.value!.summary.totalRevenue,
            ),
            Theme.of(context).colorScheme.tertiary,
          ),
          _buildVerticalDivider(),
          _buildMinimalStat(
            "Trips",
            _navReports.tripsStatModel.value!.summary.totalTrips.toString(),
            GTheme.primary(context),
          ),
          _buildVerticalDivider(),
          _buildMinimalStat(
            "Margin",
            "${_navReports.tripsStatModel.value!.summary.margin.toStringAsFixed(0)}%",
            Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 4),
            Icon(Icons.north_east_rounded, color: color, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withAlpha(30));
  }

  // --- 3. Unified Chart Surface ---
  Widget _buildChartSurface() {
    final firstDay = selectedDateRange.end.subtract(
      Duration(days: getDays(_plan)),
    );
    return Container(
      height: 430,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultDropdown(
            label: "View Type",
            value: _plan,
            items: ['monthly', 'weekly', 'daily'],
            onChanged: (String? value) {
              setState(() {
                _plan = value!;
              });
              filter();
            },
          ),
          14.gapHeight,
          Text(
            "Revenue  ${firstDay.day} ${GenesisDate.getMonthName(firstDay.month)} - ${selectedDateRange.end.day} ${GenesisDate.getMonthName(selectedDateRange.end.month)}",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child:
                  LineChart(
                    LineChartData(
                      clipData: const FlClipData.none(),
                      maxX:
                          (_navReports
                                      .tripsStatModel
                                      .value!
                                      .monthlyBreakdown
                                      .length -
                                  1)
                              .toDouble() *
                          1.3,
                      minX: 0,
                      minY: 0,
                      maxY:
                          _navReports
                              .tripsStatModel
                              .value!
                              .monthlyBreakdown
                              .isEmpty
                          ? 10.0
                          : _navReports.tripsStatModel.value!.monthlyBreakdown
                                    .map((e) => e.revenue)
                                    .reduce((a, b) => a > b ? a : b) *
                                2.15,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40, // Space for the labels
                            interval:
                                1, // Show a label every 2 units on the X axis
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 ||
                                  index >=
                                      _navReports
                                          .tripsStatModel
                                          .value!
                                          .monthlyBreakdown
                                          .length) {
                                return const SizedBox.shrink(); // Return nothing if out of bounds
                              }
                              final data = _navReports
                                  .tripsStatModel
                                  .value!
                                  .monthlyBreakdown[index];
                              return SideTitleWidget(
                                space: 8.0,
                                meta: meta,
                                child: Transform.rotate(
                                  angle:
                                      -45 *
                                      0.0174533, // Converts -45 degrees to radians
                                  child: Text(
                                    _plan == 'monthly'
                                        ? "${GenesisDate.getShortMonthName(data.date.month)}"
                                        : "${data.date.day}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ), // Hide right
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ), // 'Hide top'
                        leftTitles: AxisTitles(
                          axisNameSize: 10,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) => SideTitleWidget(
                              child: NumberUtils.formatNumber(
                                value,
                              ).text(style: TextStyle(fontSize: 10)),
                              meta: meta,
                            ),
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _navReports
                              .tripsStatModel
                              .value!
                              .monthlyBreakdown
                              .asMap()
                              .entries
                              .map(
                                (entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.revenue,
                                ),
                              )
                              .toList(),
                          isCurved: true,
                          color: GTheme.primary(context),
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                GTheme.primary(context).withAlpha(70),
                                GTheme.primary(context).withAlpha(0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).sizedBox(
                    height: 340,
                    width:
                        _navReports
                                .tripsStatModel
                                .value!
                                .monthlyBreakdown
                                .length *
                            20.0 +
                        50,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Activity List (Limited to 5) ---
  Widget _buildActivitySection() {
    if (_navReports.tripsStatModel.value!.vehicles.isEmpty) {
      return [
        "No Settlements found".text(),
      ].row(mainAxisAlignment: MainAxisAlignment.center);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Vehicle Settlements",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: GTheme.surface(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _navReports.tripsStatModel.value!.vehicles.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withAlpha(50),
              indent: 70,
            ),
            itemBuilder: (context, index) {
              final trip = _navReports.tripsStatModel.value!.vehicles[index];
              return ListTile(
                onTap: () async {
                  if (trip.id.isEmpty) {
                    return Toaster.showErrorTop(
                      "Vehicle",
                      'Vehicle not found / May have been deleted',
                    );
                  }
                  if (await _vehicleController.fetchVehicle(id: trip.id)) {
                    Get.to(
                      () => VehicleDetailStatsScreen(
                        vehicle: _vehicleController.selectedVehicle.value!,
                      ),
                    );
                  }
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: GTheme.primary(context),
                    size: 20,
                  ),
                ),
                title: Text(
                  trip.model,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  trip.driverName,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Obx(
                  () => _vehicleController.vehicleInSearch.value == trip.id
                      ? MaterialLoader()
                      : [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberUtils.formatCurrency(trip.totalRevenue),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                "Settled",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          12.gapWidth,
                          Icon(Icons.chevron_right, color: Colors.blue),
                        ].row().constrained(minWidth: 30, maxWidth: 100),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDriverActivitySection() {
    if (_navReports.tripsStatModel.value!.drivers.isEmpty) {
      return [
        "No Driver Settlements found".text(),
      ].row(mainAxisAlignment: MainAxisAlignment.center);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Driver Settlements",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: GTheme.surface(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _navReports.tripsStatModel.value!.drivers.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withAlpha(50),
              indent: 70,
            ),
            itemBuilder: (context, index) {
              final driver = _navReports.tripsStatModel.value!.drivers[index];
              return ListTile(
                onTap: () async {
                  if (driver.driverId.isEmpty) {
                    return Toaster.showErrorTop(
                      "Vehicle",
                      'Vehicle not found / May have been deleted',
                    );
                  }
                  Get.to(() => DriverStatsScreen(userId: driver.driverId));
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: GTheme.primary(context),
                    size: 20,
                  ),
                ),
                title: Text(
                  driver.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  driver.email,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberUtils.formatCurrency(driver.totalRevenue),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        "Settled",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  12.gapWidth,
                  Icon(Icons.chevron_right, color: Colors.blue),
                ].row().constrained(minWidth: 30, maxWidth: 100),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openTimeSelectRange() async {
    final dateRange = await showDateRangePicker(
      initialDateRange: selectedDateRange,
      context: context,
      saveText: "Filter",
      cancelText: "close",
      currentDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (dateRange == null) return;
    setState(() {
      selectedDateRange = dateRange;
    });
    filter();
  }

  void filter() {
    _navReports.fetchTripStats(selectedDateRange, _plan);
  }

  int getDays(String plan) {
    if (plan == 'monthly') return 365;
    if (plan == 'weekly') return 7;
    return [
      31,
      selectedDateRange.end.year % 4 == 0 ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ][selectedDateRange.end.month - 1];
  }
}
