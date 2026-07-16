import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/screen_sizes.dart';
import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/utils/pdf_marker/genesis_printer.dart';
import 'package:genesis/controllers/notifications_controller.dart';
import 'package:genesis/screens/notifications/notification_list.dart';
import 'package:genesis/navs/admin/nav_maintanance.dart';

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
      child: RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              16.gapHeight,
              _buildFilters(),
              _buildMainSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return _buildDateSelector();
  }

  Widget _buildPeriodSelector() {
    final periods = [
      {"label": "Daily", "value": "Daily"},
      {"label": "Monthly", "value": "Monthly"},
      {"label": "Yearly", "value": "Yearly"},
    ];

    return Obx(
      () => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: GTheme.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withAlpha(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: periods.map((p) {
            final periodValue = p["value"]!;
            final periodLabel = p["label"]!;
            final isSelected =
                _statsController.selectedPeriod.value == periodValue;
            return GestureDetector(
              onTap: () {
                _statsController.selectedPeriod.value = periodValue;
                _statsController.fetchGraphStats(selectedDateRange);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  periodLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[500],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final hasRange = selectedDateRange != null;
    final label = hasRange
        ? '${selectedDateRange!.start.day}/${selectedDateRange!.start.month}/${selectedDateRange!.start.year} — ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}/${selectedDateRange!.end.year}'
        : 'All Time';

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: GTheme.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withAlpha(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: hasRange ? accentColor : Colors.grey[500],
              ),
            ),
            const SizedBox(width: 8),
            if (hasRange)
              GestureDetector(
                onTap: () {
                  setState(() => selectedDateRange = null);
                  refresh();
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.grey[400],
              ),
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
      // Force Obx to track monthly sparkline data changes so mini sparklines rebuild instantly
      final _ = _statsController.monthlySparklineData.length;
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

  // --- Expense Breakdown Section ---
  Widget _buildExpenseBreakdownSection(MainStatsModel data) {
    final totalExp = NumberUtils.getStatsTotalExpenses(data);
    final expenses = [
      _ExpenseItem(
        "Fuel",
        data.fuelExpense,
        Icons.local_gas_station_rounded,
        const Color(0xFFFF9F43),
      ),
      _ExpenseItem(
        "Tollgate",
        data.tolgateExpense,
        Icons.toll_rounded,
        const Color(0xFF4CA6EA),
      ),
      _ExpenseItem(
        "TruckStop",
        data.truckStopExpense,
        Icons.handyman_rounded,
        const Color(0xFFFF6B6B),
      ),
      _ExpenseItem(
        "Food",
        data.foodExpense,
        Icons.restaurant_rounded,
        const Color(0xFF33D69F),
      ),
      _ExpenseItem(
        "Fines",
        data.finesExpense,
        Icons.gavel_rounded,
        const Color(0xFF6C5DD3),
      ),
      _ExpenseItem(
        "Extras",
        data.extrasExpense,
        Icons.more_horiz_rounded,
        const Color(0xFF78909C),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Expense Breakdown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  NumberUtils.formatCurrency(totalExp),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...expenses.map((e) => _buildExpenseRow(e, totalExp)),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(_ExpenseItem item, num totalExp) {
    final pct = totalExp > 0 ? (item.amount / totalExp) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                      ),
                    ),
                    Text(
                      NumberUtils.formatCurrency(item.amount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: item.color.withAlpha(25),
                    valueColor: AlwaysStoppedAnimation(item.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "${(pct * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    final isDeskop = MediaQuery.of(context).size.width > ScreenSizes.DESKTOP_W;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning ☀️'
        : (hour < 17 ? 'Good Afternoon 🌤️' : 'Good Evening 🌙');
    final primaryColor = Theme.of(context).colorScheme.primary;
    final now = DateTime.now();
    final dateStr = GenesisDate.formatNormalDate(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withBlue((primaryColor.blue + 60).clamp(0, 255)),
            const Color(0xFF6C5DD3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(100),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Drawer button — mobile only
              GestureDetector(
                onTap: () => widget.triggerKey?.currentState?.openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ).visibleIfNot(isDeskop),
              if (!isDeskop) const SizedBox(width: 12),
              // Date chip — flex so it shrinks on small screens
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white70,
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          dateStr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Print button
              Obx(
                () => GestureDetector(
                  onTap: () async {
                    if (_isPrinting || _statsController.stats.value == null)
                      return;
                    setState(() => _isPrinting = true);
                    await GenisisPrinter.printMainStatsReports(
                      _statsController.stats.value!,
                    );
                    setState(() => _isPrinting = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    child: _isPrinting.lord(
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const Icon(
                        Icons.print_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).visibleIf(_statsController.stats.value != null),
              ),
              const SizedBox(width: 8),
              // Notifications
              GestureDetector(
                onTap: () => Get.to(() => NotificationListScreen()),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: Obx(
                    () => (_notificationsController.notificationSize.value > 0)
                        .lord(
                          Badge.count(
                            count:
                                _notificationsController.notificationSize.value,
                            child: const Icon(
                              Icons.notifications_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.notifications_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Fleet Dashboard",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Monitor operations, performance & finances",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // --- Top Grid ---
  Widget _buildQuickStatsGrid(MainStatsModel data) {
    final totalExpenses = NumberUtils.getStatsTotalExpenses(data);
    final netProfit =
        data.totalRevenue - totalExpenses - data.grossPayroll - data.totalMaintainanceCost;

    String formatDuration(int ms) {
      if (ms <= 0) return "0h 0m";
      final duration = Duration(milliseconds: ms);
      if (duration.inDays > 0) {
        return "${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m";
      }
      if (duration.inHours > 0) {
        return "${duration.inHours}h ${duration.inMinutes % 60}m";
      }
      return "${duration.inMinutes}m";
    }

    final kpis = [
      _KpiTile(
        "Revenue",
        NumberUtils.formatCurrency(data.totalRevenue),
        Icons.trending_up_rounded,
        const Color(0xFF33D69F),
        _statsController.monthlySparklineData
            .map((e) => e.revenue.toDouble())
            .toList(),
      ),
      _KpiTile(
        "Expenses",
        NumberUtils.formatCurrency(totalExpenses),
        Icons.trending_down_rounded,
        const Color(0xFFFF6B6B),
        _statsController.monthlySparklineData
            .map((e) => e.maintenanceCost.toDouble())
            .toList(),
      ),
      _KpiTile(
        "Net Profit",
        NumberUtils.formatCurrency(netProfit),
        Icons.account_balance_wallet_rounded,
        const Color(0xFF6C5DD3),
        [],
      ),
      _KpiTile(
        "Turnaround Time",
        formatDuration(data.totalTurnaroundTimeMs),
        Icons.timer_rounded,
        Colors.amber,
        [],
      ),
      _KpiTile(
        "Maintenance Cost",
        NumberUtils.formatCurrency(data.totalMaintainanceCost),
        Icons.handyman_rounded,
        Colors.blueGrey,
        [],
      ),
      _KpiTile(
        "Total Payroll",
        NumberUtils.formatCurrency(data.grossPayroll),
        Icons.payments_rounded,
        const Color(0xFFE84393),
        [],
      ),
      _KpiTile(
        "Payrolls Processed",
        (data.payrollCount ?? 0).toString(),
        Icons.receipt_long_rounded,
        const Color(0xFFFD7272),
        [],
      ),
      _KpiTile(
        "Total Fleet",
        data.totalVehiclesInSystem.toString(),
        Icons.local_shipping_rounded,
        const Color(0xFF4CA6EA),
        _statsController.monthlySparklineData
            .map((e) => e.newVehicles.toDouble())
            .toList(),
      ),
      _KpiTile(
        "Service Reminders",
        (data.totalMaintenanceCount).toString(),
        Icons.build_rounded,
        const Color(0xFF8395A7),
        [],
      ),
      _KpiTile(
        "Services Due",
        (data.servicesDue ?? 0).toString(),
        Icons.warning_amber_rounded,
        Colors.red,
        [],
        onTap: () =>
            Get.to(() => const AdminNavMaintenance(initialStatus: "Critical")),
      ),
      _KpiTile(
        "Services Almost Due",
        (data.servicesAlmostDue ?? 0).toString(),
        Icons.notification_important_rounded,
        Colors.orange,
        [],
        onTap: () =>
            Get.to(() => const AdminNavMaintenance(initialStatus: "Due Soon")),
      ),
      _KpiTile(
        "Drivers",
        data.totalDriversInSystem.toString(),
        Icons.people_alt_rounded,
        const Color(0xFFFFB347),
        _statsController.monthlySparklineData
            .map((e) => e.newDrivers.toDouble())
            .toList(),
      ),
      _KpiTile(
        "Finalized Trips",
        (data.tripsFinalized ?? 0).toString(),
        Icons.check_circle_outline_rounded,
        const Color(0xFF1DD1A1),
        [],
      ),
      _KpiTile(
        "Active Trips",
        (data.tripsActive ?? 0).toString(),
        Icons.play_circle_outline_rounded,
        const Color(0xFF00D2AA),
        [],
      ),
      _KpiTile(
        "Pending Trips",
        (data.tripsPending ?? 0).toString(),
        Icons.hourglass_empty_rounded,
        const Color(0xFFFECA57),
        [],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900 ? 3 : 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: kpis.map((k) {
            final tileWidth =
                (constraints.maxWidth - (crossCount - 1) * 16) / crossCount;
            return SizedBox(width: tileWidth, child: _buildKpiTile(k));
          }).toList(),
        );
      },
    );
  }

  Widget _buildKpiTile(_KpiTile tile) {
    return GestureDetector(
      onTap: tile.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GTheme.cardColor(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: tile.color.withAlpha(40), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: tile.color.withAlpha(18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tile.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(tile.icon, color: tile.color, size: 20),
                ),
                if (tile.chartData.isNotEmpty)
                  SizedBox(
                    width: 60,
                    height: 32,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: const LineTouchData(enabled: false),
                        minX: 0,
                        maxX: tile.chartData.length <= 1
                            ? 1
                            : (tile.chartData.length - 1).toDouble(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: tile.chartData
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: tile.color,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: tile.color.withAlpha(35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tile.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              tile.label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 16,
                      spacing: 16,
                      children: [
                        const Text(
                          "Operations and Expenses",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildGraphLegend(),
                        _buildPeriodSelector(),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Obx(() {
                        if (_statsController.isGraphLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6C5DD3),
                            ),
                          );
                        }
                        if (_statsController.graphData.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.show_chart_rounded,
                                  size: 48,
                                  color: Colors.grey.withAlpha(50),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No graph data available",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return _buildLineChart();
                      }),
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Fleet Health",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildPieChart(data),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${data.totalVehiclesInSystem.toInt()}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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

  Widget _buildLineChart() {
    double maxY = 0;
    for (var data in _statsController.graphData) {
      if (data.revenue > maxY) maxY = data.revenue.toDouble();
      if (data.maintenanceCost > maxY) maxY = data.maintenanceCost.toDouble();
    }
    if (maxY == 0) maxY = 100; // Default headroom if no data

    double yInterval = maxY / 4;
    if (yInterval == 0) yInterval = 25;

    String formatAxisValue(double value) {
      if (value == 0) return '\$0';
      if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
      if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}k';
      return '\$${value.toStringAsFixed(0)}';
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                GTheme.cardColor(context).withAlpha(220),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: touchedSpot.bar.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                return LineTooltipItem(
                  NumberUtils.formatCurrency(touchedSpot.y),
                  textStyle,
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withAlpha(20),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
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
                final index = value.toInt();
                if (index < 0 || index >= _statsController.graphData.length) {
                  return const Text("");
                }
                final data = _statsController.graphData[index];
                const style = TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );

                String label = "${data.date.day}";
                if (_statsController.selectedPeriod.value == "Monthly") {
                  label = GenesisDate.getShortMonthName(data.date.month)[0];
                } else if (_statsController.selectedPeriod.value == "Yearly") {
                  label = "${data.date.year}";
                } else if (_statsController.selectedPeriod.value == "Daily") {
                  if (data.date.day % 5 != 0) return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(label, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                return Text(
                  formatAxisValue(value),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
              reservedSize: 45,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withAlpha(50), width: 2),
            left: BorderSide.none,
            right: BorderSide.none,
            top: BorderSide.none,
          ),
        ),
        minX: 0,
        maxX: _statsController.graphData.isEmpty
            ? 1
            : (_statsController.graphData.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.1, // 10% headroom above the highest point
        lineBarsData: [
          LineChartBarData(
            spots: _statsController.graphData
                .asMap()
                .entries
                .map(
                  (e) => FlSpot(
                    e.key.toDouble(),
                    e.value.maintenanceCost.toDouble(),
                  ),
                )
                .toList(),
            isCurved: true,
            preventCurveOverShooting: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE53935), // Red for expenses
                const Color(0xFFEF5350),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEF5350).withAlpha(80),
                  const Color(0xFFEF5350).withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: _statsController.graphData
                .asMap()
                .entries
                .map(
                  (e) => FlSpot(e.key.toDouble(), e.value.revenue.toDouble()),
                )
                .toList(),
            isCurved: true,
            preventCurveOverShooting: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8E24AA), // Purple for revenue
                const Color(0xFFBA68C8),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFBA68C8).withAlpha(80),
                  const Color(0xFFBA68C8).withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(
              const Color(0xFF33D69F),
              "Active (${stats?.activeVehicles.toInt() ?? 0})",
            ),
            const SizedBox(width: 16),
            _legendItem(
              const Color(0xFFFF8F6B),
              "Maint. (${stats?.inServiceVehicles.toInt() ?? 0})",
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(
              const Color(0xFF4CA6EA),
              "Idle/Garage (${stats?.idleVehicles.toInt() ?? 0})",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGraphLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendItem(const Color(0xFFBA68C8), "Revenue"),
        const SizedBox(width: 16),
        _legendItem(const Color(0xFFEF5350), "Expenses"),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

  Future<void> refresh() async {
    await _statsController.fetchStats(selectedDateRange);
  }
}

class _ExpenseItem {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  _ExpenseItem(this.title, this.amount, this.icon, this.color);
}

class _KpiTile {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final List<double> chartData;
  final void Function()? onTap;
  _KpiTile(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.chartData, {
    this.onTap,
  });
}
