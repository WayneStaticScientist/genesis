import 'package:genesis/models/trip_model.dart';

class UserTripStatsHistory {
  final String id;
  final String status;
  final String destination;
  final String origin;
  final double revenue;
  final DateTime date;
  final String loadType;
  final double loadWeight;
  final List<Destinations> destinations;

  UserTripStatsHistory({
    required this.id,
    required this.status,
    required this.destination,
    required this.origin,
    required this.revenue,
    required this.date,
    required this.loadType,
    required this.loadWeight,
    required this.destinations,
  });
  factory UserTripStatsHistory.fromJSON(data) {
    return UserTripStatsHistory(
      id: data['_id'] ?? '',
      destinations:
          (data['destinations'] as List<dynamic>?)
              ?.map((e) => Destinations.fromJson(e))
              .toList() ??
          [],
      status: data['status'] ?? '',
      loadType: data['loadType'] ?? '',
      destination: data['destination'] ?? '',
      origin: data['origin'] ?? '',
      revenue: (data['revenue'] as num?)?.toDouble() ?? 0,
      loadWeight: (data['loadWeight'] as num?)?.toDouble() ?? 0,
      date: DateTime.parse(data['date']),
    );
  }
}

class UserTripStatsModel {
  final String firstName;
  final String lastName;
  final int totalTrips;
  final double totalRevenue;
  final String email;
  final List<UserTripStatsHistory> recentTrips;
  UserTripStatsModel({
    required this.firstName,
    required this.lastName,
    required this.totalTrips,
    required this.totalRevenue,
    required this.recentTrips,
    required this.email,
  });
  factory UserTripStatsModel.fromJSON(data) {
    return UserTripStatsModel(
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      totalTrips: data['totalTrips'] ?? 0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0,
      recentTrips:
          (data['recentTrips'] as List<dynamic>?)
              ?.map((e) => UserTripStatsHistory.fromJSON(e))
              .toList() ??
          [],
    );
  }
}
