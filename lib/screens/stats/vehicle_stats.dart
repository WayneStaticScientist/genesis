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
  // Pass your Vehicle model here
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildHeaderInfo(context)),
          SliverToBoxAdapter(
            child: FootNote(
              iconData: LineIcons.cog,
              description:
                  'Tap on maintainances to view all mantainances for that vehicle',
            ).padding(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
          ),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(child: _buildTotalsSection(context)),

          SliverToBoxAdapter(child: _buildDocumentSection(context)),
          if (widget.vehicle.serviceReminders.isNotEmpty)
            SliverToBoxAdapter(child: _buildServiceRemindersSection(context)),
          SliverToBoxAdapter(
            child:
                FootNote(
                  iconData: LineIcons.moneyBill,
                  iconColor: Colors.purple,
                  description:
                      'You can tap on insurances to pay insurance for the vehicle  or view its history',
                ).padding(
                  const EdgeInsets.only(
                    top: 10,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabDelegate(child: _buildTabSwitcher(context)),
          ),

          Obx(
            () => SliverToBoxAdapter(
              child: [
                "Date From ${GenesisDate.getInformalShortDate(controller.dateRange.value.start)} - "
                        "${GenesisDate.getInformalShortDate(controller.dateRange.value.end)}"
                    .text(style: TextStyle(color: GTheme.primary(context))),
              ].row(mainAxisAlignment: MainAxisAlignment.center),
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
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "Vehicle Profile",
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Obx(
          () => _statsController.vehicleTripStats.value == null
              ? 0.gapHeight
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
                  icon: _isPrinting.lord(AdaptiveLoader(), Icon(Icons.print)),
                ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () =>
              Get.to(() => AdminEditVehicle(vehicle: widget.vehicle)),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // 2. HEADER INFO (The "Wow" Profile)
  Widget _buildHeaderInfo(BuildContext context) {
    return Container(
      color: GTheme.cardColor(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Avatar with Status Glow
              Stack(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(30),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: widget.vehicle.carModel[0]
                        .toUpperCase()
                        .text(
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        )
                        .center(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.vehicle.status.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicle.carModel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.vehicle.licencePlate,
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _infoChip(
                          Icons.card_travel_outlined,
                          widget.vehicle.fuelRatio.toString(),
                        ),
                        const SizedBox(width: 10),
                        _infoChip(
                          Icons.ev_station,
                          "${widget.vehicle.fuelLevel}% Fuel",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // 3. QUICK ACTION STATS
  Widget _buildQuickActions(BuildContext context) {
    return Obx(() {
      if (_statsController.fetchingUserTripStatus.value) {
        return [
          MaterialLoader(),
        ].row(mainAxisAlignment: MainAxisAlignment.center);
      }
      if (_statsController.fetchingVehicleTripStatsError.value.isNotEmpty ||
          _statsController.vehicleTripStats.value == null) {
        return [
          _statsController.fetchingVehicleTripStatsError.value.text(),
        ].row(mainAxisAlignment: MainAxisAlignment.center);
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statMiniCard(
              "Trips",
              _statsController.vehicleTripStats.value!.totalTrips.toString(),
              Colors.blue,
            ),
            _statMiniCard(
              "Revenue",
              "${NumberUtils.formatCurrency(_statsController.vehicleTripStats.value!.totalRevenue)}",
              Colors.green,
            ),
            _statMiniCard(
              "Maintainances",
              "${NumberUtils.formatCurrency(_statsController.vehicleTripStats.value!.totalMaintenanceCosts)}",
              Colors.orange,
            ).onTap(
              () => Get.to(
                () => MaintenanceHistoryScreen(vehicle: widget.vehicle),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statMiniCard(String label, String value, Color color) {
    return Container(
      width: Get.width * 0.28,
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withAlpha(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dashboard_customize,
                    color: GTheme.primary(context),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vehicle Performance',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                      value:
                          '${NumberUtils.formatNumber(stats.totalMileage)} km',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTotalsCard(
                      title: 'Total Hours',
                      value: '${stats.totalHours} h',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTotalsCard(
                title: 'Estimated Fuel Use',
                value: '${NumberUtils.formatNumber(fuelConsumption)} L',
                color: Colors.green,
                subtitle: ratioText,
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
  }) {
    return Container(
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    );
  }

  // 4. DOCUMENTS (License & Permits)
  Widget _buildDocumentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Documentation",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _docCard(
                "License",
                (widget.vehicle.licence == null
                    ? "No licence"
                    : 'Expires ${GenesisDate.getInformalShortDate(widget.vehicle.licence!.expiryDate)}'),
                Icons.abc,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _docCard(
                "Insurances",
                "${widget.vehicle.insurances.length.toString()} Covers",
                Icons.shield,
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              expiry,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ).onTap(() => ontap?.call()),
    );
  }

  // SERVICE REMINDERS SECTION
  Widget _buildServiceRemindersSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Service Reminders",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Icon(Icons.build, color: statusColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          reminder.type == 'mileage'
                              ? 'Mileage: ${NumberUtils.formatNumber(reminder.mileage)} km'
                              : 'Date: ${reminder.date != null ? GenesisDate.getInformalShortDate(reminder.date!) : 'N/A'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    remainingText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: GTheme.isDark(
                  context,
                ).lord(Colors.grey.withAlpha(30), Colors.grey[200]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () =>
                    Row(children: [_tabBtn(0, "Service"), _tabBtn(1, "Trips")]),
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
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.blueAccent,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null)
                controller.updateDateRange(picked, widget.vehicle.id ?? '');
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GTheme.emmense(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month,
                size: 20,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(int index, String label) {
    bool isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4)]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
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
          child: [
            MaterialLoader(),
          ].row(mainAxisAlignment: MainAxisAlignment.center),
        );
      }
      if (_statsController.fetchingVehicleTripStatsError.value.isNotEmpty ||
          _statsController.vehicleTripStats.value == null) {
        return SliverToBoxAdapter(
          child: [
            _statsController.fetchingVehicleTripStatsError.value.text(),
          ].row(mainAxisAlignment: MainAxisAlignment.center),
        );
      }
      if (isService) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _statsController
                    .vehicleTripStats
                    .value!
                    .maintenances[index];
                return _historyItem(
                  title: item.issueDetails,
                  subtitle: item.urgenceLevel.toUpperCase(),
                  date: "",
                  amount: '-${NumberUtils.formatCurrency(item.estimatedCosts)}',
                  icon: Icons.webhook_rounded,
                  iconColor: Colors.orange,
                );
              },
              childCount:
                  _statsController.vehicleTripStats.value!.maintenances.length,
            ),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item =
                  _statsController.vehicleTripStats.value!.trips[index];
              return _historyItem(
                title:
                    "${item.origin}  ${item.destinations.isNotEmpty ? item.destinations.last.name : item.destination}",
                subtitle: "Payload: ${item.loadWeight} kgs",
                date: item.startTime != null
                    ? GenesisDate.getInformalShortDate(item.startTime!)
                    : '',
                amount: "+${NumberUtils.formatCurrency(item.tripPayout)}",
                icon: Icons.pin_drop,
                iconColor: Colors.green,
              );
            },
            childCount: isService
                ? _statsController.vehicleTripStats.value!.maintenances.length
                : _statsController.vehicleTripStats.value!.trips.length,
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
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "$date • $subtitle",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: amount.startsWith('+') ? Colors.green : Colors.redAccent,
            ),
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
  double get minExtent => 65;
  @override
  double get maxExtent => 65;

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
