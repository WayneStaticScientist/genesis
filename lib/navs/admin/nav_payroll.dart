import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AdminNavPayroll extends StatefulWidget {
  const AdminNavPayroll({super.key});

  @override
  State<AdminNavPayroll> createState() => _AdminNavPayrollState();
}

class _AdminNavPayrollState extends State<AdminNavPayroll> {
  // Mock Payroll Data
  final List<Map<String, dynamic>> payrollCategories = [
    {
      "title": "Base Salaries",
      "subtitle": "Fixed monthly employee compensation",
      "icon": LineIcons.wallet,
      "color": Colors.blue,
      "trend": "+1.2%",
      "isPositive": false, // Increased cost is usually marked red in accounting
    },
    {
      "title": "Overtime & Bonuses",
      "subtitle": "Performance-based additions",
      "icon": LineIcons.handHoldingUsDollar,
      "color": Colors.green,
      "trend": "+18.4%",
      "isPositive": false,
    },
    {
      "title": "Tax Deductions",
      "subtitle": "Government & statutory withholdings",
      "icon": LineIcons.fileInvoiceWithUsDollar,
      "color": Colors.orange,
      "trend": "-2.1%",
      "isPositive": true,
    },
    {
      "title": "Benefits & Insurance",
      "subtitle": "Health, dental, and life coverage",
      "icon": LineIcons.heartbeat,
      "color": Colors.red,
      "trend": "+0.5%",
      "isPositive": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // === PAYROLL COMMAND HEADER ===
        SliverAppBar(
          expandedHeight: 180,
          floating: true,
          pinned: true,
          elevation: 0,
          backgroundColor: const Color(0xFF1E293B),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            title: const Text(
              "Payroll Control",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(LineIcons.coins, size: 150, color: Colors.white),
                ),
              ),
            ),
          ),
        ),

        // === PAYROLL SUMMARY METRICS ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Monthly Payout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "Next: Jan 30",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryCard(
                      "Gross Total",
                      "\$124,500",
                      LineIcons.fileInvoiceWithUsDollar,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                      "Employees",
                      "42 Active",
                      LineIcons.users,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // === PAYROLL CATEGORIES LIST ===
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildReportCategoryCard(payrollCategories[index]),
              childCount: payrollCategories.length,
            ),
          ),
        ),

        // === RECENT PAYSLIPS / SETTLEMENTS ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recent Settlements",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildRecentReportItem(
                  "December_Full_Payroll.pdf",
                  "Processed Dec 28, 2023",
                ),
                _buildRecentReportItem(
                  "Staff_Bonus_Batch_B.xlsx",
                  "Processed Dec 24, 2023",
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
    //   floatingActionButton: FloatingActionButton.extended(
    //     onPressed: () {},
    //     backgroundColor: Colors.blue.shade800,
    //     icon: const Icon(LineIcons.checkCircle, color: Colors.white),
    //     label: const Text(
    //       "Run Payroll",
    //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    //     ),
    //   ),
    // );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCategoryCard(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: report['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(report['icon'], color: report['color']),
        ),
        title: Text(
          report['title'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report['subtitle'],
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(LineIcons.angleRight, size: 16, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              report['trend'],
              style: TextStyle(
                color: report['isPositive'] ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildRecentReportItem(String name, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LineIcons.fileAlt, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const Icon(LineIcons.download, size: 18, color: Colors.blue),
        ],
      ),
    );
  }
}
