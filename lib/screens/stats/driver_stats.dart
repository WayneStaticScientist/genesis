import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/utils/pdf_marker/genesis_printer.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
// Assuming these models are in your project as per your snippet
// import 'package:genesis/models/user_model.dart';

class DriverStatsScreen extends StatefulWidget {
  final String userId; // Pass your User model instance here
  const DriverStatsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DriverStatsScreenState createState() => _DriverStatsScreenState();
}

class _DriverStatsScreenState extends State<DriverStatsScreen> {
  final _navReports = Get.find<StatsController>();
  late DateTimeRange _selectedDateRange;
  bool _isPrinting = false;
  @override
  void initState() {
    super.initState();
    // Default range: Last 30 days
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    refresh();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: GTheme.copyOverlay(context),
        title: const Text(
          "Performance Insights",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(
            () => _navReports.userTripStats.value == null
                ? 0.gapHeight
                : IconButton(
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
                    icon: _isPrinting.lord(AdaptiveLoader(), Icon(Icons.print)),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (_navReports.fetchingUserTripStatus.value) {
                return [
                  MaterialLoader(),
                ].row(mainAxisAlignment: MainAxisAlignment.center);
              }
              if (_navReports.fetchingUserTripStatsError.value.isNotEmpty ||
                  _navReports.userTripStats.value == null) {
                return [
                  _navReports.fetchingUserTripStatsError.value.text(),
                ].row(mainAxisAlignment: MainAxisAlignment.center);
              }
              return [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildDateSelector(),
                const SizedBox(height: 24),
                _buildStatCards(),
                const SizedBox(height: 32),
                const Text(
                  "Recent Trip History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTripList(),
                const SizedBox(height: 40),
              ].column(mainAxisSize: MainAxisSize.min);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              "${_navReports.userTripStats.value!.firstName[0]}${_navReports.userTripStats.value!.lastName[0]}",
              style: TextStyle(
                color: GTheme.cardColor(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_navReports.userTripStats.value!.firstName} ${_navReports.userTripStats.value!.lastName}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _navReports.userTripStats.value!.email,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.indigo,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reporting Period",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "${GenesisDate.getInformalDate(_selectedDateRange.start)} - ${GenesisDate.getInformalDate(_selectedDateRange.end)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _statTile(
            "Trips Completed",
            _navReports.userTripStats.value!.totalTrips.toString(),
            Icons.local_shipping_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statTile(
            "Total Revenue",
            NumberUtils.formatCurrency(
              _navReports.userTripStats.value!.totalRevenue,
            ),
            Icons.account_balance_wallet_outlined,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTripList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _navReports.userTripStats.value!.recentTrips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = _navReports.userTripStats.value!.recentTrips[index];
        return Container(
          decoration: BoxDecoration(
            color: GTheme.cardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withAlpha(50)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: _buildStepperLine(index == 0),
              title: Text(
                trip.destination,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                GenesisDate.getInformalShortDate(trip.date),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                NumberUtils.formatCurrency(trip.revenue),
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(72, 0, 20, 20),
                  child: Column(
                    children: [
                      _detailRow(
                        "Route",
                        "${trip.origin} → ${trip.destination}",
                      ),
                      const SizedBox(height: 8),
                      _detailRow("Load", trip.loadType),
                      const SizedBox(height: 8),
                      _detailRow(
                        "Load Weight",
                        '${NumberUtils.formatNumber(trip.loadWeight)}kg',
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isLatest ? Colors.indigo : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: isLatest ? Colors.indigo.shade100 : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        Container(width: 2, height: 30, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  void refresh() {
    _navReports.fetchUSerTripStats(widget.userId, _selectedDateRange);
  }
}
