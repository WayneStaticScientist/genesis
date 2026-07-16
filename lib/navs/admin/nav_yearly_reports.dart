import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:genesis/utils/pdf_marker/genesis_printer.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminNavYearlyReports extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavYearlyReports({super.key, required this.triggerKey});
  @override
  State<AdminNavYearlyReports> createState() => _AdminNavYearlyReportsState();
}

class _AdminNavYearlyReportsState extends State<AdminNavYearlyReports> {
  final _c = Get.find<StatsController>();
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _c.selectedYear.value = DateTime.now().year;
    _c.fetchYearlyReport();
  }

  void _previousYear() {
    _c.selectedYear.value--;
    _c.fetchYearlyReport();
  }

  void _nextYear() {
    if (_c.selectedYear.value < DateTime.now().year) {
      _c.selectedYear.value++;
      _c.fetchYearlyReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(primary),
          Obx(() {
            final loading = _c.isFetchingYearly.value;
            if (loading) return SliverFillRemaining(child: MaterialLoader().center());
            
            final report = _c.yearlyReport.value;
            if (report == null) {
              return SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.bar_chart_outlined, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Text(_c.yearlyError.value.isEmpty ? 'No data available' : _c.yearlyError.value,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                TextButton.icon(onPressed: () => _c.fetchYearlyReport(),
                    icon: const Icon(Icons.refresh), label: const Text('Retry')),
              ])));
            }

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildYearSelector(primary),
                  const SizedBox(height: 20),
                  _buildNetBanner(report, primary),
                  const SizedBox(height: 16),
                  _buildKpiGrid(report, primary),
                  const SizedBox(height: 20),
                  _buildChartCard(report, primary),
                  const SizedBox(height: 20),
                  const Text('Monthly Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  _buildMonthlyList(report),
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
            if (_isPrinting || _c.yearlyReport.value == null) return;
            setState(() => _isPrinting = true);
            await GenisisPrinter.printYearlyReport(_c.yearlyReport.value!, _c.selectedYear.value);
            setState(() => _isPrinting = false);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(12)),
            child: _isPrinting.lord(const MaterialLoader(), const Icon(Icons.print_rounded, color: Colors.white, size: 18)),
          ),
        ).visibleIf(_c.yearlyReport.value != null)),
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
              const Text('Yearly Reports',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              const Text('Track your annual financial performance',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          )),
        ),
      ),
    );
  }

  // ─── Year Selector ────────────────────────────────────────────────────────
  Widget _buildYearSelector(Color primary) {
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
            onTap: _previousYear,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: primary.withAlpha(20), shape: BoxShape.circle),
              child: Icon(Icons.chevron_left_rounded, color: primary, size: 24),
            ),
          ),
          Obx(() {
            final year = _c.selectedYear.value;
            final isCurrentYear = year == DateTime.now().year;
            return Column(
              children: [
                Text(
                  year.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                if (isCurrentYear)
                  Text(
                    "Current Year",
                    style: TextStyle(fontSize: 10, color: Colors.green.shade600, fontWeight: FontWeight.w700),
                  )
              ],
            );
          }),
          Obx(() => GestureDetector(
            onTap: _nextYear,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _c.selectedYear.value < DateTime.now().year ? primary.withAlpha(20) : Colors.grey.withAlpha(20), 
                shape: BoxShape.circle
              ),
              child: Icon(Icons.chevron_right_rounded, color: _c.selectedYear.value < DateTime.now().year ? primary : Colors.grey, size: 24),
            ),
          )),
        ],
      ),
    );
  }

  // ─── Net Profit Banner ─────────────────────────────────────────────────────
  Widget _buildNetBanner(report, Color primary) {
    final net = report.yearlyNetProfit;
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
          const Text('Yearly Net Profit', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Text(NumberUtils.formatCurrency(net),
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
      ]),
    );
  }

  // ─── KPI Grid ──────────────────────────────────────────────────────────────
  Widget _buildKpiGrid(report, Color primary) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _kpiCard('Total Revenue', NumberUtils.formatCurrency(report.yearlyRevenue), Icons.account_balance_wallet_rounded, Colors.green),
        _kpiCard('Total Expenses', NumberUtils.formatCurrency(report.yearlyExpenses), Icons.money_off_rounded, Colors.redAccent),
        _kpiCard('Total Payroll', NumberUtils.formatCurrency(report.yearlyPayroll), Icons.payments_rounded, Colors.orange),
        _kpiCard('Maintenance', NumberUtils.formatCurrency(report.yearlyMaintenance), Icons.handyman_rounded, Colors.blueGrey),
        _kpiCard('Total Trips', '${report.yearlyTrips}', Icons.route_rounded, Colors.blue),
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

  // ─── Multi-Line Chart (Revenue + Expenses) ─────────────────────────────────
  Widget _buildChartCard(report, Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context), borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withAlpha(18)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Monthly Revenue vs Expenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
          child: _buildMultiLineChart(report.monthlyData),
        ),
      ]),
    );
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
      if (d.expenses > maxY) maxY = d.expenses.toDouble();
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
              return SideTitleWidget(meta: m,
                  child: Text(GenesisDate.getShortMonthName(d.month), 
                    style: const TextStyle(color: Color(0xff68737d), fontSize: 9, fontWeight: FontWeight.bold)));
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
          spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.expenses.toDouble())).toList(),
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

  // ─── Monthly Breakdown List ────────────────────────────────────────────────
  Widget _buildMonthlyList(report) {
    return Container(
      decoration: BoxDecoration(color: GTheme.surface(context), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withAlpha(15))),
      child: ListView.separated(
        shrinkWrap: true, padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: report.monthlyData.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withAlpha(25)),
        itemBuilder: (_, i) {
          final month = report.monthlyData[i];
          final pos = month.netProfit >= 0;
          
          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: const Border(),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: (pos ? Colors.green : Colors.red).withAlpha(15), 
                borderRadius: BorderRadius.circular(14)
              ),
              child: Icon(Icons.calendar_month_rounded, color: pos ? Colors.green : Colors.red, size: 20),
            ),
            title: Text(GenesisDate.getShortMonthName(month.month), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
            subtitle: Text('${month.trips} trips completed', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(NumberUtils.formatCurrency(month.netProfit),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: pos ? Colors.green.shade600 : Colors.red)),
                Text('Net Profit', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.withAlpha(100), size: 20),
            ]),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black.withAlpha(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _breakdownItem('Revenue', month.revenue, Colors.green),
                    _breakdownItem('Expenses', month.expenses, Colors.redAccent),
                    _breakdownItem('Payroll', month.payroll, Colors.orange),
                    _breakdownItem('Maintenance', month.maintenance, Colors.blueGrey),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _breakdownItem(String label, double val, Color color) {
    return Column(
      children: [
        Text(NumberUtils.formatCurrency(val), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
