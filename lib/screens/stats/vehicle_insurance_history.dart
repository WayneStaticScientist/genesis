import 'package:flutter/material.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/models/insurance_model.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/theme.dart';

// --- Screen Implementation ---

class VehicleInsuranceHistoryScreen extends StatefulWidget {
  const VehicleInsuranceHistoryScreen({super.key});

  @override
  State<VehicleInsuranceHistoryScreen> createState() =>
      _VehicleInsuranceHistoryScreenState();
}

class _VehicleInsuranceHistoryScreenState
    extends State<VehicleInsuranceHistoryScreen> {
  DateTimeRange? _selectedDateRange;
  // Mock Data
  final List<InsuranceModel> _payments = [
    InsuranceModel(
      total: 450.00,
      vehicleId: "V-8829",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      insurances: [
        DeductionItem(
          name: "Full Coverage",
          value: 300,
          deductionType: DeductionType.fixed,
        ),
        DeductionItem(
          name: "Roadside Assist",
          value: 150,
          deductionType: DeductionType.fixed,
        ),
      ],
    ),
    InsuranceModel(
      total: 120.50,
      vehicleId: "V-1102",
      createdAt: DateTime.now().subtract(const Duration(days: 32)),
      insurances: [
        DeductionItem(
          name: "Third Party",
          value: 120.50,
          deductionType: DeductionType.fixed,
        ),
      ],
    ),
  ];

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: GTheme.copyOverlay(context),
        centerTitle: false,
        title: Text(
          'Payment History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: Icon(
              Icons.calendar_month_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeHeader(colorScheme, isDark),
          Expanded(
            child: _payments.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _payments.length,
                    itemBuilder: (context, index) => _buildPaymentCard(
                      _payments[index],
                      colorScheme,
                      isDark,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader(ColorScheme colorScheme, bool isDark) {
    String rangeText = _selectedDateRange == null
        ? "Showing all records"
        : "${GenesisDate.getInformalDate(_selectedDateRange!.start)} - ${GenesisDate.getInformalDate(_selectedDateRange!.end)}";

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.date_range, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Period",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  rangeText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedDateRange != null)
            IconButton(
              onPressed: () => setState(() => _selectedDateRange = null),
              icon: const Icon(Icons.close, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    InsuranceModel payment,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                Icons.receipt_long_rounded,
                color: colorScheme.primary,
              ),
            ),
          ),
          title: Text(
            GenesisDate.getInformalDate(payment.createdAt),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "Vehicle: ${payment.vehicleId}",
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${payment.total.toStringAsFixed(2)}",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(height: 30),
                  ...payment.insurances.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "\$${item.value.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Successfully paid via Wallet",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "No payments found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            "Try selecting a different date range",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
