import 'dart:io';
import 'package:genesis/models/payroll_model.dart';
import 'package:genesis/models/user_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static Future<pw.MemoryImage> _loadLogo() async {
    final bytes = await rootBundle.load('assets/icons/ic_icon.png');
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  static Future<void> printFinancialReports(TripStatsModel model) async {
    final logo = await _loadLogo();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(logo, title: "Financial Trip Statistics Report"),
            pw.SizedBox(height: 24),

            // --- Summary Section ---
            _buildSectionTitle("Overall Summary"),
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
            pw.SizedBox(height: 32),

            // --- Drivers Table ---
            _buildSectionTitle("Driver Performance"),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#F0F2F5')),
                bottom: pw.BorderSide(color: PdfColor.fromHex('#E0E4EC')),
              ),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2A2D3E')),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              cellStyle: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#3A3D4E')),
              cellPadding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
            ),
            pw.SizedBox(height: 32),

            // --- Monthly Breakdown ---
            _buildSectionTitle("Range Breakdown"),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#F0F2F5')),
                bottom: pw.BorderSide(color: PdfColor.fromHex('#E0E4EC')),
              ),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2A2D3E')),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              cellStyle: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#3A3D4E')),
              cellPadding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(logo),
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
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F8F9FB'),
          border: pw.Border.all(color: PdfColor.fromHex('#E0E4EC'), width: 1.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#7D859C'),
                letterSpacing: 1.1,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#2A2D3E'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildHeader(pw.MemoryImage logoImage, {String? title}) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 24),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E0E4EC'), width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            children: [
              pw.Image(logoImage, width: 64, height: 64),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "GENESIS FLEET",
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#2A2D3E'),
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    title ?? "Administrative Performance Report",
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColor.fromHex('#6C5DD3'),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "REPORT GENERATED",
                style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#7D859C'), fontWeight: pw.FontWeight.bold, letterSpacing: 1.2),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                GenesisDate.formatNormalDate(DateTime.now()),
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2A2D3E')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#212332'),
              letterSpacing: 1.2,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Container(height: 3, width: 60, color: PdfColor.fromHex('#6C5DD3')),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionSubtitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#7D859C'),
          letterSpacing: 1.5,
        ),
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
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColor.fromHex('#7D859C'),
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
            color: color ?? PdfColor.fromHex('#2A2D3E'),
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

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E0E4EC')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#F0F2F5')),
              bottom: pw.BorderSide(color: PdfColor.fromHex('#E0E4EC')),
            ),
            headerAlignment: pw.Alignment.centerLeft,
            cellAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2A2D3E')),
            cellStyle: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#3A3D4E')),
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            headers: ['Category', 'Amount'],
            data: rows
                .map((r) => [r[0], NumberUtils.formatCurrency(r[1] as double)])
                .toList(),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8F9FB')),
            alignment: pw.Alignment.centerRight,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  "Total Operational Cost: ",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#7D859C'),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  NumberUtils.formatCurrency(totalExp),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#E53935'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> printVehicleProfileReports(
    VehicleModel mode,
    VehicleStatsModel stats,
  ) async {
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          double totalTripExpenses = stats.trips.fold(0.0, (sum, trip) => sum + NumberUtils.getTripExpenseTotal(trip));
          double totalExpenses = stats.totalMaintenanceCosts + totalTripExpenses;
          double netProfit = stats.totalRevenue - totalExpenses;
          
          return [
          _buildHeader(logo, title: "Vehicle Profile Report"),
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
                      "Total Expenses",
                      NumberUtils.formatCurrency(totalExpenses),
                      color: PdfColors.red400,
                    ),
                    _buildMetric(
                      "Total Revenue",
                      NumberUtils.formatCurrency(stats.totalRevenue),
                      color: PdfColors.orange700,
                    ),
                    _buildMetric(
                      "Net Profit",
                      NumberUtils.formatCurrency(netProfit),
                      color: netProfit >= 0 ? PdfColors.green700 : PdfColors.red700,
                      isBold: true,
                    ),
                  ],
                ),
                pw.Divider(height: 20, color: PdfColors.grey100),
              ],
            ),
          ),
          pw.SizedBox(height: 32),
          if (mode.insurances.isNotEmpty) ...[
            _buildSectionTitle("Insurance Coverage"),
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
            _buildSectionTitle("Trips History"),
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

          if (stats.maintenances.isNotEmpty) ...[
            _buildSectionTitle("Service History"),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Issue Details', 'CarModel', 'Cost', 'Status'],
              data: stats.maintenances
                  .map(
                    (m) => [
                      GenesisDate.getInformalShortDate(m.dueDate),
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
        ];
      },
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
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            logo,
            title:
                "Maintenance History - ${GenesisDate.formatMonthAndDay(dateRange.start)} - ${GenesisDate.formatMonthAndDay(dateRange.end)}",
          ),
          pw.SizedBox(height: 24),

          // --- Section 1: Fleet Utilization Overview ---
          _buildSectionTitle("Vehicle - ${mode.carModel}"),
          _buildSectionSubtitle(mode.licencePlate),

          if (stats.isNotEmpty) ...[
            _buildSectionTitle("Service History"),
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
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            logo,
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
            _buildSectionTitle("Service History"),
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
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(logo, title: "Trips History"),
          pw.SizedBox(height: 24),

          if (stats.isNotEmpty) ...[
            _buildSectionTitle("Trip History"),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#F0F2F5')),
                bottom: pw.BorderSide(color: PdfColor.fromHex('#E0E4EC')),
              ),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2A2D3E')),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              cellStyle: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#3A3D4E')),
              cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              headers: [
                'Route',
                'Driver',
                'Vehicle',
                'Duration',
                'Start Time',
                'Stop Time',
                'Revenue',
                'Expenses',
                'Status',
              ],
              data: stats.map((m) {
                String routeStr = m.origin;
                if (m.destinations.isNotEmpty) {
                  routeStr += " -> " + m.destinations.map((d) => d.name).join(" -> ");
                } else {
                  routeStr += " -> " + m.destination;
                }
                
                String duration = "-";
                if (m.startTime != null && m.endTime != null) {
                  final diff = m.endTime!.difference(m.startTime!);
                  final days = diff.inDays;
                  final hours = diff.inHours % 24;
                  if (days > 0) duration = "${days}d ${hours}h";
                  else duration = "${hours}h";
                }
                
                return [
                  routeStr,
                  m.driver != null ? "${m.driver['firstName']} ${m.driver['lastName']}" : 'notfound',
                  m.vehicle.carModel,
                  duration,
                  m.startTime != null ? GenesisDate.getInformalDate(m.startTime!) : '-',
                  m.endTime != null ? GenesisDate.getInformalDate(m.endTime!) : 'in process',
                  NumberUtils.formatCurrency(m.tripPayout),
                  NumberUtils.formatCurrency(NumberUtils.getTripExpenseTotal(m)),
                  m.status.toUpperCase(),
                ];
              }).toList(),
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
    final logo = await _loadLogo();
    final pdf = pw.Document();
    
    final totalExpenses = NumberUtils.getTripExpenseTotal(stats);
    final netProfit = stats.tripPayout - totalExpenses;
    
    String duration = "-";
    if (stats.startTime != null && stats.endTime != null) {
      final diff = stats.endTime!.difference(stats.startTime!);
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      if (days > 0) duration = "${days}d ${hours}h";
      else duration = "${hours}h";
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(logo, title: "Trip Manifest & Summary"),
          pw.SizedBox(height: 20),

          // --- SECTION: Key Stats ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard("Total Revenue", NumberUtils.formatCurrency(stats.tripPayout)),
              _buildStatCard("Total Expenses", NumberUtils.formatCurrency(totalExpenses)),
              _buildStatCard(
                "Net Profit",
                NumberUtils.formatCurrency(netProfit),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // --- SECTION: Trip Details Grid ---
          _buildSectionTitle("General Information"),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#E0E4EC'), width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("Origin", stats.origin),
                    _buildMetric("Destination", stats.destination),
                    _buildMetric("Status", stats.status.toUpperCase(), 
                        color: stats.status.toLowerCase() == 'finalized' ? PdfColors.green700 : PdfColors.orange700),
                  ],
                ),
                pw.Divider(height: 16, color: PdfColor.fromHex('#F0F2F5')),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("Pilot / Driver", stats.driver != null ? "${stats.driver['firstName']} ${stats.driver['lastName']}" : 'N/A'),
                    _buildMetric("Vehicle", stats.vehicle.carModel),
                    _buildMetric("Duration", duration),
                  ],
                ),
                pw.Divider(height: 16, color: PdfColor.fromHex('#F0F2F5')),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("Load Type", stats.loadType),
                    _buildMetric("Start Time", stats.startTime != null ? GenesisDate.getInformalDate(stats.startTime!) : '-'),
                    _buildMetric("Stop Time", stats.endTime != null ? GenesisDate.getInformalDate(stats.endTime!) : 'In Progress'),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // --- SECTION: Navigation Log ---
          if (stats.destinations.isNotEmpty) ...[
            _buildSectionTitle("Navigation Log"),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#F0F2F5')),
                bottom: pw.BorderSide(color: PdfColor.fromHex('#E0E4EC')),
              ),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2A2D3E')),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              cellStyle: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#3A3D4E')),
              cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              headers: ['Route Segment / Destination', 'Distance', 'Offload Weight', 'Revenue', 'Completed At', 'Status'],
              data: stats.destinations.map((d) => [
                 d.name,
                 "${d.distance} km",
                 "${d.offloadWeight} kg",
                 NumberUtils.formatCurrency(d.revenue),
                 d.reachedAt != null ? GenesisDate.getInformalDate(d.reachedAt!) : "-",
                 d.reached ? "REACHED" : "PENDING",
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // --- SECTION: Expenses ---
          _buildSectionTitle("Expense Breakdown"),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#F0F2F5')),
              bottom: pw.BorderSide(color: PdfColor.fromHex('#E0E4EC')),
            ),
            headerAlignment: pw.Alignment.centerLeft,
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2A2D3E')),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
            cellStyle: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#3A3D4E')),
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            headers: ['Expense Category', 'Amount'],
            data: [
              ['Food / Allowances', NumberUtils.formatCurrency(stats.foodExpense)],
              ['Tollgate Fees', NumberUtils.formatCurrency(stats.tolgateExpense)],
              ['Truck Shop / Parts', NumberUtils.formatCurrency(stats.truckShopExpense)],
              ['Fuel Expenses', NumberUtils.formatCurrency(stats.fuelExpense)],
              ['Fines & Penalties', NumberUtils.formatCurrency(stats.finesExpense)],
              ['Miscellaneous Extras', NumberUtils.formatCurrency(stats.extrasExpense)],
            ],
          ),
          pw.SizedBox(height: 24),

          // --- SECTION: Admin Info ---
          _buildSectionTitle("Administrative Metadata"),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8F9FB'),
              border: pw.Border.all(color: PdfColor.fromHex('#E0E4EC'), width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("Initiated By", stats.initiater != null ? "${stats.initiater['firstName']} ${stats.initiater['lastName']} (${stats.initiater['email']})" : 'N/A'),
                    if (stats.finalizer != null)
                      _buildMetric("Finalized By", "${stats.finalizer['firstName']} ${stats.finalizer['lastName']} (${stats.finalizer['email']})"),
                  ],
                ),
                if (stats.notes.isNotEmpty) ...[
                  pw.Divider(height: 16, color: PdfColor.fromHex('#E0E4EC')),
                  pw.Text(
                    "ADMIN NOTES:",
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#7D859C')),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    stats.notes,
                    style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#3A3D4E')),
                  ),
                ],
              ],
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
      name: 'trip_report.pdf',
    );
  }

  static Future<void> printListMaintainances(
    List<MaintainanceModel> stats,
  ) async {
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(logo, title: "Maintenance History"),
          pw.SizedBox(height: 24),
          if (stats.isNotEmpty) ...[
            _buildSectionTitle("Service History"),
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
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(logo, title: "Maintainance Model "),
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
            _buildSectionTitle("Maintainance Initiator"),
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
            _buildSectionTitle("Approver"),
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
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            logo,
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
            _buildSectionTitle("History"),
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
    final logo = await _loadLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            logo,
            title:
                "${user.firstName} Payroll History - ${GenesisDate.formatMonthAndDay(range.start)} - ${GenesisDate.formatMonthAndDay(range.end)}",
          ),
          pw.SizedBox(height: 14),
          _buildSectionTitle("${user.firstName} ${user.lastName}"),
          _buildSectionSubtitle("${user.email}"),
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
            _buildSectionTitle("History"),
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
