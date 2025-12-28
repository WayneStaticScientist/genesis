import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AdminNavReports extends StatefulWidget {
  const AdminNavReports({super.key});

  @override
  State<AdminNavReports> createState() => _AdminNavReportsState();
}

class _AdminNavReportsState extends State<AdminNavReports> {
  // Mock Report Data
  final List<Map<String, dynamic>> reportCategories = [
    {
      "title": "Fuel Analysis",
      "subtitle": "Efficiency and consumption trends",
      "icon": LineIcons.gasPump,
      "color": Colors.orange,
      "trend": "+2.4%",
      "isPositive": false,
    },
    {
      "title": "Fleet Utilization",
      "subtitle": "Active vs Idle asset hours",
      "icon": LineIcons.pieChart,
      "color": Colors.blue,
      "trend": "+12.1%",
      "isPositive": true,
    },
    {
      "title": "Maintenance Costs",
      "subtitle": "Monthly repair & service spend",
      "icon": LineIcons.moneyBill,
      "color": Colors.green,
      "trend": "-5.2%",
      "isPositive": true,
    },
    {
      "title": "Incident Reports",
      "subtitle": "Safety violations and accidents",
      "icon": LineIcons.exclamationTriangle,
      "color": Colors.red,
      "trend": "0.0%",
      "isPositive": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // === ANALYTICAL HEADER ===
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
              "Fleet Intelligence",
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
                  child: Icon(
                    LineIcons.barChartAlt,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // === KEY METRICS GRID ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Monthly Overview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryCard(
                      "Total Spend",
                      "\$42,850",
                      LineIcons.wallet,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                      "Avg. Health",
                      "92%",
                      LineIcons.heartbeat,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // === REPORT CATEGORIES LIST ===
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildReportCategoryCard(reportCategories[index]),
              childCount: reportCategories.length,
            ),
          ),
        ),

        // === RECENT DOWNLOADS SECTION ===
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recent Generations",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildRecentReportItem(
                  "Q4_Fleet_Efficiency.pdf",
                  "Generated 2 hours ago",
                ),
                _buildRecentReportItem(
                  "Annual_Fuel_Tax_Log.xlsx",
                  "Generated Yesterday",
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ).expanded1;
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
