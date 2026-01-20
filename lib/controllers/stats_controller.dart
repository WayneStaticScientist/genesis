import 'package:genesis/models/main_stats_model.dart';
import 'package:get/get.dart';
import 'package:genesis/services/network_adapter.dart';

class StatsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorState = ''.obs;
  Rx<MainStatsModel?> stats = Rx<MainStatsModel?>(null);
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
    return;
  }
}
