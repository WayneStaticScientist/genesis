import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/bool_utils.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:genesis/models/maintainance_model.dart';
import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:genesis/controllers/maintainance_controller.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const MaintenanceHistoryScreen({super.key, required this.vehicle});

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  DateTimeRange? _selectedDateRange;
  final _maintainaceController = Get.find<MaintainanceController>();
  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _filterRecords();
  }

  void _filterRecords() {
    _maintainaceController.findMaintainanceForVehicle(
      widget.vehicle.id ?? '',
      _selectedDateRange!,
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              primary: Colors.blue.shade700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _filterRecords();
    }
  }

  double _calculateTotalCost() {
    return _maintainaceController.maintainancesForVehicle.fold(
      0,
      (sum, item) => item.status == "Approved" ? sum + item.estimatedCosts : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Maintenance History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${widget.vehicle.carModel} • ${widget.vehicle.licencePlate}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDateRange,
            tooltip: "Select Date Range",
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Range & Summary Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Current Period",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _selectDateRange,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Filter"),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: Colors.grey.withAlpha(50)),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        "Total Logs",
                        _maintainaceController.maintainancesForVehicle.length
                            .toString(),
                        Icons.history,
                      ),
                      _buildSummaryItem(
                        "Total Cost",
                        currencyFormat.format(_calculateTotalCost()),
                        Icons.account_balance_wallet,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Expanded(
              child: _maintainaceController.findingMaintainancesForVehicle.value
                  .lord(
                    MaterialLoader().center(),
                    _maintainaceController.maintainancesForVehicle.isEmpty.lord(
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.build_circle_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No maintenance records found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _maintainaceController
                            .maintainancesForVehicle
                            .length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final record = _maintainaceController
                              .maintainancesForVehicle[index];
                          return _MaintenanceCard(
                            record: record,
                            currencyFormat: currencyFormat,
                            dateFormat: dateFormat,
                          );
                        },
                      ),
                    ),
                  ),
            ),
          ),
          // Records List
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintainanceModel record;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;

  const _MaintenanceCard({
    required this.record,
    required this.currencyFormat,
    required this.dateFormat,
  });

  Color _getUrgencyColor() {
    switch (record.urgenceLevel.toLowerCase()) {
      case 'high':
      case 'urgent':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor().withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    record.urgenceLevel.toUpperCase(),
                    style: TextStyle(
                      color: _getUrgencyColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(record.dueDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record.issueDetails.length > 30
                  ? "${record.issueDetails.substring(0, 30)}..."
                  : record.issueDetails,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text("Health: ${(record.currentHealth).toStringAsFixed(0)}%"),
                const Spacer(),
                Text(
                  currencyFormat.format(record.estimatedCosts),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: Colors.grey.withAlpha(50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(
                        Icons.person,
                        size: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Status: ${record.status}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
