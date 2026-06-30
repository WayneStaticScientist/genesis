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
import 'package:google_fonts/google_fonts.dart';

class AdminNavMonthlyReports extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavMonthlyReports({super.key, required this.triggerKey});
  @override
  State<AdminNavMonthlyReports> createState() => _AdminNavMonthlyReportsState();
}

class _AdminNavMonthlyReportsState extends State<AdminNavMonthlyReports> {
  bool _isPrinting = false;
  final _c = Get.find<StatsController>();
  final _vc = Get.find<VehicleControler>();

  @override
  void initState() {
    super.initState();
    // Default to current month when opened
    _c.selectedMonth.value = DateTime.now();
    _c.refreshMonthlyReports();
  }

  void _previousMonth() {
    final current = _c.selectedMonth.value;
    _c.selectedMonth.value = DateTime(current.year, current.month - 1, 1);
    _c.refreshMonthlyReports();
  }

  void _nextMonth() {
    final current = _c.selectedMonth.value;
    final next = DateTime(current.year, current.month + 1, 1);
    if (next.isBefore(DateTime.now()) || (next.year == DateTime.now().year && next.month == DateTime.now().month)) {
      _c.selectedMonth.value = next;
      _c.refreshMonthlyReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(primary),
          Obx(() {
            final loading = _c.fetchingTripStatus.value || _c.isLoading.value;
            if (loading) return SliverFillRemaining(child: MaterialLoader().center());
            final stat = _c.tripsStatModel.value;
            final main = _c.stats.value;
            if (stat == null) {
              return SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.bar_chart_outlined, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Text(_c.fetchingTripStatsError.value.isEmpty ? 'No data available' : _c.fetchingTripStatsError.value,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                TextButton.icon(onPressed: () => _c.refreshMonthlyReports(),
                    icon: const Icon(Icons.refresh), label: const Text('Retry')),
              ])));
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildMonthSelector(primary, isDark),
                  const SizedBox(height: 20),
                  _buildNetBanner(stat, main, primary),
                  const SizedBox(height: 16),
                  _buildKpiGrid(stat, main, primary),
                  const SizedBox(height: 20),
                  _buildChartCard(primary),
                  const SizedBox(height: 20),
                  if (main != null) ...[_buildExpenseCard(main), const SizedBox(height: 20)],
                  _sectionTitle('Driver Performance'),
                  const SizedBox(height: 10),
                  _buildSettlements(stat.drivers, isVehicle: false),
                  const SizedBox(height: 20),
                  _sectionTitle('Vehicle Output'),
                  const SizedBox(height: 10),
                  _buildSettlements(stat.vehicles, isVehicle: true),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(Color primary) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: primary,
      leading: DrawerButton(color: Colors.white,
          onPressed: () => widget.triggerKey?.currentState?.openDrawer())
          .visibleIf(widget.triggerKey != null),
      actions: [
        Obx(() => GestureDetector(
          onTap: () async {
            if (_isPrinting || _c.tripsStatModel.value == null) return;
            setState(() => _isPrinting = true);
            await GenisisPrinter.printFinancialReports(_c.tripsStatModel.value!);
            setState(() => _isPrinting = false);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(12)),
            child: _isPrinting.lord(const WhiteLoader(), const Icon(Icons.print_rounded, color: Colors.white, size: 18)),
          ),
        ).visibleIf(_c.tripsStatModel.value != null)),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: LinearGradient(
            colors: [primary, primary.withBlue((primary.blue + 55).clamp(0, 255)), const Color(0xFF6C5DD3)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          )),
          child: SafeArea(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              const Text('Monthly Reports',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              const Text('Track your revenue, expenses, and operations',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          )),
        ),
      ),
    );
  }

  // ─── Month Selector ────────────────────────────────────────────────────────
  Widget _buildMonthSelector(Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(20)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _previousMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: primary.withAlpha(20), shape: BoxShape.circle),
              child: Icon(Icons.chevron_left_rounded, color: primary, size: 24),
            ),
          ),
          Obx(() {
            final month = _c.selectedMonth.value;
            final isCurrentMonth = month.year == DateTime.now().year && month.month == DateTime.now().month;
            return GestureDetector(
              onTap: () => _showMonthPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Text(
                          "${GenesisDate.getShortMonthName(month.month)} ${month.year}",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        if (isCurrentMonth)
                          Text(
                            "Current Month",
                            style: TextStyle(fontSize: 10, color: Colors.green.shade600, fontWeight: FontWeight.w700),
                          )
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down_rounded, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: _nextMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: primary.withAlpha(20), shape: BoxShape.circle),
              child: Icon(Icons.chevron_right_rounded, color: primary, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    int tempYear = _c.selectedMonth.value.year;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => setState(() => tempYear--), icon: const Icon(Icons.chevron_left)),
                      Text(tempYear.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: tempYear >= DateTime.now().year ? null : () => setState(() => tempYear++), 
                        icon: const Icon(Icons.chevron_right)
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final m = index + 1;
                      final isFuture = tempYear == DateTime.now().year && m > DateTime.now().month;
                      final isSelected = tempYear == _c.selectedMonth.value.year && m == _c.selectedMonth.value.month;
                      return InkWell(
                        onTap: isFuture ? null : () {
                          _c.selectedMonth.value = DateTime(tempYear, m, 1);
                          _c.refreshMonthlyReports();
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected ? null : Border.all(color: Colors.grey.withAlpha(40)),
                          ),
                          child: Text(
                            GenesisDate.getShortMonthName(m),
                            style: TextStyle(
                              color: isFuture 
                                ? Colors.grey 
                                : isSelected 
                                  ? Colors.white 
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
      }
    );
  }

  // ─── Net Profit Banner ─────────────────────────────────────────────────────
  Widget _buildNetBanner(stat, main, Color primary) {
    final revenue = (stat.summary.totalRevenue as num).toDouble();
    final expenses = main != null ? NumberUtils.getStatsTotalExpenses(main) : 0.0;
    final payroll = (main?.grossPayroll as num?)?.toDouble() ?? 0.0;
    final net = revenue - expenses - payroll;
    final pos = net >= 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pos 
              ? [const Color(0xFF0A6B4D), const Color(0xFF0DB37F)] 
              : [const Color(0xFF7A1616), const Color(0xFFD32F2F)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: (pos ? Colors.green : Colors.red).withAlpha(55), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withAlpha(28), borderRadius: BorderRadius.circular(10)),
              child: Icon(pos ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          const Text('Net Profit', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Text(NumberUtils.formatCurrency(net),
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
      ]),
    );
  }

  // ─── KPI Grid ──────────────────────────────────────────────────────────────
  Widget _buildKpiGrid(stat, main, Color primary) {
    final revenue = (stat.summary.totalRevenue as num).toDouble();
    final expenses = main != null ? NumberUtils.getStatsTotalExpenses(main) : 0.0;
    final payroll = (main?.grossPayroll as num?)?.toDouble() ?? 0.0;
    
    final trips = stat.summary.totalTrips;
    final distance = stat.summary.totalDistance ?? 0.0;
    final load = stat.summary.totalLoadWeight ?? 0.0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _kpiCard('Revenue', NumberUtils.formatCurrency(revenue), Icons.account_balance_wallet_rounded, Colors.green),
        _kpiCard('Total Expenses', NumberUtils.formatCurrency(expenses), Icons.money_off_rounded, Colors.redAccent),
        _kpiCard('Payroll', NumberUtils.formatCurrency(payroll), Icons.payments_rounded, Colors.orange),
        _kpiCard('Total Trips', '$trips', Icons.route_rounded, Colors.blue),
        _kpiCard('Total Distance', '${NumberUtils.formatNumber(distance)} km', Icons.speed_rounded, Colors.purple),
        _kpiCard('Total Load', '${NumberUtils.formatNumber(load)} kgs', Icons.monitor_weight_rounded, Colors.teal),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30), width: 1.5),
        boxShadow: [BoxShadow(color: color.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: GTheme.reverse(context)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Expense Card ──────────────────────────────────────────────────────────
  Widget _buildExpenseCard(main) {
    final total = NumberUtils.getStatsTotalExpenses(main);
    final items = [
      _Exp('Fuel', main.fuelExpense as double, const Color(0xFFFF9F43), Icons.local_gas_station_rounded),
      _Exp('Tollgate', main.tolgateExpense as double, const Color(0xFF4CA6EA), Icons.toll_rounded),
      _Exp('Truck Shop', main.truckShopExpense as double, const Color(0xFFFF6B6B), Icons.handyman_rounded),
      _Exp('Food', main.foodExpense as double, const Color(0xFF33D69F), Icons.restaurant_rounded),
      _Exp('Fines', main.finesExpense as double, const Color(0xFF6C5DD3), Icons.gavel_rounded),
      _Exp('Extras', main.extrasExpense as double, const Color(0xFF78909C), Icons.more_horiz_rounded),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context), borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withAlpha(18)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Expense Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.red.withAlpha(18), borderRadius: BorderRadius.circular(20)),
            child: Text(NumberUtils.formatCurrency(total),
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 16),
        ...items.map((e) {
          final pct = total > 0 ? (e.amount / total).clamp(0.0, 1.0) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: e.color.withAlpha(22), borderRadius: BorderRadius.circular(8)),
                  child: Icon(e.icon, color: e.color, size: 14)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(e.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500]))),
                  Text(NumberUtils.formatCurrency(e.amount), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  SizedBox(width: 34, child: Text('${(pct * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: e.color), textAlign: TextAlign.right)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: pct, minHeight: 4,
                        backgroundColor: e.color.withAlpha(18), valueColor: AlwaysStoppedAnimation(e.color))),
              ])),
            ]),
          );
        }),
      ]),
    );
  }

  // ─── Multi-Line Chart (Revenue + Expenses) ─────────────────────────────────
  Widget _buildChartCard(Color primary) {
    return Obx(() {
      final graphLoading = _c.isGraphLoading.value;
      final data = _c.graphData;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GTheme.cardColor(context), borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.withAlpha(18)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Revenue Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(children: [
            _legend('Revenue', const Color(0xFF6C5DD3)),
            const SizedBox(width: 16),
            _legend('Expenses', const Color(0xFFFF6B6B)),
          ]),
          const SizedBox(height: 24),
          // Chart
          SizedBox(
            height: 240,
            child: graphLoading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.show_chart_rounded, size: 40, color: Colors.grey.withAlpha(60)),
                        const SizedBox(height: 8),
                        const Text('No chart data', style: TextStyle(color: Colors.grey)),
                      ]))
                    : _buildMultiLineChart(data),
          ),
        ]),
      );
    });
  }

  Widget _legend(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 12, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
  ]);

  Widget _buildMultiLineChart(List data) {
    double maxY = 0;
    for (final d in data) {
      if (d.revenue > maxY) maxY = d.revenue.toDouble();
      if (d.maintenanceCost > maxY) maxY = d.maintenanceCost.toDouble();
    }
    if (maxY == 0) maxY = 100;
    final yi = (maxY / 4).clamp(1.0, double.infinity);
    String fmt(double v) {
      if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
      if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(0)}k';
      return '\$${v.toStringAsFixed(0)}';
    }
    return LineChart(LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: yi,
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withAlpha(18), strokeWidth: 1, dashArray: [4, 4])),
      borderData: FlBorderData(show: true,
          border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(35), width: 1.5))),
      lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => GTheme.cardColor(context).withAlpha(235),
        getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
          NumberUtils.formatCurrency(s.y),
          TextStyle(color: s.bar.color, fontWeight: FontWeight.bold, fontSize: 12),
        )).toList(),
      )),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 46, interval: yi,
            getTitlesWidget: (v, _) => Text(fmt(v), style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w600)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26, interval: 1,
            getTitlesWidget: (v, m) {
              final i = v.toInt();
              if (i < 0 || i >= data.length) return const SizedBox.shrink();
              final d = data[i];
              String lbl;
              // Because we set selectedPeriod = 'Daily' when fetching the graph for the month,
              // we can just show the day number:
              if (d.date.day % 5 != 0 && d.date.day != 1 && d.date.day != 31) return const SizedBox.shrink();
              lbl = '${d.date.day}';
              
              return SideTitleWidget(meta: m,
                  child: Text(lbl, style: const TextStyle(color: Color(0xff68737d), fontSize: 9, fontWeight: FontWeight.bold)));
            })),
      ),
      minX: 0,
      maxX: data.length <= 1 ? 1 : (data.length - 1).toDouble(),
      minY: 0,
      maxY: maxY * 1.15,
      lineBarsData: [
        // Revenue line
        LineChartBarData(
          spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.revenue.toDouble())).toList(),
          isCurved: true, preventCurveOverShooting: true,
          color: const Color(0xFF6C5DD3), barWidth: 2.5, isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(
            colors: [const Color(0xFF6C5DD3).withAlpha(55), const Color(0xFF6C5DD3).withAlpha(0)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          )),
        ),
        // Expenses line
        LineChartBarData(
          spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.maintenanceCost.toDouble())).toList(),
          isCurved: true, preventCurveOverShooting: true,
          color: const Color(0xFFFF6B6B), barWidth: 2.5, isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(
            colors: [const Color(0xFFFF6B6B).withAlpha(45), const Color(0xFFFF6B6B).withAlpha(0)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          )),
        ),
      ],
    ));
  }

  // ─── Settlements ───────────────────────────────────────────────────────────
  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));

  Widget _buildSettlements(List items, {required bool isVehicle}) {
    if (items.isEmpty) return Center(child: Padding(
      padding: const EdgeInsets.all(18),
      child: Text('No ${isVehicle ? "vehicle" : "driver"} settlements', style: TextStyle(color: Colors.grey[500])),
    ));
    return Container(
      decoration: BoxDecoration(color: GTheme.surface(context), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withAlpha(15))),
      child: ListView.separated(
        shrinkWrap: true, padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withAlpha(25), indent: 66),
        itemBuilder: (_, i) {
          final item = items[i];
          final name = isVehicle ? item.model as String : item.name as String;
          final sub  = isVehicle ? item.driverName as String : item.email as String;
          final rev  = (item.totalRevenue as num).toDouble();
          return ListTile(
            onTap: () async {
              if (isVehicle) {
                if ((item.id as String).isEmpty) return Toaster.showErrorTop('Vehicle', 'Not found');
                if (await _vc.fetchVehicle(id: item.id)) {
                  Get.to(() => VehicleDetailStatsScreen(vehicle: _vc.selectedVehicle.value!));
                }
              } else {
                if ((item.driverId as String).isEmpty) return Toaster.showErrorTop('Driver', 'Not found');
                Get.to(() => DriverStatsScreen(userId: item.driverId));
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: GTheme.primary(context).withAlpha(14), borderRadius: BorderRadius.circular(14)),
              child: Icon(isVehicle ? Icons.local_shipping_outlined : Icons.person_outline_rounded,
                  color: GTheme.primary(context), size: 20),
            ),
            title: Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
            subtitle: Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(NumberUtils.formatCurrency(rev),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.green.shade600)),
                Text('Revenue', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.withAlpha(100), size: 18),
            ]),
          );
        },
      ),
    );
  }
}

class _Exp {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  _Exp(this.label, this.amount, this.color, this.icon);
}
