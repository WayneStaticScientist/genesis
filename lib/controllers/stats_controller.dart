import 'dart:developer';

import 'package:genesis/models/user_trip_stats_model.dart';
import 'package:genesis/models/vehicle_stats_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/models/graph_data_point.dart';
import 'package:genesis/models/trip_stats_model.dart';
import 'package:genesis/services/network_adapter.dart';

import 'package:genesis/models/yearly_report_model.dart';

class StatsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isGraphLoading = false.obs;
  RxString errorState = ''.obs;
  Rx<MainStatsModel?> stats = Rx<MainStatsModel?>(null);
  RxString selectedPeriod = 'Monthly'.obs;
  Rx<DateTime> selectedMonth = DateTime.now().obs;
  RxInt selectedYear = DateTime.now().year.obs;
  RxList<GraphDataPoint> graphData = RxList<GraphDataPoint>([]);
  RxList<GraphDataPoint> monthlySparklineData = RxList<GraphDataPoint>([]);

  RxBool isFetchingYearly = false.obs;
  RxString yearlyError = ''.obs;
  Rx<YearlyReportModel?> yearlyReport = Rx<YearlyReportModel?>(null);

  Future<void> fetchYearlyReport() async {
    isFetchingYearly.value = true;
    yearlyError.value = '';
    final response = await Net.get('/stats/yearly?year=${selectedYear.value}');
    isFetchingYearly.value = false;
    
    if (response.hasError) {
      yearlyError.value = response.response;
      return;
    }
    yearlyReport.value = YearlyReportModel.fromJSON(response.body);
  }

  Future<void> refreshMonthlyReports() async {
    final start = DateTime(selectedMonth.value.year, selectedMonth.value.month, 1);
    final end = DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 0, 23, 59, 59);
    final range = DateTimeRange(start: start, end: end);
    
    await Future.wait([
      fetchStats(range),
      fetchTripStats('Daily', range), // Pass 'Daily' for graph to show daily points in that month
    ]);
  }

  Future<void> fetchStats(DateTimeRange? range) async {
    isLoading.value = true;
    errorState.value = '';
    
    // Fetch main stats
    final response = await Net.get(
      '/stats/main?startDate=${range?.start.toIso8601String() ?? ''}&endDate=${range?.end.toIso8601String() ?? ''}',
    );
    
    if (response.hasError) {
      isLoading.value = false;
      errorState.value = response.response;
      return;
    }
    stats.value = MainStatsModel.fromJson(response.body['data']);
    
    // Fetch monthly sparkline data independently but part of initial load
    final sparklineResponse = await Net.get(
      '/stats/graph?startDate=${range?.start.toIso8601String() ?? ''}&endDate=${range?.end.toIso8601String() ?? ''}&period=Monthly',
    );
    if (!sparklineResponse.hasError) {
      monthlySparklineData.value =
          (sparklineResponse.body['graphData'] as List<dynamic>?)
              ?.map((json) => GraphDataPoint.fromJson(json))
              .toList() ??
          [];
    }
    
    isLoading.value = false;

    // Fetch the dynamic graph data (for the main chart)
    await fetchGraphStats(range);
  }

  Future<void> fetchGraphStats(DateTimeRange? range) async {
    isGraphLoading.value = true;
    final response = await Net.get(
      '/stats/graph?startDate=${range?.start.toIso8601String() ?? ''}&endDate=${range?.end.toIso8601String() ?? ''}&period=${selectedPeriod.value}',
    );
    isGraphLoading.value = false;
    
    if (response.hasError) {
      log("Error fetching graph data: ${response.response}");
      return;
    }
    
    graphData.value =
        (response.body['graphData'] as List<dynamic>?)
            ?.map((json) => GraphDataPoint.fromJson(json))
            .toList() ??
        [];
  }


  RxBool fetchingTripStatus = false.obs;
  RxString fetchingTripStatsError = ''.obs;
  Rx<TripStatsModel?> tripsStatModel = Rx<TripStatsModel?>(null);
  Future<void> fetchTripStats(String period, [DateTimeRange? range]) async {
    fetchingTripStatus.value = true;
    fetchingTripStatsError.value = '';
    
    String url = '/stats/trips?period=$period';
    if (range != null) {
      url += '&startDate=${range.start.toIso8601String()}&endDate=${range.end.toIso8601String()}';
    }
    
    final response = await Net.get(url);
    fetchingTripStatus.value = false;
    log("response ${response.response}");
    if (response.hasError) {
      fetchingTripStatsError.value = response.response;
      return;
    }
    tripsStatModel.value = TripStatsModel.fromJSON(response.body);
    return;
  }

  RxBool fetchingUserTripStatus = false.obs;
  RxString fetchingUserTripStatsError = ''.obs;
  Rx<UserTripStatsModel?> userTripStats = Rx<UserTripStatsModel?>(null);
  Future<void> fetchUSerTripStats(String userId, DateTimeRange range) async {
    fetchingUserTripStatus.value = true;
    fetchingUserTripStatsError.value = '';
    final response = await Net.get(
      '/stats/trips/user?startDate=${range.start.toIso8601String()}&endDate=${range.end.toIso8601String()}&userId=$userId',
    );
    fetchingUserTripStatus.value = false;
    if (response.hasError) {
      fetchingUserTripStatsError.value = response.response;
      return;
    }
    userTripStats.value = UserTripStatsModel.fromJSON(response.body);
    return;
  }

  RxBool fetchingVehicleTripStatus = false.obs;
  RxString fetchingVehicleTripStatsError = ''.obs;
  Rx<VehicleStatsModel?> vehicleTripStats = Rx<VehicleStatsModel?>(null);
  Future<void> fetchVehicleTripStats(
    String vehicleId,
    DateTimeRange range,
  ) async {
    fetchingVehicleTripStatus.value = true;
    fetchingVehicleTripStatsError.value = '';
    final response = await Net.get(
      '/stats/trips/vehicle?startDate=${range.start.toIso8601String()}&endDate=${range.end.toIso8601String()}&vehicleId=$vehicleId',
    );
    fetchingVehicleTripStatus.value = false;
    if (response.hasError) {
      fetchingVehicleTripStatsError.value = response.response;
      return;
    }
    vehicleTripStats.value = VehicleStatsModel.fromJSON(response.body);
    return;
  }
}
