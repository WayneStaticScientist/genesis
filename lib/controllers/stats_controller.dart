import 'package:genesis/models/main_stats_model.dart';
import 'package:genesis/models/seven_days_total.dart';
import 'package:get/get.dart';
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
}
