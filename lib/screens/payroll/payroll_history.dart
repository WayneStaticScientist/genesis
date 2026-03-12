import 'package:flutter/material.dart';
import 'package:genesis/controllers/payroll_controller.dart';
import 'package:genesis/models/payroll_details.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/widgets/layouts/date_stepper.dart';
import 'package:get/get.dart';

class PayrollHistory extends StatefulWidget {
  const PayrollHistory({super.key});

  @override
  State<PayrollHistory> createState() => _PayrollHistoryState();
}

class _PayrollHistoryState extends State<PayrollHistory> {
  final _payrollController = Get.find<PayrollController>();

  late DateTimeRange _selectedRange;
  List<PayrollDetails> _filteredPayroll = [];

  @override
  void initState() {
    super.initState();
    _selectedRange = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: 365)),
      end: DateTime.now(),
    );
    filterResults();
  }

  void _filterData(DateTimeRange? range) {}
  double get _totalGross =>
      _filteredPayroll.fold(0, (sum, item) => sum + item.grossTotal);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payroll History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: colorScheme.primary),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedRange,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(colorScheme: colorScheme),
                    child: child!,
                  );
                },
              );
              if (range != null) _filterData(range);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(100),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenesisDateRangeStepper(
                    startDate: _selectedRange.start,
                    endDate: _selectedRange.end,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Gross",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            NumberUtils.formatCurrency(_totalGross),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Active Records",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${_filteredPayroll.length}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _filteredPayroll.isEmpty
                ? Text("No payroll data found for this period.")
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPayroll.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _filteredPayroll[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.primary.withAlpha(
                                  30,
                                ),
                                child: Icon(
                                  Icons.payments_outlined,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      GenesisDate.formatNormalDate(
                                        item.createdAt,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${item.totalEmployees} Employees",
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                NumberUtils.formatCurrency(item.grossTotal),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void filterResults() {
    _payrollController.fetchPayRowHistory(_selectedRange);
  }
}
