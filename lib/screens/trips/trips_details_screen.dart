import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/utils/string_utils.dart';
import 'package:genesis/shared/utils/trip-util.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/utils/pdf_marker/genesis_printer.dart';
import 'package:genesis/screens/trips/trip_clearing_screen.dart';
import 'package:genesis/widgets/layouts/finalize_trip_dialog.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;

  const TripDetailsScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final UserController userController = Get.find<UserController>();
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.findTrip(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: GTheme.color(context),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: GTheme.reverse(context)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Trip Management",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: GTheme.reverse(context),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Obx(
            () => userController.trip.value == null
                ? 0.gapHeight
                : IconButton(
                    onPressed: () async {
                      if (_isPrinting) return;
                      setState(() {
                        _isPrinting = true;
                      });
                      await GenisisPrinter.PrintTrip(
                        userController.trip.value!,
                      );
                      setState(() {
                        _isPrinting = false;
                      });
                    },
                    icon: _isPrinting.lord(
                      AdaptiveLoader(),
                      Icon(Icons.print, color: GTheme.reverse(context)),
                    ),
                  ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: GTheme.reverse(context)),
            onPressed: () => userController.findTrip(widget.tripId),
          ),
        ],
      ),
      body: Obx(() {
        if (userController.fetchingTrip.value) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final trip = userController.trip.value;

        if (trip == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trip_origin_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("Trip not found", style: theme.textTheme.bodyLarge),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModernHeader(trip, theme, primaryColor),
                    const SizedBox(height: 24),

                    _buildModernInfoSection(trip, theme),
                    const SizedBox(height: 24),

                    _buildModernEntityCard(
                      title: "Pilot & Logistics",
                      content: Column(
                        children: [
                          _buildModernDriverRow(trip.driver),
                          const Divider(height: 24),
                          _buildModernInfoRow(
                            icon: Icons.local_shipping_outlined,
                            label: "Vehicle",
                            value: trip.vehicle.carModel,
                            onTap: () {
                              // Maybe navigate to vehicle details
                            },
                          ),
                          _buildModernInfoRow(
                            icon: Icons.business_outlined,
                            label: "Client / Receiver",
                            value: trip.receiver.empty("Not specified"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (trip.destinations.isNotEmpty) ...[
                      _buildModernDestinations(trip, theme, primaryColor),
                      const SizedBox(height: 24),
                    ],

                    if (trip.tripType == "Cross-Border") ...[
                      _buildModernEntityCard(
                        title: "Customs & Border",
                        content: _buildBorderInfoSection(trip, theme),
                      ),
                      const SizedBox(height: 24),
                    ],

                    _buildModernEntityCard(
                      title: "Timeline & Runtime",
                      content: Column(
                        children: [
                          if (trip.startedAt != null &&
                              trip.finishedAt != null) ...[
                            _buildRuntimeCard(trip, theme),
                            const Divider(height: 24),
                          ],
                          _buildTimelineDetails(trip, theme, primaryColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildModernExpenses(trip, theme, primaryColor),
                    const SizedBox(height: 24),

                    _buildModernEntityCard(
                      title: "Administration",
                      content: Column(
                        children: [
                          _buildAdminRow("Trip Initiator", trip.initiater),
                          if (trip.finalizer != null) ...[
                            const Divider(height: 16),
                            _buildAdminRow("Trip Finalizer", trip.finalizer),
                          ],
                          if (trip.notes.isNotEmpty) ...[
                            const Divider(height: 16),
                            _buildModernInfoRow(
                              icon: Icons.note_alt_outlined,
                              label: "Admin Notes",
                              value: trip.notes,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFuelAnalytics(trip, theme, primaryColor),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildModernBottomActions(trip, theme, primaryColor),
          ],
        );
      }),
    );
  }

  Widget _buildRuntimeCard(TripModel trip, ThemeData theme) {
    final startedAt = trip.startedAt!;
    final finishedAt = trip.finishedAt!;
    final durationText = _formatDuration(finishedAt.difference(startedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Driver Runtime",
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        _buildTimeRow(
          "Started at",
          GenesisDate.getInformalDate(startedAt),
          theme,
        ),
        const SizedBox(height: 8),
        _buildTimeRow(
          "Finished at",
          GenesisDate.getInformalDate(finishedAt),
          theme,
        ),
        const SizedBox(height: 8),
        _buildTimeRow("Duration", durationText, theme),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return "${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m";
    }
    if (duration.inHours > 0) {
      return "${duration.inHours}h ${duration.inMinutes % 60}m";
    }
    return "${duration.inMinutes}m ${duration.inSeconds % 60}s";
  }

  Map<String, dynamic> _calculateDetailedFuel(TripModel trip) {
    final vehicle = trip.vehicle;
    double totalConsumption = 0;
    List<Map<String, dynamic>> destinationConsumptions = [];

    double currentLoad = trip.loadWeight;
    double fullLoad = vehicle.fullLoad > 0 ? vehicle.fullLoad : trip.loadWeight;

    for (var dest in trip.destinations) {
      double legDistance = dest.distance;
      double ratio = 0;

      if (vehicle.loadedFuelRatio > 0 && vehicle.emptyRatio > 0) {
        double loadFactor = fullLoad > 0 ? (currentLoad / fullLoad) : 0;
        if (loadFactor > 1.0) loadFactor = 1.0;
        ratio =
            vehicle.emptyRatio +
            (loadFactor * (vehicle.loadedFuelRatio - vehicle.emptyRatio));
      } else {
        ratio = vehicle.fuelRatio;
      }

      double legConsumption = legDistance * ratio;
      totalConsumption += legConsumption;

      destinationConsumptions.add({
        'name': dest.name,
        'consumption': legConsumption,
        'load': currentLoad,
        'ratio': ratio,
        'distance': legDistance,
      });

      currentLoad -= dest.offloadWeight;
      if (currentLoad < 0) currentLoad = 0;
    }

    return {'total': totalConsumption, 'destinations': destinationConsumptions};
  }

  Widget _buildTimeRow(String label, String time, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  // --- Modern Widgets ---

  Widget _buildModernHeader(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withBlue(255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(80),
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
              _buildModernStatusBadge(trip.status),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberUtils.formatCurrency(trip.tripPayout),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "NET: ${NumberUtils.formatCurrency(trip.tripPayout - NumberUtils.getTripExpenseTotal(trip))}",
                    style: const TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ORIGIN",
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    trip.origin,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward,
                color: Colors.white.withAlpha(100),
                size: 16,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "DESTINATION",
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    trip.destinations.isNotEmpty
                        ? TripUtils.getCurrentDestination(trip)?.name ??
                              trip.destination
                        : trip.destination,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: trip.status.toLowerCase() == 'finalized' ? 1.0 : 0.6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Distance: ${NumberUtils.formatNumber(trip.distance)} KM",
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 11,
                ),
              ),
              Text(
                trip.tripType,
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.orange;
        break;
      case 'finalized':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.grey;
        break;
      default:
        color = Colors.deepPurple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoSection(TripModel trip, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.inventory_2_outlined,
            label: "Load",
            value: trip.loadType,
            subValue: "${trip.loadWeight} kg",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.local_gas_station_outlined,
            label: "Fuel",
            value: "${trip.startFuelLevel?.toInt()}%",
            subValue: "Initial Level",
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          if (subValue != null)
            Text(
              subValue,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildModernEntityCard({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GTheme.surface(context),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildModernDriverRow(dynamic driver) {
    if (driver == null || driver is String) return const SizedBox.shrink();
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
          child: Text(
            driver['firstName']?[0] ?? '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${driver['firstName']} ${driver['lastName']}",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                driver['email'] ?? "No email",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chat_bubble_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            // Chat logic
          },
        ),
      ],
    );
  }

  Widget _buildModernInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: Colors.grey[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDestinations(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    final fuelData = _calculateDetailedFuel(trip);
    final destConsumptions =
        fuelData['destinations'] as List<Map<String, dynamic>>;

    return _buildModernEntityCard(
      title: "Navigation Log",
      content: Column(
        children: List.generate(trip.destinations.length, (index) {
          final dest = trip.destinations[index];
          final isReached = dest.reached;
          final fuel = destConsumptions[index]['consumption'] as double;
          final fromLoc = index == 0 ? trip.origin : trip.destinations[index - 1].name;
          
          String durationStr = "";
          if (isReached && dest.reachedAt != null) {
             DateTime startTime = index == 0 
                ? (trip.startedAt ?? dest.reachedAt!) 
                : (trip.destinations[index - 1].reachedAt ?? dest.reachedAt!);
             Duration diff = dest.reachedAt!.difference(startTime);
             if (diff.inMinutes > 0) {
               durationStr = " • Duration: ${_formatDuration(diff)}";
             }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isReached ? Colors.green : primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    if (index != trip.destinations.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey.withAlpha(50),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Route Segment ${index + 1}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "From $fromLoc to ${dest.name}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: isReached
                              ? TextDecoration.lineThrough
                              : null,
                          color: isReached ? Colors.grey : null,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          List<String> details = [];
                          if (dest.distance > 0) {
                            details.add("${dest.distance} km");
                            details.add("Fuel: ${fuel.toStringAsFixed(1)}L");
                          }
                          details.add("Revenue: ${NumberUtils.formatCurrency(dest.revenue)}");
                          String text = details.join(" • ") + durationStr;
                          return Text(
                            text,
                            style: TextStyle(
                              color: primaryColor.withAlpha(180),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (isReached)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFuelAnalytics(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    final fuelData = _calculateDetailedFuel(trip);
    final total = fuelData['total'] as double;

    return _buildModernEntityCard(
      title: "Fuel Consumption Est.",
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Estimated Fuel",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text(
                "${total.toStringAsFixed(1)} Liters",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDetails(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Column(
      children: [
        _buildModernInfoRow(
          icon: Icons.play_circle_outline,
          label: "Started On",
          value: trip.startTime != null
              ? GenesisDate.getInformalDate(trip.startTime!)
              : "Pending",
        ),
        _buildModernInfoRow(
          icon: Icons.flag_outlined,
          label: "Estimated Completion",
          value: trip.estimatedEndTime != null
              ? GenesisDate.getInformalDate(trip.estimatedEndTime!)
              : "Calculating...",
        ),
        if (trip.endTime != null)
          _buildModernInfoRow(
            icon: Icons.check_circle_outline,
            label: "Finished On",
            value: GenesisDate.getInformalDate(trip.endTime!),
          ),
      ],
    );
  }

  Widget _buildModernExpenses(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    final total = NumberUtils.getTripExpenseTotal(trip);
    return _buildModernEntityCard(
      title: "Financial Ledger",
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Expenses",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              Text(
                NumberUtils.formatCurrency(total),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildExpenseRow(
            "Tollgates",
            trip.tolgateExpense +
                trip.tollgates.fold(0.0, (p, e) => p + e.amount),
          ),
          _buildExpenseRow("Fuel", trip.fuelExpense),
          _buildExpenseRow("Truck Shop", trip.truckShopExpense),
          _buildExpenseRow("Fines", trip.finesExpense),
          _buildExpenseRow("Food Expense", trip.foodExpense),
          _buildExpenseRow(
            "Other",
            trip.extrasExpense +
                trip.otherExpenses.fold(0.0, (p, e) => p + e.amount),
          ),
          const SizedBox(height: 16),
          if (trip.status.toLowerCase() == 'active')
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _showAddExpenseDialog,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  "Add New Expense",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  backgroundColor: primaryColor.withAlpha(20),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(String label, double amount) {
    if (amount <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            NumberUtils.formatCurrency(amount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminRow(String label, dynamic user) {
    if (user == null || user is String) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(
          Icons.admin_panel_settings_outlined,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              children: [
                TextSpan(text: "$label: "),
                TextSpan(
                  text: "${user['firstName']} ${user['lastName']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: GTheme.reverse(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernBottomActions(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    final status = trip.status.toLowerCase();
    final user = userController.user.value;
    final isAdmin = user?.role == 'admin' || user?.role == 'manager';

    if (status == 'finalized' || status == 'cancelled')
      return const SizedBox.shrink();

    List<Widget> actions = [];

    if (status == 'active' && isAdmin) {
      actions.add(
        Expanded(
          child: _buildActionButton(
            label: "Complete",
            color: Colors.orange,
            icon: Icons.check_circle_outline,
            onTap: () async {
              final confirm = await _showConfirmDialog(
                "Mark Trip as Completed",
                "This will notify the driver that the trip has reached its destination. Proceed?",
              );
              if (confirm) {
                userController.completeTripAdmin(trip.id);
              }
            },
          ),
        ),
      );
      actions.add(const SizedBox(width: 12));
      actions.add(
        Expanded(
          child: _buildActionButton(
            label: "Cancel",
            color: Colors.redAccent,
            icon: Icons.cancel_outlined,
            onTap: () => _showActionDialog(
              "Are you sure you want to cancel this trip?",
              "cancel",
            ),
          ),
        ),
      );
    } else if (status == 'completed' && isAdmin) {
      actions.add(
        Expanded(
          child: _buildActionButton(
            label: "Finalize Trip",
            color: Colors.green,
            icon: Icons.flag,
            onTap: _finalizeTripDialog,
          ),
        ),
      );
    } else if (status == 'agent-assigned' && isAdmin) {
      actions.add(
        Expanded(
          child: _buildActionButton(
            label: "Clear Trip",
            color: primaryColor,
            icon: Icons.local_shipping,
            onTap: () => Get.to(() => TripClearingScreen(trip: trip)),
          ),
        ),
      );
    } else if (status == 'pending' && isAdmin) {
      actions.add(
        Expanded(
          child: _buildActionButton(
            label: "Initiate",
            color: Colors.blue,
            icon: Icons.play_arrow_outlined,
            onTap: () => _showActionDialog(
              "Initiate this trip manually? This will mark it as active.",
              "initiate",
            ),
          ),
        ),
      );
      actions.add(const SizedBox(width: 12));
      actions.add(
        Expanded(
          child: _buildActionButton(
            label: "Revoke",
            color: Colors.redAccent,
            icon: Icons.delete_forever_outlined,
            onTap: () => _showActionDialog(
              "Are you sure you want to revoke/delete this trip?",
              "revoke",
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(children: actions),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: userController.processingTrip.value ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      icon: userController.processingTrip.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Confirm",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showActionDialog(String s, String t) {
    Get.defaultDialog(
      title: "Trip Action",
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(s, textAlign: TextAlign.center),
      ),
      textCancel: "Cancel",
      textConfirm: "Confirm",
      confirmTextColor: Colors.white,
      buttonColor: Theme.of(context).colorScheme.primary,
      onConfirm: () async {
        Get.back();
        final success = await userController.finalizeTrip(
          tripId: widget.tripId,
          tripAction: t,
        );
        if (success) {
          if (t == "revoke") Get.back();
          Toaster.showSuccess("Operation successful");
        }
      },
    );
  }

  void _finalizeTripDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          content: FinalizeTripDialog(
            trip: userController.trip.value!,
            setDialogState: setInnerState,
          ),
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Add Extra Trip Cost",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Expense Name",
                hintText: "e.g. Extra Fuel",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "\$ ",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final amountText = amountController.text.trim();
              if (name.isEmpty || amountText.isEmpty) {
                Toaster.showError("Please fill both fields");
                return;
              }
              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                Toaster.showError("Invalid amount");
                return;
              }
              Navigator.pop(context);
              final success = await userController.addOtherExpense(
                tripId: widget.tripId,
                name: name,
                amount: amount,
              );
              if (success) {
                Toaster.showSuccess("Expense added successfully");
              }
            },
            child: const Text("Add Expense"),
          ),
        ],
      ),
    );
  }

  Widget _buildBorderInfoSection(TripModel trip, ThemeData theme) {
    return Column(
      children: [
        _buildModernInfoRow(
          icon: Icons.exit_to_app,
          label: "Port of Exit",
          value: trip.portOfExit ?? "Not specified",
        ),
        const Divider(height: 16),
        _buildModernInfoRow(
          icon: Icons.login,
          label: "Port of Entry",
          value: trip.portOfEntry ?? "Not specified",
        ),
      ],
    );
  }
}
