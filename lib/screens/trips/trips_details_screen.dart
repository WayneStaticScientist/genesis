import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:exui/material.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/utils/string_utils.dart';
import 'package:genesis/shared/utils/trip-util.dart';
import 'package:genesis/navs/admin/fleet_tracking.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/controllers/socket_controller.dart';
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
  final _socketController = Get.find<SocketController>();
  bool _isPrinting = false;

  /// Get current destination - first one with reached == false, or last if all are true

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
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Trip Details",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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
                    icon: _isPrinting.lord(AdaptiveLoader(), Icon(Icons.print)),
                  ),
          ),
          Obx(
            () => "track"
                .toUpperCase()
                .text()
                .textButton(
                  onPressed: () {
                    final vehicleId = userController.trip.value?.vehicle.id;
                    if (vehicleId == "" || vehicleId!.isEmpty) {
                      Toaster.showError("Vehicle not found");
                      return;
                    }
                    _socketController.listenId.value = vehicleId;
                    Get.to(() => FleetTrackingScreen());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                )
                .visibleIf(
                  userController.trip.value?.status.toLowerCase() == "active",
                ),
          ),
          Obx(() {
            final trip = userController.trip.value;
            final user = userController.user.value;
            final canAddExpense =
                trip != null &&
                trip.status.toLowerCase() == "active" &&
                user != null &&
                (user.role == 'admin' ||
                    user.role == 'agent' ||
                    (user.role == 'manager' &&
                        user.permissions.contains('trip')));
            return canAddExpense
                ? IconButton(
                    icon: Icon(Icons.add, color: primaryColor),
                    onPressed: () => _showAddExpenseDialog(),
                  )
                : SizedBox.shrink();
          }),
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(trip, theme, primaryColor),
                    SizedBox(height: 20),
                    _buildSectionTitle(theme, "Driver & Info"),
                    SizedBox(height: 10),
                    _buildDriverCard(trip.driver),
                    ListTile(
                      title: "${trip.vehicle.carModel}".text(),
                      subtitle: "Vehicle".text(),
                    ),
                    ListTile(
                      title: "${trip.receiver.empty("Not specified")}".text(),
                      subtitle: "Company Name or Client".text(),
                    ),
                    SizedBox(height: 20),
                    _buildSectionTitle(theme, "Load & Vehicle"),
                    SizedBox(height: 10),
                    _buildInfoGrid(trip, theme),
                    SizedBox(height: 20),
                    if (trip.destinations.isNotEmpty) ...[
                      _buildDestinationsSection(trip, theme, primaryColor),
                      SizedBox(height: 20),
                    ],
                    if (trip.tripType == "Cross-Border") ...[
                      _buildSectionTitle(theme, "Border Information"),
                      SizedBox(height: 10),
                      _buildBorderInfoSection(trip, theme),
                      SizedBox(height: 20),
                    ],
                    _buildSectionTitle(theme, "Timeline"),
                    SizedBox(height: 10),
                    if (trip.startedAt != null && trip.finishedAt != null) ...[
                      _buildRuntimeCard(trip, theme),
                      SizedBox(height: 20),
                    ],
                    _buildTimelineCard(trip, theme, primaryColor),
                    SizedBox(height: 20),
                    _buildSectionTitle(
                      theme,
                      "Expenses (${NumberUtils.formatCurrency(NumberUtils.getTripExpenseTotal(trip))})",
                    ),
                    SizedBox(height: 10),
                    _buildExpenseCard(
                      title: "Tolgate Fees",
                      icon: Icons.gas_meter_outlined,
                      value: trip.tolgateExpense,
                    ),
                    if (trip.tollgates.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildSectionTitle(theme, "Tollgates"),
                      const SizedBox(height: 10),
                      ...trip.tollgates.map(
                        (toll) => _buildExpenseCard(
                          title: toll.name,
                          icon: Icons.toll,
                          value: toll.amount,
                        ),
                      ),
                    ],
                    _buildExpenseCard(
                      title: "Food Expense",
                      icon: Icons.food_bank,
                      value: trip.foodExpense,
                    ),
                    _buildExpenseCard(
                      title: "Fuel Expenses",
                      icon: Icons.gas_meter_outlined,
                      value: trip.fuelExpense,
                    ),
                    _buildExpenseCard(
                      title: "Fines",
                      icon: Icons.ev_station_sharp,
                      value: trip.finesExpense,
                    ),
                    _buildExpenseCard(
                      title: "Truck Stop",
                      icon: Icons.local_shipping_outlined,
                      value: trip.truckShopExpense,
                    ),
                    _buildExpenseCard(
                      title: "Extras",
                      icon: Icons.exposure,
                      value: trip.extrasExpense,
                    ),
                    ...trip.otherExpenses.map(
                      (expense) => _buildExpenseCard(
                        title: expense.name,
                        icon: Icons.attach_money,
                        value: expense.amount,
                      ),
                    ),
                    _buildInitiatorCard(theme, trip.initiater),
                    _buildFinalizerCard(theme, trip.finalizer),
                    if (trip.notes.isNotEmpty) ...[
                      _buildSectionTitle(theme, "Notes"),
                      trip.notes.text(),
                      SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(trip, theme, primaryColor),
          ],
        );
      }),
    );
  }

  // --- Widgets ---

  Widget _buildHeaderCard(TripModel trip, ThemeData theme, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(100),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(trip.status),
              [
                Text(
                  "${NumberUtils.formatCurrency(trip.tripPayout)}",
                  textAlign: TextAlign.end,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "-${NumberUtils.formatCurrency(NumberUtils.getTripExpenseTotal(trip))}",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${NumberUtils.formatCurrency(trip.tripPayout - NumberUtils.getTripExpenseTotal(trip))}",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ].column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            trip.origin,
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          ""
              .plus(
                (trip.distance > 0).lors(
                  "${NumberUtils.formatNumber(trip.distance)}KM",
                  '-',
                ),
              )
              .text(),
          SizedBox(height: 5),
          Text(
            trip.destinations.isNotEmpty
                ? TripUtils.getCurrentDestination(trip)?.name ??
                      trip.destination
                : trip.destination,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        badgeColor = Colors.greenAccent.shade100;
        textColor = Colors.green.shade900;
        break;
      case 'active':
        badgeColor = Colors.blueAccent.shade100;
        textColor = Colors.blue.shade900;
        break;
      case 'pending':
        badgeColor = Colors.orangeAccent.shade100;
        textColor = Colors.orange.shade900;
        break;
      default:
        badgeColor = Colors.white24;
        textColor = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoGrid(TripModel trip, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.inventory_2_outlined,
            label: "Load Type",
            value: trip.loadType,
            theme: theme,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.scale_outlined,
            label: "Weight",
            value: "${trip.loadWeight} kg",
            theme: theme,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.local_shipping_outlined,
            label: "Vehicle",
            value: trip.vehicle.carModel, // Assuming name exists
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationsSection(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    final currentDest = TripUtils.getCurrentDestination(trip);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, "Trip Routes (${trip.destinations.length})"),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trip.destinations.length,
          itemBuilder: (context, index) {
            final dest = trip.destinations[index];
            final isCurrentDest = currentDest?.name == dest.name;
            final isReached = dest.reached;

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentDest
                    ? primaryColor.withAlpha(30)
                    : isReached
                    ? Colors.green.withAlpha(20)
                    : GTheme.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentDest
                      ? primaryColor
                      : isReached
                      ? Colors.green.withAlpha(100)
                      : Colors.grey.withAlpha(50),
                  width: isCurrentDest ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isReached
                              ? Colors.green
                              : (isCurrentDest ? primaryColor : Colors.grey),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isReached
                              ? Icons.check
                              : (isCurrentDest
                                    ? Icons.location_pin
                                    : Icons.location_on_outlined),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Stop ${index + 1}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              dest.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isReached)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(50),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Reached",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (isCurrentDest)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Current",
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (dest.location != null) ...[
                    SizedBox(height: 12),
                    Text(
                      "Coordinates",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "${dest.location!.lat.toStringAsFixed(4)}, ${dest.location!.lng.toStringAsFixed(4)}",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Icon(Icons.circle, size: 12, color: primaryColor),
              Container(height: 30, width: 2, color: Colors.grey.shade300),
              Icon(Icons.circle_outlined, size: 12, color: Colors.grey),
            ],
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeRow(
                  "Start Time",
                  trip.startTime != null
                      ? GenesisDate.getInformalDate(trip.startTime!)
                      : "Not started",
                  theme,
                ),
                _buildTimeRow(
                  "Ended on",
                  trip.endTime != null
                      ? GenesisDate.getInformalDate(trip.endTime!)
                      : "Not started",
                  theme,
                ).visibleIf(trip.endTime != null),
                SizedBox(height: 16),
                _buildTimeRow(
                  "Est. Completion",
                  trip.estimatedEndTime != null
                      ? GenesisDate.getInformalDate(trip.estimatedEndTime!)
                      : "Calculating...",
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuntimeCard(TripModel trip, ThemeData theme) {
    final startedAt = trip.startedAt!;
    final finishedAt = trip.finishedAt!;
    final durationText = _formatDuration(finishedAt.difference(startedAt));

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Driver Runtime",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildTimeRow(
            "Started at",
            GenesisDate.getInformalDate(startedAt),
            theme,
          ),
          SizedBox(height: 12),
          _buildTimeRow(
            "Finished at",
            GenesisDate.getInformalDate(finishedAt),
            theme,
          ),
          SizedBox(height: 12),
          _buildTimeRow("Duration", durationText, theme),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      final minutes = duration.inMinutes % 60;
      return "${days}d ${hours}h ${minutes}m";
    }
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return "${hours}h ${minutes}m";
    }
    if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return "${minutes}m ${seconds}s";
    }
    return "${duration.inSeconds}s";
  }

  Widget _buildTimeRow(String label, String time, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        Text(
          time,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBottomActionBar(
    TripModel trip,
    ThemeData theme,
    Color primaryColor,
  ) {
    String status = trip.status.toLowerCase();

    // Logic based on requirements:
    // "Completed" -> End Trip
    // "Active" -> Cancel Trip
    // "Pending" -> Revoke Trip

    VoidCallback? onTap;
    String label = "";
    Color btnColor = primaryColor;
    IconData icon = Icons.check;

    if (status == 'completed') {
      label = "End Trip";
      icon = Icons.flag;
      onTap = () async {
        _finalizeTripDialog();
      };
    } else if (status == 'active') {
      label = "Cancel Trip";
      btnColor = Colors.redAccent;
      icon = Icons.cancel;
      onTap = () {
        // Implement Cancel Logic
        // userController.cancelTrip(...) // If method exists
        _showActionDialog(
          "Are you sure you want to cancel this trip?",
          "cancel",
        );
      };
    } else if (status == 'agent-assigned') {
      final user = userController.user.value;
      final canClear =
          user != null &&
          (user.role == 'admin' ||
              user.role == 'agent' ||
              (user.role == 'manager' && user.permissions.contains('trip')));

      if (canClear) {
        label = "Clear Trip";
        btnColor = primaryColor;
        icon = Icons.local_shipping;
        onTap = () {
          Get.to(() => TripClearingScreen(trip: trip));
        };
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return SizedBox.shrink(); // No action for other statuses
    }
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: userController.processingTrip.value ? null : onTap,
            icon: userController.processingTrip.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, color: Colors.white),
            label: Text(
              userController.processingTrip.value ? "Processing..." : label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionDialog(String s, String t) {
    Get.defaultDialog(
      title: "Action",
      content: s.text(),
      textCancel: "cancel",
      textConfirm: "confirm",
      onConfirm: () async {
        Get.back();
        final status = await userController.finalizeTrip(
          tripId: widget.tripId,
          tripAction: t,
        );
        if (status) {
          if (t == "revoke") {
            Get.back();
          }
          Toaster.showSuccess2("Trip Action", "Operation was succesfull");
        }
      },
    );
  }

  _buildDriverCard(dynamic driver) {
    if (driver == null || driver.runtimeType == String) {
      return "".text().center();
    }
    return ListTile(
      title: "${driver['firstName'] ?? 'N/A'} ${driver['lastName'] ?? 'N/A'}"
          .text(),
      subtitle: "${driver['email'] ?? "N/A"}".text(),
    );
  }

  _buildInitiatorCard(ThemeData theme, dynamic user) {
    if (user == null || user.runtimeType == String) {
      return "".text().center();
    }
    return [
      Divider(color: Colors.grey.withAlpha(50)),

      _buildSectionTitle(theme, "Trip starter"),

      ListTile(
        title: "${user['firstName'] ?? 'N/A'} ${user['lastName'] ?? 'N/A'}"
            .text(),
        subtitle: "${user['email'] ?? "N/A"}".text(),
      ),
    ].column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  _buildFinalizerCard(ThemeData theme, dynamic user) {
    if (user == null || user.runtimeType == String) {
      return "".text().center();
    }
    return [
      Divider(color: Colors.grey.withAlpha(50)),

      _buildSectionTitle(theme, "Trip Finalizer"),

      ListTile(
        title: "${user['firstName'] ?? 'N/A'} ${user['lastName'] ?? 'N/A'}"
            .text(),
        subtitle: "${user['email'] ?? "N/A"}".text(),
      ),
    ].column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  void _finalizeTripDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
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
        title: Text("Add Extra Trip Cost"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Expense Name"),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
          TextButton(
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
              Get.back();
              final success = await userController.addOtherExpense(
                tripId: widget.tripId,
                name: name,
                amount: amount,
              );
              if (success) {
                Toaster.showSuccess("Expense added successfully");
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  _buildExpenseCard({
    required String title,
    required IconData icon,
    required double value,
  }) {
    return ListTile(
      title: title.text(style: TextStyle(fontSize: 12)),
      leading: Icon(icon),
      subtitle: NumberUtils.formatCurrency(value).text(),
    );
  }

  Widget _buildBorderInfoSection(TripModel trip, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.exit_to_app,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Port of Exit",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      trip.portOfExit ?? "Not specified",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.login, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Port of Entry",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      trip.portOfEntry ?? "Not specified",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
}
