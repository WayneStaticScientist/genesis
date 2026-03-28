import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/models/trip_stats_model.dart';
import 'package:genesis/models/vehicle_stats_model.dart';

class GenisisPrinter {
  static Future<void> printFinancialReports(TripStatsModel model) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text("Financial Trip Statistics Report"),
            ),

            // --- Summary Section ---
            pw.Header(level: 1, child: pw.Text("Overall Summary")),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  "Total Revenue",
                  "\$${model.summary.totalRevenue.toStringAsFixed(2)}",
                ),
                _buildStatCard("Total Trips", "${model.summary.totalTrips}"),
                _buildStatCard(
                  "Margin",
                  "${model.summary.margin.toStringAsFixed(1)}%",
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // --- Drivers Table ---
            pw.Header(level: 1, child: pw.Text("Driver Performance")),
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Email', 'Revenue'],
              data: model.drivers
                  .map((d) => [d.name, d.email, "\$${d.totalRevenue}"])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
            ),
            pw.SizedBox(height: 20),

            // --- Monthly Breakdown ---
            pw.Header(level: 1, child: pw.Text("Range Breakdown")),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Revenue'],
              data: model.monthlyBreakdown
                  .map(
                    (m) => [
                      GenesisDate.getInformalDate(m.date),
                      "\$${m.revenue.toStringAsFixed(2)}",
                    ],
                  )
                  .toList(),
            ),
          ];
        },
      ),
    );

    // 1. Save to folder
    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/trip_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // 2. Open / Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Financial_Report.pdf',
    );
  }

  static Future<void> printMainStatsReports(MainStatsModel stats) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 24),

          // --- Section 1: Fleet Utilization Overview ---
          _buildSectionTitle("Fleet Utilization"),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric(
                      "Total Fleet",
                      stats.totalVehiclesInSystem.toString(),
                    ),
                    _buildMetric(
                      "Active",
                      stats.activeVehicles.toInt().toString(),
                      color: PdfColors.green700,
                    ),
                    _buildMetric(
                      "Idle",
                      stats.idleVehicles.toInt().toString(),
                      color: PdfColors.orange700,
                    ),
                    _buildMetric(
                      "In Service",
                      stats.inServiceVehicles.toInt().toString(),
                      color: PdfColors.blue700,
                    ),
                  ],
                ),
                pw.Divider(height: 20, color: PdfColors.grey100),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric(
                      "Total Drivers",
                      stats.totalDriversInSystem.toString(),
                    ),
                    _buildMetric(
                      "Revenue",
                      NumberUtils.formatCurrency(stats.totalRevenue),
                      isBold: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 32),

          // --- Section 2: Operational Expense Breakdown ---
          _buildSectionTitle("Operational Expenses"),
          _buildExpenseTable(stats),

          pw.SizedBox(height: 32),

          // --- Section 3: Maintenance Summary ---
          _buildSectionTitle("Maintenance & Workshop"),
          pw.Row(
            children: [
              _buildMetric(
                "Work Orders",
                stats.totalMaintenanceCount.toString(),
              ),
              _buildMetric(
                "Vehicles Impacted",
                stats.numberOfVehiclesWithMaintenance.toString(),
              ),
              _buildMetric(
                "Maintenance Cost",
                NumberUtils.formatCurrency(stats.totalMaintainanceCost),
                color: PdfColors.red700,
              ),
            ],
          ),

          pw.Spacer(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Generated on: ${DateTime.now().toString().split(' ')[0]}",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
          ),
        ],
      ),
    );
    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/trip_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // 2. Open / Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'main_report.pdf',
    );
  }

  static pw.Widget _buildStatCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "GENESIS FLEET",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              "Administrative Performance Report",
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.PdfLogo(),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          pw.Container(height: 2, width: 40, color: PdfColors.blue700),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionSubtitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildMetric(
    String label,
    String value, {
    PdfColor? color,
    bool isBold = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: color ?? PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildExpenseTable(MainStatsModel stats) {
    final rows = [
      ['Fuel Expenses', stats.fuelExpense],
      ['Tollgate Fees', stats.tolgateExpense],
      ['Truck Shop / Parts', stats.truckShopExpense],
      ['Food / Allowances', stats.foodExpense],
      ['Fines & Penalties', stats.finesExpense],
      ['Miscellaneous Extras', stats.extrasExpense],
    ];

    final totalExp =
        stats.fuelExpense +
        stats.tolgateExpense +
        stats.truckShopExpense +
        stats.foodExpense +
        stats.finesExpense +
        stats.extrasExpense;

    return pw.Column(
      children: [
        pw.TableHelper.fromTextArray(
          border: null,
          headerAlignment: pw.Alignment.centerLeft,
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
          ),
          cellStyle: const pw.TextStyle(fontSize: 10),
          rowDecoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100)),
          ),
          headers: ['Category', 'Amount'],
          data: rows
              .map((r) => [r[0], NumberUtils.formatCurrency(r[1] as double)])
              .toList(),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Total Operational Cost: ${NumberUtils.formatCurrency(totalExp)}",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> printVehicleProfileReports(
    VehicleModel mode,
    VehicleStatsModel stats,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 24),

          // --- Section 1: Fleet Utilization Overview ---
          _buildSectionTitle("Vehicle - ${mode.carModel}"),
          _buildSectionSubtitle(mode.licencePlate),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("Trips", stats.totalTrips.toString()),
                    _buildMetric(
                      "Maintainances Costs",
                      stats.totalMaintenanceCosts.toString(),
                      color: PdfColors.red400,
                    ),
                    _buildMetric(
                      "Total Revenue",
                      stats.totalRevenue.toString(),
                      color: PdfColors.orange700,
                    ),
                  ],
                ),
                pw.Divider(height: 20, color: PdfColors.grey100),
              ],
            ),
          ),
          pw.SizedBox(height: 32),
          if (mode.insurances.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("Insurance Coverage")),
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Amount'],
              data: mode.insurances
                  .map(
                    (m) => [m.name, "\$${NumberUtils.formatCurrency(m.value)}"],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 32),
          ],
          if (stats.trips.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("Trips History")),
            pw.TableHelper.fromTextArray(
              headers: ['Route', 'Payout', 'Start Date', 'End Date', 'Status'],
              data: stats.trips
                  .map(
                    (m) => [
                      '${m.origin}-${m.destination}',
                      "\$${NumberUtils.formatCurrency(m.tripPayout)}",
                      "${m.startTime != null ? GenesisDate.getInformalDate(m.startTime!) : '-'}",
                      "${m.endTime != null ? GenesisDate.getInformalDate(m.endTime!) : 'in progress'}",
                      m.status.toUpperCase(),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 32),
          ],

          if (stats.trips.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("Service History")),
            pw.TableHelper.fromTextArray(
              headers: ['Issue Details', 'CarModel', 'Cost', 'Status'],
              data: stats.maintenances
                  .map(
                    (m) => [
                      '${m.issueDetails.length > 30 ? m.issueDetails.substring(0, 30) + '...' : m.issueDetails}',
                      '${m.carModel}',
                      "\$${NumberUtils.formatCurrency(m.estimatedCosts)}",
                      m.status.toUpperCase(),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 32),
          ],
        ],
      ),
    );
    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/vehicle_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // 2. Open / Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'vehicle_report.pdf',
    );
  }
}
