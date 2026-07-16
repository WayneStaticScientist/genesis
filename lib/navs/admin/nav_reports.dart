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

class AdminNavReports extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavReports({super.key, required this.triggerKey});
  @override
  State<AdminNavReports> createState() => _AdminNavReportsState();
}

class _AdminNavReportsState extends State<AdminNavReports> {
  bool _isPrinting = false;
  // Graph period only — does NOT affect the KPI summary cards
  String _graphPeriod = 'Monthly';
  final _c = Get.find<StatsController>();
  final _vc = Get.find<VehicleControler>();

  @override
  void initState() {
    super.initState();
    _c.fetchTripStats('Monthly'); // summary is always YTD Monthly
    if (_c.stats.value == null) _c.fetchStats(null);
    _refreshGraph();
  }

  void _refreshGraph() {
    _c.selectedPeriod.value = _graphPeriod;
    _c.fetchGraphStats(null);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
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
                TextButton.icon(onPressed: () => _c.fetchTripStats('Monthly'),
                    icon: const Icon(Icons.refresh), label: const Text('Retry')),
              ])));
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildNetBanner(stat, main, primary),
                  const SizedBox(height: 16),
                  _buildKpiRow(stat, primary),
                  const SizedBox(height: 20),
                  if (main != null) ...[_buildExpenseCard(main), const SizedBox(height: 20)],
                  _buildChartCard(primary),
                  const SizedBox(height: 20),
                  _sectionTitle('Vehicle Settlements'),
                  const SizedBox(height: 10),
                  _buildSettlements(stat.vehicles, isVehicle: true),
                  const SizedBox(height: 20),
                  _sectionTitle('Driver Settlements'),
                  const SizedBox(height: 10),
                  _buildSettlements(stat.drivers, isVehicle: false),
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
      expandedHeight: 190,
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withAlpha(22), borderRadius: BorderRadius.circular(20)),
                child: Text(GenesisDate.formatNormalDate(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              const Text('Performance Reports',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 3),
              const Text('Revenue · Expenses · Fleet insights',
                  style: TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
          )),
        ),
      ),
    );
  }

  // ─── Net Profit Banner ─────────────────────────────────────────────────────
  Widget _buildNetBanner(stat, main, Color primary) {
    final revenue = (stat.summary.totalRevenue as num).toDouble();
    final expenses = main != null ? NumberUtils.getStatsTotalExpenses(main) : 0.0;
    final payroll = (main?.grossPayroll as num?)?.toDouble() ?? 0.0;
    final maintenance = main != null ? main.totalMaintainanceCost : 0.0;
    final net = revenue - expenses - payroll - maintenance;
    final pos = net >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pos ? [const Color(0xFF0A6B4D), const Color(0xFF0DB37F)] : [const Color(0xFF7A1616), const Color(0xFFD32F2F)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: (pos ? Colors.green : Colors.red).withAlpha(55), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: Colors.white.withAlpha(28), borderRadius: BorderRadius.circular(10)),
              child: Icon(pos ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: Colors.white, size: 16)),
          const SizedBox(width: 8),
          const Text('Net Profit (YTD)', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        Text(NumberUtils.formatCurrency(net),
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _miniStat('Revenue', NumberUtils.formatCurrency(revenue))),
          Expanded(child: _miniStat('Expenses', NumberUtils.formatCurrency(expenses))),
          Expanded(child: _miniStat('Payroll', NumberUtils.formatCurrency(payroll))),
          Expanded(child: _miniStat('Maintenance', NumberUtils.formatCurrency(maintenance))),
        ]),
      ]),
    );
  }

  Widget _miniStat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
  ]);

  // ─── KPI Row ───────────────────────────────────────────────────────────────
  Widget _buildKpiRow(stat, Color primary) {
    return Row(children: [
      Expanded(child: _kpiTile('Total Trips', '${stat.summary.totalTrips}', Icons.route_rounded, primary)),
      const SizedBox(width: 12),
      Expanded(child: _kpiTile('Margin', '${(stat.summary.margin as num).toStringAsFixed(1)}%', Icons.percent_rounded, const Color(0xFF6C5DD3))),
      const SizedBox(width: 12),
      Expanded(child: _kpiTile('YTD Period', 'Monthly', Icons.calendar_today_rounded, const Color(0xFF00C897))),
    ]);
  }

  Widget _kpiTile(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: GTheme.cardColor(context), borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withAlpha(40), width: 1.5),
      boxShadow: [BoxShadow(color: color.withAlpha(14), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 15)),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.4), maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500)),
    ]),
  );

  // ─── Expense Card ──────────────────────────────────────────────────────────
  Widget _buildExpenseCard(main) {
    final total = NumberUtils.getStatsTotalExpenses(main);
    final items = [
      _Exp('Fuel', main.fuelExpense as double, const Color(0xFFFF9F43), Icons.local_gas_station_rounded),
      _Exp('Tollgate', main.tolgateExpense as double, const Color(0xFF4CA6EA), Icons.toll_rounded),
      _Exp('Truck Stop', main.truckStopExpense as double, const Color(0xFFFF6B6B), Icons.handyman_rounded),
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
                  Text(NumberUtils.formatCurrency(e.amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
          // Title row + period selector — uses Wrap to avoid overflow
          Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Analytics Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(children: [
            _legend('Revenue', const Color(0xFF6C5DD3)),
            const SizedBox(width: 16),
            _legend('Expenses', const Color(0xFFFF6B6B)),
          ]),
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 260,
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
              if (_graphPeriod == 'Monthly') {
                lbl = GenesisDate.getShortMonthName(d.date.month)[0];
              } else if (_graphPeriod == 'Yearly') {
                lbl = '${d.date.year}';
              } else {
                if (d.date.day % 5 != 0) return const SizedBox.shrink();
                lbl = '${d.date.day}';
              }
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

  // ─── Period Selector (graph only) ──────────────────────────────────────────
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: GTheme.surface(context), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withAlpha(20))),
      child: Row(mainAxisSize: MainAxisSize.min, children: ['Daily', 'Monthly', 'Yearly'].map((p) {
        final sel = _graphPeriod == p;
        return GestureDetector(
          onTap: () {
            if (_graphPeriod == p) return;
            setState(() => _graphPeriod = p);
            _refreshGraph();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: sel ? const Color(0xFF6C5DD3) : Colors.transparent, borderRadius: BorderRadius.circular(7)),
            child: Text(p, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? Colors.white : Colors.grey[500])),
          ),
        );
      }).toList()),
    );
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: GTheme.primary(context).withAlpha(14), borderRadius: BorderRadius.circular(12)),
              child: Icon(isVehicle ? Icons.local_shipping_outlined : Icons.person_outline_rounded,
                  color: GTheme.primary(context), size: 18),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            subtitle: Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(NumberUtils.formatCurrency(rev),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                Text('Settled', style: TextStyle(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.blue.withAlpha(180), size: 18),
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
