import 'package:genesis/widgets/loaders/material_loader.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/models/payroll_model.dart';
import 'package:genesis/widgets/layouts/date_stepper.dart';
import 'package:genesis/controllers/payroll_controller.dart';

class PayrollUserHistory extends StatefulWidget {
  final User user;
  const PayrollUserHistory({super.key, required this.user});

  @override
  State<PayrollUserHistory> createState() => _PayrollUserHistoryState();
}

class _PayrollUserHistoryState extends State<PayrollUserHistory> {
  late DateTimeRange _selectedDateRange;
  final _payrollController = Get.find<PayrollController>();

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).primaryColor,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      filterResults();
    }
  }

  @override
  void initState() {
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: 365)),
      end: DateTime.now(),
    );
    filterResults();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payroll History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => _selectDateRange(context),
            tooltip: "Filter by Date",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Summary Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(30),
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.user.firstName} ${widget.user.lastName}",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GenesisDateRangeStepper(
                    startDate: _selectedDateRange.start,
                    endDate: _selectedDateRange.end,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => _buildSummaryItem(
                          context,
                          "Total Net",
                          NumberUtils.formatCurrency(
                            _payrollController.totalNetPayment.value,
                          ),
                          true,
                        ),
                      ),
                      Obx(
                        () => _buildSummaryItem(
                          context,
                          "Records",
                          _payrollController.userPayrollHistory.length
                              .toString(),
                          false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // List Section
            Obx(() {
              if (_payrollController.fetchingUserPayrollHistory.value) {
                return MaterialLoader();
              }
              if (_payrollController.userPayrollHistory.isEmpty) {
                return Text("No payroll records found for this period.");
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _payrollController.userPayrollHistory.length,
                itemBuilder: (context, index) {
                  final item = _payrollController.userPayrollHistory[index];
                  return _PayrollCard(payroll: item);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    bool isPrimary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isPrimary ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }

  void filterResults() {
    _payrollController.fetchUserPayRowHistory(
      _selectedDateRange,
      widget.user.id,
    );
  }
}

class _PayrollCard extends StatelessWidget {
  final PayrollModel payroll;

  const _PayrollCard({required this.payroll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withAlpha(30)),
      ),
      child: ExpansionTile(
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withAlpha(30),
          child: Icon(Icons.payments_outlined, color: theme.primaryColor),
        ),
        title: Text(
          GenesisDate.getInformalDate(payroll.createdAt),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(GenesisDate.getInformalDate(payroll.createdAt)),
        trailing: Text(
          NumberUtils.formatCurrency(payroll.netPayment),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.primaryColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const Divider(),
                _buildDetailRow("Gross Payment", payroll.payment, theme),
                _buildDetailRow(
                  "Tax Deducted",
                  -payroll.tax,
                  theme,
                  isNegative: true,
                ),
                _buildDetailRow(
                  "Insurance",
                  -payroll.insurance,
                  theme,
                  isNegative: true,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(27),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildDetailRow(
                    "Net Amount",
                    payroll.netPayment,
                    theme,
                    isBold: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    double value,
    ThemeData theme, {
    bool isNegative = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor)),
          Text(
            NumberUtils.formatCurrency(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative ? Colors.redAccent : null,
            ),
          ),
        ],
      ),
    );
  }
}
