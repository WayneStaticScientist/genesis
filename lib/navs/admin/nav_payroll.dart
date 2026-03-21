import 'dart:async';
import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:exui/material.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/widgets/layouts/taxes_dialog.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/screens/payroll/payroll_history.dart';
import 'package:genesis/controllers/payroll_controller.dart';
import 'package:genesis/widgets/layouts/employee_dialog.dart';

class AdminNavPayroll extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavPayroll({super.key, this.triggerKey});

  @override
  State<AdminNavPayroll> createState() => _AdminNavPayrollState();
}

class _AdminNavPayrollState extends State<AdminNavPayroll> {
  final _searchController = TextEditingController();
  final _payrollController = Get.find<PayrollController>();
  String _searchKey = '';
  Timer? _debounceTimer;
  @override
  void initState() {
    filterResults();
    super.initState();
    _initDebouncer();
  }

  void filterResults() {
    _payrollController.findEmployees(query: _searchKey, page: 1);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _runPayroll() {
    Get.defaultDialog(
      title: "Payment Procedural",
      content:
          "Confirm with payment of ${NumberUtils.formatCurrency(_payrollController.grossTotal.value)}"
              .text(),
      textCancel: "cancel",
      textConfirm: "proceed",
      onConfirm: () {
        Get.back();
        _payrollController.proceedPayment();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: DrawerButton(
              color: Colors.white,
              onPressed: () {
                widget.triggerKey?.currentState?.openDrawer();
              },
            ),
            expandedHeight: 220,
            actions: [
              "Taxes"
                  .text(style: TextStyle(color: Colors.white))
                  .textIconButton(
                    onPressed: () => _showTaxesDialog(),
                    icon: Icon(Icons.percent, color: Colors.white),
                  ),
              IconButton(
                onPressed: () => Get.to(() => PayrollHistory()),
                icon: Icon(Icons.refresh, color: Colors.white),
              ),
            ],
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.payments,
                        size: 200,
                        color: Colors.white.withAlpha(30),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Payroll Control",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Obx(
                            () =>
                                _payrollController.lastPayrollDetails.value !=
                                    null
                                ? "Last Cycle - ${GenesisDate.getInformalDate(_payrollController.lastPayrollDetails.value!.createdAt)} "
                                      .text(
                                        style: TextStyle(color: Colors.white),
                                      )
                                : 0.gapWidth,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Obx(
                                () => _headerMetric(
                                  "Gross Total",
                                  "${NumberUtils.formatCurrency(_payrollController.grossTotal.value)}",
                                ),
                              ),
                              const SizedBox(width: 16),
                              Obx(
                                () => _headerMetric(
                                  "Staff",
                                  "${_payrollController.employees.length} Active",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Individual Payouts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${GenesisDate.getMonthName(DateTime.now().month)} Cycle",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final emp = _payrollController.employees[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: InkWell(
                    onTap: () => _showEmployeeDialog(emp),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GTheme.surface(context),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                emp.firstName[0],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${emp.firstName} ${emp.lastName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${emp.role.toUpperCase()} - ${NumberUtils.formatCurrency(emp.payment)}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "NET PAYOUT",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                "\$${emp.finalPayment.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: _payrollController.employees.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: FloatingActionButton.extended(
            onPressed: _runPayroll,
            backgroundColor: const Color(0xFF0F172A),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            label: Obx(
              () => _payrollController.paymentProceeding.value
                  ? WhiteLoader()
                  : const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Text(
                          "Process Full Payroll",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerMetric(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeDialog(User emp) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: EmployeeDialog(emp: emp, setDialogState: setDialogState),
          );
        },
      ),
    );
  }

  void _showTaxesDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: TaxesDialog(setDialogState: setDialogState),
          );
        },
      ),
    );
  }

  void _initDebouncer() {
    _debounceTimer = Timer.periodic(Duration(milliseconds: 700), (time) {
      if (_searchController.text != _searchKey) {
        _searchKey = _searchController.text;
        filterResults();
      }
    });
  }
}
