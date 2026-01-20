import 'package:get/get.dart';
import 'package:genesis/services/network_adapter.dart';

class StatsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorState = ''.obs;
  void fetchStats() async {
    isLoading.value = true;
    errorState.value = '';
    final response = await Net.get('/stats/main');
    isLoading.value = false;
    if (response.hasError) {
      errorState.value = response.response;
      return;
    }
  }
}
