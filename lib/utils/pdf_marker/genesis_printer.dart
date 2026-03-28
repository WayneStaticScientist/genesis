import 'dart:io';
import 'package:genesis/models/payroll_model.dart';
import 'package:genesis/models/user_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/models/vehicle_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:genesis/models/payroll_details.dart';
import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/models/trip_stats_model.dart';
import 'package:genesis/models/maintainance_model.dart';
import 'package:genesis/models/vehicle_stats_model.dart';
import 'package:genesis/models/user_trip_stats_model.dart';

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
                  "${NumberUtils.formatCurrency(model.summary.totalRevenue)}",
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
                  .map(
                    (d) => [
                      d.name,
                      d.email,
                      "${NumberUtils.formatCurrency(d.totalRevenue)}",
                    ],
                  )
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
                      "${NumberUtils.formatCurrency(m.revenue)}",
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

  static pw.Widget _buildHeader({String? title}) {
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
              title ?? "Administrative Performance Report",
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
                    (m) => [m.name, "${NumberUtils.formatCurrency(m.value)}"],
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
                      "${NumberUtils.formatCurrency(m.tripPayout)}",
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
                      "${NumberUtils.formatCurrency(m.estimatedCosts)}",
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

  static Future<void> printMaintainancesState(
    VehicleModel mode,
    List<MaintainanceModel> stats,
    DateTimeRange dateRange,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            title:
                "Maintenance History - ${GenesisDate.formatMonthAndDay(dateRange.start)} - ${GenesisDate.formatMonthAndDay(dateRange.end)}",
          ),
          pw.SizedBox(height: 24),

          // --- Section 1: Fleet Utilization Overview ---
          _buildSectionTitle("Vehicle - ${mode.carModel}"),
          _buildSectionSubtitle(mode.licencePlate),

          if (stats.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("Service History")),
            pw.TableHelper.fromTextArray(
              headers: ['Issue Details', 'CarModel', 'Cost', 'Status'],
              data: stats
                  .map(
                    (m) => [
                      '${m.issueDetails.length > 30 ? m.issueDetails.substring(0, 30) + '...' : m.issueDetails}',
                      '${m.carModel}',
                      "${NumberUtils.formatCurrency(m.estimatedCosts)}",
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

  static Future<void> printUserInsightsState(
    UserTripStatsModel stats,
    DateTimeRange dateRange,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            title:
                "UserInsights - ${GenesisDate.formatMonthAndDay(dateRange.start)} - ${GenesisDate.formatMonthAndDay(dateRange.end)}",
          ),
          pw.SizedBox(height: 24),

          // --- Section 1: Fleet Utilization Overview ---
          _buildSectionTitle("User - ${stats.firstName} ${stats.lastName}}"),
          _buildSectionSubtitle(stats.email),
          _buildSectionTitle("Performance Summary"),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard("Total Trips", "${stats.totalTrips}"),

              _buildStatCard(
                "Total Revenue",
                "${NumberUtils.formatCurrency(stats.totalRevenue)}",
              ),
            ],
          ),
          if (stats.recentTrips.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("Service History")),
            pw.TableHelper.fromTextArray(
              headers: ['Route', 'Revenue', 'Type', 'Status', 'Date'],
              data: stats.recentTrips
                  .map(
                    (m) => [
                      '${m.origin}-${m.destination}',
                      "${NumberUtils.formatCurrency(m.revenue)}",
                      '${m.loadType}',
                      m.status.toUpperCase(),
                      "${GenesisDate.formatNormalDate(m.date)}",
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
      "${output.path}/user_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // 2. Open / Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'user_report.pdf',
    );
  }

  static Future<void> printTripsReports(List<TripModel> stats) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(title: "Trips History"),
          pw.SizedBox(height: 24),

          if (stats.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("Service History")),
            pw.TableHelper.fromTextArray(
              headers: [
                'Route',
                'Revenue',
                'Expenses',
                'Driver',
                'Car Model',
                'Type',
                'Start Time',
                'Stop Time',
                'Status',
              ],
              data: stats
                  .map(
                    (m) => [
                      '${m.origin}-${m.destination}',
                      "${NumberUtils.formatCurrency(m.tripPayout)}",
                      "${NumberUtils.formatCurrency(NumberUtils.getTripExpenseTotal(m))}",
                      m.driver != null
                          ? (
                              m.driver['firstName'] +
                                  ' ' +
                                  m.driver['lastName'],
                            )
                          : 'notfound',
                      m.vehicle.carModel,
                      '${m.loadType}',
                      "${m.startTime != null ? GenesisDate.formatNormalDate(m.startTime!) : ''}",
                      "${m.endTime != null ? GenesisDate.formatNormalDate(m.endTime!) : 'in process'}",
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
      "${output.path}/trip_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // 2. Open / Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'trip_report.pdf',
    );
  }

  static Future<void> PrintTrip(TripModel stats) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(title: "Trip ${stats.origin}-${stats.destination}"),
          pw.SizedBox(height: 24),
          pw.TableHelper.fromTextArray(
            headers: [
              'Revenue',
              'Expenses',
              'Driver',
              'Car Model',
              'Type',
              'Start Time',
              'Stop Time',
              'Status',
            ],
            data: [
              [
                "${NumberUtils.formatCurrency(stats.tripPayout)}",
                "${NumberUtils.formatCurrency(NumberUtils.getTripExpenseTotal(stats))}",
                stats.driver != null
                    ? (
                        stats.driver['firstName'] +
                            ' ' +
                            stats.driver['lastName'],
                      )
                    : 'notfound',
                stats.vehicle.carModel,
                '${stats.loadType}',
                "${stats.startTime != null ? GenesisDate.formatNormalDate(stats.startTime!) : ''}",
                "${stats.endTime != null ? GenesisDate.formatNormalDate(stats.endTime!) : 'in process'}",
                stats.status.toUpperCase(),
              ],
            ],
          ),
          pw.SizedBox(height: 32),
          pw.Header(level: 1, child: pw.Text("Expenses")),
          pw.TableHelper.fromTextArray(
            headers: [
              'Food Expense',
              'Tolgate Fees',
              'Truck Stop',
              'Fuel Expenses',
              'Fines',
              'Extras',
            ],
            data: [
              [
                NumberUtils.formatCurrency(stats.foodExpense),
                NumberUtils.formatCurrency(stats.tolgateExpense),
                NumberUtils.formatCurrency(stats.truckShopExpense),
                NumberUtils.formatCurrency(stats.fuelExpense),
                NumberUtils.formatCurrency(stats.finesExpense),
                NumberUtils.formatCurrency(stats.extrasExpense),
              ],
            ],
          ),
          if (stats.initiater != null) ...[
            pw.SizedBox(height: 32),
            pw.Header(level: 1, child: pw.Text("Trip Creator")),
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Email'],
              data: [
                [
                  "${stats.initiater['firstName']} ${stats.initiater['lastName']}",
                  stats.initiater['email'],
                ],
              ],
            ),
          ],
          if (stats.finalizer != null) ...[
            pw.SizedBox(height: 32),
            pw.Header(level: 1, child: pw.Text("Trip Finalizer")),
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Email'],
              data: [
                [
                  "${stats.finalizer['firstName']} ${stats.finalizer['lastName']}",
                  stats.finalizer['email'],
                ],
              ],
            ),
          ],
          if (stats.notes.isNotEmpty) ...[
            pw.SizedBox(height: 32),
            _buildHeader(title: "Notes"),
            pw.SizedBox(height: 14),
            pw.Text(stats.notes),
          ],
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
      name: 'trip_report.pdf',
    );
  }

  static Future<void> printListMaintainances(
    List<MaintainanceModel> stats,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(title: "Maintenance History"),
          pw.SizedBox(height: 24),
          if (stats.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("Service History")),
            pw.TableHelper.fromTextArray(
              headers: ['Issue Details', 'CarModel', 'Cost', 'Status'],
              data: stats
                  .map(
                    (m) => [
                      '${m.issueDetails.length > 30 ? m.issueDetails.substring(0, 30) + '...' : m.issueDetails}',
                      '${m.carModel}',
                      "${NumberUtils.formatCurrency(m.estimatedCosts)}",
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
      "${output.path}/mantainances_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // 2. Open / Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'mantainances_report.pdf',
    );
  }

  static Future<void> PrintMantainance(MaintainanceModel stats) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(title: "Maintainance Model "),
          pw.SizedBox(height: 24),
          pw.TableHelper.fromTextArray(
            headers: ['Cost', 'Car Model', 'Health', 'Status'],
            data: [
              [
                "${NumberUtils.formatCurrency(stats.estimatedCosts)}",
                "${stats.carModel}",
                stats.currentHealth,
                stats.status.toUpperCase(),
              ],
            ],
          ),

          if (stats.maintainerId != null) ...[
            pw.SizedBox(height: 32),
            pw.Header(level: 1, child: pw.Text("Maintainance Initiator")),
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Email'],
              data: [
                [
                  "${stats.maintainerId['firstName']} ${stats.maintainerId['lastName']}",
                  stats.maintainerId['email'],
                ],
              ],
            ),
          ],
          if (stats.approverId != null) ...[
            pw.SizedBox(height: 32),
            pw.Header(level: 1, child: pw.Text("Approver")),
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Email'],
              data: [
                [
                  "${stats.approverId['firstName']} ${stats.approverId['lastName']}",
                  stats.approverId['email'],
                ],
              ],
            ),
          ],
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
      name: 'trip_report.pdf',
    );
  }

  static Future<void> printPayrollHistory(
    List<PayrollDetails> stats,
    DateTimeRange range,
    double total,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            title:
                "Payroll History - ${GenesisDate.formatMonthAndDay(range.start)} - ${GenesisDate.formatMonthAndDay(range.end)}",
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            children: [
              _buildStatCard(
                "Total Payout",
                "${NumberUtils.formatCurrency(total)}",
              ),
              _buildStatCard("Active Records", "${stats.length}"),
            ],
          ),
          pw.SizedBox(height: 24),
          if (stats.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("History")),
            pw.TableHelper.fromTextArray(
              headers: ['Amount', 'Total Employees', 'Date'],
              data: stats
                  .map(
                    (m) => [
                      '${NumberUtils.formatCurrency(m.grossTotal)}',
                      '${m.totalEmployees}',
                      "${GenesisDate.formatNormalDate(m.createdAt)}",
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
      "${output.path}/payroll_history_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // 2. Open / Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'payroll_history_report.pdf',
    );
  }

  static Future<void> printUserPayrollHistory(
    List<PayrollModel> stats,
    DateTimeRange range,
    double total,
    User user,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            title:
                "${user.firstName} Payroll History - ${GenesisDate.formatMonthAndDay(range.start)} - ${GenesisDate.formatMonthAndDay(range.end)}",
          ),
          pw.SizedBox(height: 14),
          pw.Header(
            level: 1,
            child: pw.Text("${user.firstName} ${user.lastName}"),
          ),
          pw.Header(level: 1, child: pw.Text("${user.email}")),
          pw.SizedBox(height: 24),
          pw.Row(
            children: [
              _buildStatCard(
                "Total Payout",
                "${NumberUtils.formatCurrency(total)}",
              ),
              _buildStatCard("Active Records", "${stats.length}"),
            ],
          ),
          pw.SizedBox(height: 24),
          if (stats.isNotEmpty) ...[
            pw.Header(level: 1, child: pw.Text("History")),
            pw.TableHelper.fromTextArray(
              headers: ['Payment', 'Insurances', 'Tax', 'Net Payment', 'Date'],
              data: stats
                  .map(
                    (m) => [
                      '${NumberUtils.formatCurrency(m.payment)}',
                      '${NumberUtils.formatCurrency(m.netPayment)}',
                      '${NumberUtils.formatCurrency(m.insurance)}',
                      '${NumberUtils.formatCurrency(m.tax)}',
                      "${GenesisDate.formatNormalDate(m.createdAt)}",
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
      "${output.path}/user_payroll_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // 2. Open / Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'user_payroll_report.pdf',
    );
  }
}
