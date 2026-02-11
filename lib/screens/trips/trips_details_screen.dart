import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/controllers/user_controller.dart'; // Adjust path as necessary

class TripDetailsScreen extends StatefulWidget {
  final String tripId;

  const TripDetailsScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    // Fetch the trip by ID immediately upon entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.findTrip(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Trip Details",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
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
                    _buildSectionTitle(theme, "Load & Vehicle"),
                    SizedBox(height: 10),
                    _buildInfoGrid(trip, theme),
                    SizedBox(height: 20),
                    _buildSectionTitle(theme, "Timeline"),
                    SizedBox(height: 10),
                    _buildTimelineCard(trip, theme, primaryColor),
                    SizedBox(height: 20),
                    _buildLocationDetails(trip, theme),
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
              Text(
                "\$${trip.tripPayout.toStringAsFixed(2)}",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "DESTINATION",
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            trip.destination,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                  trip.startTime != null
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

  Widget _buildLocationDetails(TripModel trip, ThemeData theme) {
    if (trip.location == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, "Current Location"),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blueGrey),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  trip.destination,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
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
        _showActionDialog("Mark trip as succefull ", "finalize");
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
    } else if (status == 'pending') {
      label = "Revoke Trip";
      btnColor = Colors.orange;
      icon = Icons.undo;
      onTap = () {
        _showActionDialog(
          "Are you sure you want revoke the trip , The trip will not be recorded at all",
          "revoke",
        );
      };
    } else {
      return SizedBox.shrink(); // No action for other statuses
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
}
