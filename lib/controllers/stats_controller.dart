import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/models/seven_days_total.dart';
import 'package:genesis/models/trip_stats_model.dart';
import 'package:genesis/services/network_adapter.dart';

class StatsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorState = ''.obs;
  Rx<MainStatsModel?> stats = Rx<MainStatsModel?>(null);
  RxList<SevenDaysTotal> sevenDaysTotals = RxList<SevenDaysTotal>([]);
  Future<void> fetchStats() async {
    isLoading.value = true;
    errorState.value = '';
    final response = await Net.get('/stats/main');
    isLoading.value = false;
    if (response.hasError) {
      errorState.value = response.response;
      return;
    }
    stats.value = MainStatsModel.fromJson(response.body['data']);
    sevenDaysTotals.value =
        (response.body['sevenDays'] as List<dynamic>?)
            ?.map((json) => SevenDaysTotal.fromJson(json))
            .toList() ??
        [];
    return;
  }

  RxBool fetchingTripStatus = false.obs;
  RxString fetchingTripStatsError = ''.obs;
  Rx<TripStatsModel?> tripsStatModel = Rx<TripStatsModel?>(null);
  Future<void> fetchTripStats(DateTimeRange range) async {
    fetchingTripStatus.value = true;
    fetchingTripStatsError.value = '';
    final response = await Net.get(
      '/stats/trips?startDate=${range.start.toIso8601String()}&endDate=${range.end.toIso8601String()}',
    );
    fetchingTripStatus.value = false;
    if (response.hasError) {
      fetchingTripStatsError.value = response.response;
      return;
    }
    tripsStatModel.value = TripStatsModel.fromJSON(response.body);
    return;
  }
}
