import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/services/network_adapter.dart';
import 'package:genesis/utils/toast.dart';
import 'package:get/get.dart';

class TripsController extends GetxController {
  var trips = <TripModel>[].obs;
  var loadingTrips = false.obs;
  Future<void> fetchTrips({
    int page = 1,
    String search = '',
    String status = '',
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    loadingTrips.value = true;
    final response = await Net.get(
      "/trips",
      queryParameters: {
        "page": page,
        "search": search,
        "status": status,
        if (startTime != null) "startTime": startTime.toIso8601String(),
        if (endTime != null) "endTime": endTime.toIso8601String(),
      },
    );
    loadingTrips.value = false;
    if (!response.hasError) {
      final List data = response.body['list'] ?? [];
      if (page == 1) {
        trips.value = data.map((e) => TripModel.fromJson(e)).toList();
      } else {
        trips.addAll(data.map((e) => TripModel.fromJson(e)).toList());
      }
    }
  }

  RxBool processingTrip = RxBool(false);
  Future<bool> finalizeTrip(String id, {dynamic data}) async {
    if (processingTrip.value) {
      Toaster.showError("loading please wait");
      return false;
    }
    processingTrip.value = true;
    final response = await Net.put("/trip/$id", data: data);
    processingTrip.value = false;
    if (response.hasError) {
      Toaster.showError(response.response);
      return false;
    }
    final controller = Get.find<UserController>();
    controller.fetchDrivers();
    return true;
  }
}
