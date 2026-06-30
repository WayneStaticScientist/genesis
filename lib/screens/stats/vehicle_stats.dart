import 'package:genesis/screens/stats/vehicle_mantainance_history.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/utils/pdf_marker/genesis_printer.dart';
import 'package:genesis/widgets/layouts/foot_note.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/controllers/stats_controller.dart';
import 'package:genesis/screens/vehicles/vehicle_edit.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:genesis/controllers/insurance_controller.dart';
import 'package:genesis/widgets/layouts/insurance_bottom_sheet.dart';
import 'package:line_icons/line_icons.dart';

// --- CONTROLLER ---
class VehicleStatsController extends GetxController {
  var selectedTab = 0.obs;
  var dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  ).obs;

  void updateDateRange(DateTimeRange range, String vehicleId) {
    dateRange.value = range;
    getStatsForVehicle(vehicleId);
  }

  void getStatsForVehicle(String vehicleId) async {
    final controller = Get.find<StatsController>();
    await controller.fetchVehicleTripStats(vehicleId, dateRange.value);
  }
}

// --- MAIN SCREEN ---
class VehicleDetailStatsScreen extends StatefulWidget {
  final VehicleModel vehicle;
  VehicleDetailStatsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailStatsScreen> createState() =>
      _VehicleDetailStatsScreenState();
}

class _VehicleDetailStatsScreenState extends State<VehicleDetailStatsScreen> {
  final _statsController = Get.find<StatsController>();
  final _insurancesController = Get.find<InsuranceController>();

  var dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isPrinting = false;
  final controller = Get.put(VehicleStatsController());

  @override
  void initState() {
    controller.getStatsForVehicle(widget.vehicle.id ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          
          // Header Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: _buildHeaderInfo(context),
            ),
          ),

          // Alert banner for due/overdue reminders
          SliverToBoxAdapter(child: _buildDueRemindersAlert(context)),

          SliverToBoxAdapter(
            child: FootNote(
              iconData: LineIcons.cog,
              description:
                  'Tap on expenses to view all maintenance records for this vehicle',
            ).padding(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
          ),

          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(child: _buildTotalsSection(context)),
          SliverToBoxAdapter(child: _buildDocumentSection(context)),

          if (widget.vehicle.serviceReminders.isNotEmpty)
            SliverToBoxAdapter(child: _buildServiceRemindersSection(context)),

          SliverToBoxAdapter(
            child: FootNote(
              iconData: LineIcons.moneyBill,
              iconColor: Colors.purple,
              description:
                  'You can tap on insurances to pay insurance for the vehicle or view its history',
            ).padding(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabDelegate(child: _buildTabSwitcher(context)),
          ),

          Obx(
            () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: [
                  "Date Range: ${GenesisDate.getInformalShortDate(controller.dateRange.value.start)} - "
                          "${GenesisDate.getInformalShortDate(controller.dateRange.value.end)}"
                      .text(
                    style: GoogleFonts.plusJakartaSans(
                      color: GTheme.primary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ].row(mainAxisAlignment: MainAxisAlignment.center),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          Obx(
            () => controller.selectedTab.value == 0
                ? _buildHistoryList(context, isService: true)
                : _buildHistoryList(context, isService: false),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  // 1. PREMIUM APP BAR
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "Vehicle Profile",
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: GTheme.reverse(context),
        ),
      ),
      actions: [
        Obx(
          () => _statsController.vehicleTripStats.value == null
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () async {
                    if (_isPrinting) return;
                    setState(() {
                      _isPrinting = true;
                    });
                    await GenisisPrinter.printVehicleProfileReports(
                      widget.vehicle,
                      _statsController.vehicleTripStats.value!,
                    );
                    setState(() {
                      _isPrinting = false;
                    });
                  },
                  icon: _isPrinting.lord(
                    AdaptiveLoader(),
                    Icon(Icons.print_rounded, color: GTheme.reverse(context)),
                  ),
                ),
        ),
        IconButton(
          icon: Icon(Icons.edit_rounded, color: GTheme.reverse(context)),
          onPressed: () => Get.to(() => AdminEditVehicle(vehicle: widget.vehicle)),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // 2. HEADER INFO (The "Wow" Profile Card)
  Widget _buildHeaderInfo(BuildContext context) {
    final isDark = GTheme.isDark(context);
    Color statusColor;
    IconData statusIcon;
    switch (widget.vehicle.status) {
      case 'Active':
        statusColor = Colors.green;
        statusIcon = Icons.sensors;
        break;
      case 'In Service':
        statusColor = Colors.orange;
        statusIcon = Icons.build_circle_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.power_settings_new_rounded;
    }

    final hasTracker = widget.vehicle.trackerId != null && widget.vehicle.trackerId!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark.lord(Colors.white12, Colors.black.withAlpha(5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Avatar with Status Glow
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withAlpha(35),
                      statusColor.withAlpha(10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.vehicle.carModel.isNotEmpty ? widget.vehicle.carModel[0].toUpperCase() : 'C',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: statusColor,
                  ),
                ).center(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicle.carModel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: GTheme.reverse(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.vehicle.licencePlate,
                            style: GoogleFonts.jetBrainsMono(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 10, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                widget.vehicle.status.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _infoChip(
                          Icons.local_gas_station_rounded,
                          "${widget.vehicle.fuelLevel.toStringAsFixed(0)}% Fuel",
                          Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _infoChip(
                          Icons.speed_rounded,
                          "${widget.vehicle.usage.toStringAsFixed(0)} km",
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasTracker) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.satellite_alt_rounded, size: 14, color: Colors.purple.shade400),
                const SizedBox(width: 8),
                Text(
                  "Hardware GPS:",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.vehicle.trackerId!,
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // DUE/OVERDUE SERVICE REMINDERS BANNER
  Widget _buildDueRemindersAlert(BuildContext context) {
    final dueReminders = widget.vehicle.serviceReminders.where((reminder) {
      if (reminder.type == 'mileage') {
        double remaining = reminder.mileage - widget.vehicle.usage;
        return remaining <= 0;
      } else {
        if (reminder.date == null) return false;
        int daysRemaining = reminder.date!.difference(DateTime.now()).inDays;
        return daysRemaining <= 0;
      }
    }).toList();

    if (dueReminders.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(15),
        border: Border.all(color: Colors.red.withAlpha(100), width: 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                "Service Reminders Due!",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...dueReminders.map((reminder) {
            String dueDetail = "";
            if (reminder.type == 'mileage') {
              double overdue = widget.vehicle.usage - reminder.mileage;
              dueDetail = overdue == 0 ? "Due now" : "Overdue by ${NumberUtils.formatNumber(overdue)} km";
            } else {
              int overdueDays = DateTime.now().difference(reminder.date!).inDays;
              dueDetail = overdueDays == 0 ? "Due today" : "Overdue by $overdueDays days";
            }
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "• ${reminder.name} ($dueDetail)",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 3. QUICK ACTION STATS
  Widget _buildQuickActions(BuildContext context) {
    return Obx(() {
      if (_statsController.fetchingUserTripStatus.value) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: MaterialLoader().center(),
        );
      }
      if (_statsController.fetchingVehicleTripStatsError.value.isNotEmpty ||
          _statsController.vehicleTripStats.value == null) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: _statsController.fetchingVehicleTripStatsError.value.text().center(),
        );
      }
      
      final stats = _statsController.vehicleTripStats.value!;
      final tripExpenses = stats.trips.fold(0.0, (sum, trip) => sum + NumberUtils.getTripExpenseTotal(trip));
      final totalExpenses = stats.totalMaintenanceCosts + tripExpenses;
      final profit = stats.totalRevenue - totalExpenses;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statMiniCard(
                  "Trips",
                  stats.totalTrips.toInt().toString(),
                  Colors.blue,
                ),
                _statMiniCard(
                  "Revenue",
                  NumberUtils.formatCurrency(stats.totalRevenue),
                  Colors.green,
                ),
                _statMiniCard(
                  "Expenses",
                  NumberUtils.formatCurrency(totalExpenses),
                  Colors.redAccent,
                ).onTap(
                  () => Get.to(
                    () => MaintenanceHistoryScreen(vehicle: widget.vehicle),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _statWideCard(
              "Net Profit",
              NumberUtils.formatCurrency(profit),
              profit >= 0 ? Colors.teal : Colors.red,
              Icons.trending_up,
            ),
          ],
        ),
      );
    });
  }

  Widget _statMiniCard(String label, String value, Color color) {
    final isDark = GTheme.isDark(context);
    return Container(
      width: Get.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark.lord(color.withAlpha(40), color.withAlpha(20)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statWideCard(String label, String value, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 3.5 VEHICLE PERFORMANCE SECTION
  Widget _buildTotalsSection(BuildContext context) {
    return Obx(() {
      if (_statsController.fetchingUserTripStatus.value ||
          _statsController.vehicleTripStats.value == null) {
        return const SizedBox.shrink();
      }

      final stats = _statsController.vehicleTripStats.value!;
      final fuelConsumption = _calculateFuelConsumption(stats.totalMileage);
      final ratioLabel = widget.vehicle.loadType.toLowerCase() == 'loader'
          ? ((widget.vehicle.emptyRatio + widget.vehicle.loadedFuelRatio) / 2)
                .toStringAsFixed(2)
          : widget.vehicle.fuelRatio.toStringAsFixed(2);
      final ratioText = widget.vehicle.loadType.toLowerCase() == 'loader'
          ? 'Avg ratio $ratioLabel L/km'
          : 'Ratio $ratioLabel L/km';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GTheme.emmense(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dashboard_customize_rounded,
                    color: GTheme.primary(context),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vehicle Performance',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: GTheme.reverse(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTotalsCard(
                      title: 'Total Mileage',
                      value: '${NumberUtils.formatNumber(stats.totalMileage)} km',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTotalsCard(
                      title: 'Total Hours',
                      value: '${stats.totalHours} hrs',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTotalsCard(
                title: 'Estimated Fuel Use',
                value: '${NumberUtils.formatNumber(fuelConsumption)} Liters',
                color: Colors.green,
                subtitle: ratioText,
                isWide: true,
              ),
            ],
          ),
        ),
      );
    });
  }

  double _calculateFuelConsumption(double mileage) {
    if (widget.vehicle.loadType.toLowerCase() == 'loader') {
      final avgRatio =
          (widget.vehicle.emptyRatio + widget.vehicle.loadedFuelRatio) / 2;
      return mileage * avgRatio;
    }
    return mileage * widget.vehicle.fuelRatio;
  }

  Widget _buildTotalsCard({
    required String title,
    required String value,
    required Color color,
    String? subtitle,
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  // 4. DOCUMENTS (License & Permits)
  Widget _buildDocumentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Documentation",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: GTheme.reverse(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _docCard(
                "License Details",
                (widget.vehicle.licence == null
                    ? "No Licence Found"
                    : 'Expires ${GenesisDate.getInformalShortDate(widget.vehicle.licence!.expiryDate)}'),
                Icons.badge_rounded,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _docCard(
                "Insurance Policies",
                "${widget.vehicle.insurances.length} Active Covers",
                Icons.shield_rounded,
                Colors.purple,
                ontap: () => _showBottomInsurances(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _docCard(
    String title,
    String expiry,
    IconData icon,
    Color color, {
    VoidCallback? ontap,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: GTheme.reverse(context)),
            ),
            const SizedBox(height: 2),
            Text(
              expiry,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ).onTap(() => ontap?.call()),
    );
  }

  // SERVICE REMINDERS SECTION
  Widget _buildServiceRemindersSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Service Reminders",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: GTheme.reverse(context),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.vehicle.serviceReminders.map((reminder) {
            String remainingText;
            Color statusColor;
            if (reminder.type == 'mileage') {
              double remaining = reminder.mileage - widget.vehicle.usage;
              if (remaining <= 0) {
                remainingText =
                    'Overdue by ${NumberUtils.formatNumber(remaining.abs())} km';
                statusColor = Colors.red;
              } else {
                remainingText =
                    '${NumberUtils.formatNumber(remaining)} km remaining';
                statusColor = Colors.green;
              }
            } else {
              // date
              if (reminder.date == null) {
                remainingText = 'No date set';
                statusColor = Colors.grey;
              } else {
                int daysRemaining = reminder.date!
                    .difference(DateTime.now())
                    .inDays;
                if (daysRemaining < 0) {
                  remainingText = 'Overdue by ${daysRemaining.abs()} days';
                  statusColor = Colors.red;
                } else if (daysRemaining == 0) {
                  remainingText = 'Due today';
                  statusColor = Colors.orange;
                } else {
                  remainingText = '$daysRemaining days remaining';
                  statusColor = Colors.green;
                }
              }
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: statusColor.withAlpha(35)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.build_rounded, color: statusColor, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: GTheme.reverse(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reminder.type == 'mileage'
                              ? 'Target: ${NumberUtils.formatNumber(reminder.mileage)} km'
                              : 'Due: ${reminder.date != null ? GenesisDate.getInformalShortDate(reminder.date!) : 'N/A'}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    remainingText,
                    style: GoogleFonts.plusJakartaSans(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 5. TAB SWITCHER + DATE PICKER
  Widget _buildTabSwitcher(BuildContext context) {
    final isDark = GTheme.isDark(context);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark.lord(Colors.grey.withAlpha(30), Colors.grey[200]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Obx(
                () => Row(
                  children: [_tabBtn(0, "Services"), _tabBtn(1, "Trips")],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: isDark 
                    ? ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: GTheme.primary(context),
                        ),
                      )
                    : ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: GTheme.primary(context),
                        ),
                      ),
                  child: child!,
                ),
              );
              if (picked != null)
                controller.updateDateRange(picked, widget.vehicle.id ?? '');
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GTheme.emmense(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark.lord(Colors.white12, Colors.black.withAlpha(5)),
                ),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: GTheme.primary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(int index, String label) {
    bool isSelected = controller.selectedTab.value == index;
    final isDark = GTheme.isDark(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected 
              ? isDark.lord(Colors.grey.shade800, Colors.white) 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
              color: isSelected 
                ? GTheme.reverse(context) 
                : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  // 6. HISTORY LIST (Service/Trips)
  Widget _buildHistoryList(BuildContext context, {required bool isService}) {
    return Obx(() {
      if (_statsController.fetchingVehicleTripStatus.value) {
        return SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: MaterialLoader().center(),
          ),
        );
      }
      if (_statsController.fetchingVehicleTripStatsError.value.isNotEmpty ||
          _statsController.vehicleTripStats.value == null) {
        return SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: _statsController.fetchingVehicleTripStatsError.value.text().center(),
          ),
        );
      }
      
      if (isService) {
        final list = _statsController.vehicleTripStats.value!.maintenances;
        if (list.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.build_circle_outlined, color: Colors.grey.shade400, size: 40),
                  const SizedBox(height: 8),
                  Text("No maintenance records found", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = list[index];
                return _historyItem(
                  title: item.issueDetails,
                  subtitle: item.urgenceLevel.toUpperCase(),
                  date: GenesisDate.getInformalShortDate(item.dueDate),
                  amount: '-${NumberUtils.formatCurrency(item.estimatedCosts)}',
                  profit: -item.estimatedCosts.toDouble(),
                  icon: Icons.build_rounded,
                  iconColor: Colors.orange,
                );
              },
              childCount: list.length,
            ),
          ),
        );
      }
      
      final list = _statsController.vehicleTripStats.value!.trips;
      if (list.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(Icons.route_outlined, color: Colors.grey.shade400, size: 40),
                const SizedBox(height: 8),
                Text("No trips logged for this range", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = list[index];
              final tripExpense = NumberUtils.getTripExpenseTotal(item);
              final tripProfit = item.tripPayout - tripExpense;
              return _historyItem(
                title:
                    "${item.origin} ➔ ${item.destinations.isNotEmpty ? item.destinations.last.name : item.destination}",
                subtitle:
                    "Payload: ${item.loadWeight} kgs • Exp: ${NumberUtils.formatCurrency(tripExpense)}",
                date: item.startTime != null
                    ? GenesisDate.getInformalShortDate(item.startTime!)
                    : '',
                amount: NumberUtils.formatCurrency(item.tripPayout),
                profit: tripProfit,
                icon: Icons.local_shipping_outlined,
                iconColor: Colors.blue,
              );
            },
            childCount: list.length,
          ),
        ),
      );
    });
  }

  Widget _historyItem({
    required String title,
    required String subtitle,
    required String date,
    required String amount,
    required double profit,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = GTheme.isDark(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark.lord(Colors.white12, Colors.black.withAlpha(5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: GTheme.reverse(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$date • $subtitle",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                amount,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: profit >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Profit: ${NumberUtils.formatCurrency(profit)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: profit >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBottomInsurances() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InsuranceBottomSheet(
        items: widget.vehicle.insurances,
        onPayAll: () {
          _proceedToInsurancePayment();
        },
        vehicleModel: widget.vehicle,
      ),
    );
  }

  void _proceedToInsurancePayment() {
    final double totalAmount = widget.vehicle.insurances.fold(
      0,
      (sum, item) => sum + item.value,
    );
    Get.defaultDialog(
      title: "Proceed Payment",
      content:
          "Proceed payment for ${widget.vehicle.carModel} for insurances payment for ${NumberUtils.formatCurrency(totalAmount)}"
              .text(),
      textCancel: "cancel",
      textConfirm: "pay",
      onConfirm: () {
        Get.back();
        _insurancesController.payInsurances(
          widget.vehicle.id ?? '',
          widget.vehicle.insurances,
        );
      },
    );
  }
}

// Helper for Sticky Tab Switcher
class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverTabDelegate({required this.child});

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) => false;
}
