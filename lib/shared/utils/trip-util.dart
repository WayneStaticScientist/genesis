import 'package:genesis/models/trip_model.dart';

class TripUtils {
  static Destinations? getCurrentDestination(TripModel trip) {
    if (trip.destinations.isEmpty) {
      return null;
    }
    for (var dest in trip.destinations) {
      if (!dest.reached) {
        return dest;
      }
    }
    return trip.destinations.last;
  }
}
