import 'dart:developer';

import 'package:genesis/models/user_trip_stats_model.dart';
import 'package:genesis/models/vehicle_stats_model.dart';
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
  Future<void> fetchStats(DateTimeRange? range) async {
    isLoading.value = true;
    errorState.value = '';
    final response = await Net.get(
      '/stats/main?startDate=${range?.start.toIso8601String() ?? ''}&endDate=${range?.end.toIso8601String() ?? ''}',
    );
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
