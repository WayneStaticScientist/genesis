import 'package:flutter/material.dart';
import 'package:genesis/models/deducton_item.dart';

class Employee {
  final int id;
  final String name;
  final String role;
  final double salary;
  final String avatar;
  double taxRate;
  double insuranceRate;
  List<DeductionItem> taxes;
  List<DeductionItem> insurance;
  List<PaymentRecord> history;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.salary,
    required this.taxes,
    required this.insurance,
    required this.avatar,
    this.taxRate = 10.0,
    this.insuranceRate = 3.0,
    required this.history,
  });

  double get netPay {
    double deductions =
        (salary * (taxRate / 100)) + (salary * (insuranceRate / 100));
    return salary - deductions;
  }
}

class PaymentRecord {
  final String date;
  final double amount;

  PaymentRecord({required this.date, required this.amount});
}

class AdminNavPayroll extends StatefulWidget {
  final GlobalKey<ScaffoldState>? triggerKey;
  const AdminNavPayroll({super.key, this.triggerKey});

  @override
  State<AdminNavPayroll> createState() => _AdminNavPayrollState();
}

class _AdminNavPayrollState extends State<AdminNavPayroll> {
  final List<Employee> _employees = [
    Employee(
      id: 1,
      taxes: [
        DeductionItem(
          name: "Federal Tax",
          value: 12,
          type: DeductionType.percentage,
        ),
      ],
      insurance: [
        DeductionItem(
          name: "Health Plan",
          value: 250,
          type: DeductionType.fixed,
        ),
      ],

      name: "Sarah Jenkins",
      role: "Product Designer",
      salary: 8500,
      avatar: "SJ",
      taxRate: 12,
      insuranceRate: 4,
      history: [PaymentRecord(date: "Dec 28, 2023", amount: 7140)],
    ),
    Employee(
      id: 2,
      taxes: [
        DeductionItem(
          name: "Federal Tax",
          value: 12,
          type: DeductionType.percentage,
        ),
      ],
      insurance: [
        DeductionItem(
          name: "Health Plan",
          value: 250,
          type: DeductionType.fixed,
        ),
      ],

      name: "Marcus Chen",
      role: "Sr. Engineer",
      salary: 12000,
      avatar: "MC",
      taxRate: 15,
      insuranceRate: 5,
      history: [PaymentRecord(date: "Dec 28, 2023", amount: 9600)],
    ),
    Employee(
      taxes: [
        DeductionItem(
          name: "Federal Tax",
          value: 12,
          type: DeductionType.percentage,
        ),
      ],
      insurance: [
        DeductionItem(
          name: "Health Plan",
          value: 250,
          type: DeductionType.fixed,
        ),
      ],

      id: 3,
      name: "Elena Rodriguez",
      role: "HR Lead",
      salary: 7200,
      avatar: "ER",
      history: [],
    ),
    Employee(
      id: 4,
      taxes: [
        DeductionItem(
          name: "Federal Tax",
          value: 12,
          type: DeductionType.percentage,
        ),
      ],
      insurance: [
        DeductionItem(
          name: "Health Plan",
          value: 250,
          type: DeductionType.fixed,
        ),
      ],

      name: "David Kim",
      role: "Marketing",
      salary: 6500,
      avatar: "DK",
      taxRate: 8,
      insuranceRate: 2,
      history: [],
    ),
  ];

  void _runPayroll() {
    setState(() {
      for (var emp in _employees) {
        emp.history.insert(
          0,
          PaymentRecord(date: "Jan 30, 2024", amount: emp.netPay),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "Payroll Processed Successfully!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalGross = _employees.fold(0, (sum, item) => sum + item.salary);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _headerMetric(
                                "Gross Total",
                                "\$${totalGross.toInt()}",
                              ),
                              const SizedBox(width: 16),
                              _headerMetric(
                                "Staff",
                                "${_employees.length} Active",
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
                      "Jan Cycle",
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
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final emp = _employees[index];
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
                      color: Colors.white,
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
                              emp.avatar,
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
                                emp.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                emp.role.toUpperCase(),
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
                              "\$${emp.netPay.toStringAsFixed(0)}",
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
            }, childCount: _employees.length),
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
            label: const Row(
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

  void _showEmployeeDialog(Employee emp) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF0F172A),
                          child: Text(
                            emp.avatar,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emp.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                emp.role,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    _sectionHeader("Taxes", Icons.account_balance, () {
                      _addDeduction(emp, emp.taxes, setDialogState);
                    }),
                    ...emp.taxes.map(
                      (t) => _deductionTile(t, () {
                        setDialogState(() => emp.taxes.remove(t));
                        setState(() {}); // Update the main dashboard net pay
                      }),
                    ),

                    const SizedBox(height: 20),
                    _sectionHeader("Insurance", Icons.security, () {
                      _addDeduction(emp, emp.insurance, setDialogState);
                    }),
                    ...emp.insurance.map(
                      (i) => _deductionTile(i, () {
                        setDialogState(() => emp.insurance.remove(i));
                        setState(() {}); // Update the main dashboard net pay
                      }),
                    ),

                    const Divider(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Calculated Net:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${emp.netPay.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addDeduction(
    Employee emp,
    List<DeductionItem> list,
    Function setDialogState,
  ) {
    final nameController = TextEditingController();
    final valController = TextEditingController();
    DeductionType selectedType = DeductionType.percentage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text("New Deduction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name (e.g. VAT)"),
              ),
              TextField(
                controller: valController,
                decoration: const InputDecoration(labelText: "Value"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              SegmentedButton<DeductionType>(
                segments: const [
                  ButtonSegment(
                    value: DeductionType.percentage,
                    label: Text("%"),
                  ),
                  ButtonSegment(value: DeductionType.fixed, label: Text("\$")),
                ],
                selected: {selectedType},
                onSelectionChanged: (set) =>
                    setInnerState(() => selectedType = set.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setDialogState(() {
                  list.add(
                    DeductionItem(
                      name: nameController.text,
                      value: double.tryParse(valController.text) ?? 0,
                      type: selectedType,
                    ),
                  );
                });
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(
            Icons.add_circle_outline,
            color: Colors.blue,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _deductionTile(DeductionItem item, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(item.name, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            item.type == DeductionType.percentage
                ? "${item.value}%"
                : "\$${item.value}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.remove_circle,
              color: Colors.redAccent,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
