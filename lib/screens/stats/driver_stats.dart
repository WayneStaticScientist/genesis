import 'package:genesis/utils/pdf_marker/genesis_printer.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:genesis/models/user_trip_stats_model.dart';

class DriverStatsScreen extends StatefulWidget {
  final String userId;
  const DriverStatsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DriverStatsScreenState createState() => _DriverStatsScreenState();
}

class _DriverStatsScreenState extends State<DriverStatsScreen> {
  final _navReports = Get.find<StatsController>();
  DateTimeRange? _selectedDateRange;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    // Default range is null (All Time)
    _selectedDateRange = null;
    refresh();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      refresh();
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
    });
    refresh();
  }

  String _formatTurnaroundTime(int ms) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: GTheme.reverse(context),
        systemOverlayStyle: GTheme.copyOverlay(context),
        title: const Text(
          "Driver Insights",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(
            () => _navReports.userTripStats.value == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      onPressed: () async {
                        if (_isPrinting) return;
                        setState(() {
                          _isPrinting = true;
                        });
                        await GenisisPrinter.printUserInsightsState(
                          _navReports.userTripStats.value!,
                          _selectedDateRange,
                        );
                        setState(() {
                          _isPrinting = false;
                        });
                      },
                      icon: _isPrinting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            )
                          : Icon(Icons.print_rounded, color: primaryColor),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (_navReports.fetchingUserTripStatus.value) {
                return const Center(child: Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: MaterialLoader(),
                ));
              }
              if (_navReports.fetchingUserTripStatsError.value.isNotEmpty ||
                  _navReports.userTripStats.value == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _navReports.fetchingUserTripStatsError.value.isNotEmpty
                              ? _navReports.fetchingUserTripStatsError.value
                              : "No data found for this driver.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final stats = _navReports.userTripStats.value!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(stats),
                  const SizedBox(height: 24),
                  _buildDateSelector(),
                  const SizedBox(height: 24),
                  _buildStatCards(stats),
                  const SizedBox(height: 32),
                  if (stats.monthlyReports.isNotEmpty) ...[
                    const Text(
                      "Monthly Reports",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildMonthlyReportList(stats),
                    const SizedBox(height: 32),
                  ],
                  const Text(
                    "Recent Trip History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTripList(stats),
                  const SizedBox(height: 40),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserTripStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5DD3), Color(0xFF8C7DF3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                stats.firstName.isNotEmpty && stats.lastName.isNotEmpty
                    ? "${stats.firstName[0]}${stats.lastName[0]}".toUpperCase()
                    : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${stats.firstName} ${stats.lastName}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  stats.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withAlpha(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5DD3).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF6C5DD3),
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reporting Period",
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedDateRange == null
                        ? "All Time Data"
                        : "${GenesisDate.getInformalDate(_selectedDateRange!.start)} - ${GenesisDate.getInformalDate(_selectedDateRange!.end)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedDateRange != null)
              IconButton(
                onPressed: _clearDateRange,
                icon: const Icon(Icons.clear_rounded, size: 20, color: Colors.red),
              )
            else
              const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(UserTripStatsModel stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statTile(
                "Total Revenue",
                NumberUtils.formatCurrency(stats.totalRevenue),
                Icons.account_balance_wallet_rounded,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statTile(
                "Total Expenses",
                NumberUtils.formatCurrency(stats.totalExpenses),
                Icons.trending_down_rounded,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statTile(
                "Gross Profit",
                NumberUtils.formatCurrency(stats.grossProfit),
                Icons.monetization_on_rounded,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statTile(
                "Completed Trips",
                stats.totalTrips.toString(),
                Icons.local_shipping_rounded,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _statTileLarge(
          "Active Turnaround Time",
          _formatTurnaroundTime(stats.totalTurnaroundTimeMs),
          Icons.timer_rounded,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _statTileLarge(String label, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReportList(UserTripStatsModel stats) {
    return Container(
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.monthlyReports.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withAlpha(20)),
        itemBuilder: (context, index) {
          final m = stats.monthlyReports[index];
          final monthName = GenesisDate.getShortMonthName(m.month);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5DD3).withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$monthName ${m.year}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C5DD3),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${m.totalTrips} Trips",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            "GP: ${NumberUtils.formatCurrency(m.grossProfit)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rev: ${NumberUtils.formatCurrency(m.totalRevenue)}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                          ),
                          Text(
                            "Exp: ${NumberUtils.formatCurrency(m.totalExpenses)}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "Active: ${_formatTurnaroundTime(m.totalTurnaroundTimeMs)}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripList(UserTripStatsModel stats) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.recentTrips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = stats.recentTrips[index];
        return Container(
          decoration: BoxDecoration(
            color: GTheme.cardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withAlpha(20)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: _buildStepperLine(index == 0),
              title: Text(
                trip.destination,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                GenesisDate.getInformalShortDate(trip.date),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: Text(
                NumberUtils.formatCurrency(trip.revenue),
                style: const TextStyle(
                  color: Color(0xFF6C5DD3),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(72, 0, 20, 16),
                  child: Column(
                    children: [
                      Divider(color: Colors.grey.withAlpha(20)),
                      const SizedBox(height: 8),
                      _detailRow(
                        "Route",
                        "${trip.origin} → ${trip.destinations.isNotEmpty ? trip.destinations.last.name : trip.destination}",
                      ),
                      const SizedBox(height: 8),
                      _detailRow("Load Type", trip.loadType),
                      const SizedBox(height: 8),
                      _detailRow(
                        "Load Weight",
                        '${NumberUtils.formatNumber(trip.loadWeight)} kg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepperLine(bool isLatest) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isLatest ? const Color(0xFF6C5DD3) : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: isLatest ? const Color(0xFF6C5DD3).withAlpha(100) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        Container(width: 1.5, height: 26, color: Colors.grey.withAlpha(30)),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }

  void refresh() {
    _navReports.fetchUSerTripStats(widget.userId, _selectedDateRange);
  }
}
