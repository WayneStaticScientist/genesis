import 'package:genesis/models/trip_model.dart';
import 'package:genesis/services/network_adapter.dart';
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
}
