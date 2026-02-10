import 'package:genesis/models/current_vehicle_model.dart';
import 'package:genesis/models/populated_trip_model.dart';
import 'package:get_storage/get_storage.dart';

class User {
  final String? id;
  final int? trips;
  final int? safety;
  final String role;
  final String email;
  final String country;
  final String? status;
  final double? rating;
  final String lastName;
  final String firstName;
  final String? password;
  final String? companyId;
  final String? experience;
  final PopulatedTripModel? trip;
  CurrentVehicleModel? currentVehicle;
  User({
    this.id,
    this.password,
    this.status,
    this.experience,
    this.rating,
    this.safety,
    this.companyId,
    this.trips,
    this.trip,
    required this.email,
    this.currentVehicle,
    this.role = 'default',
    required this.country,
    required this.lastName,
    required this.firstName,
  });

  Map<String, dynamic> toJSON() {
    return {
      '_id': id,
      'role': role,
      'trips': trips,
      'email': email,
      'rating': rating,
      'status': status,
      'safety': safety,
      'country': country,
      'password': password,
      'lastName': lastName,
      "trip": trip?.toJSON(),
      'firstName': firstName,
      'companyId': companyId,
      'experience': experience,
      'currentVehicle': currentVehicle?.toJson(),
    };
  }

  factory User.fromJSON(Map<String, dynamic> data) {
    return User(
      id: data['_id'],
      trip: data['trip'] != null
          ? PopulatedTripModel.fromJSON(data['trip'])
          : null,
      role: data['role'],
      email: data['email'],
      trips: data['trips'],
      safety: data['safety'],
      status: data['status'],
      country: data['country'],
      lastName: data['lastName'],
      companyId: data['companyId'],
      firstName: data['firstName'],
      experience: data['experience'],
      currentVehicle: data['currentVehicle'] == null
          ? null
          : CurrentVehicleModel.fromJson(data['currentVehicle']),
      rating: (data['rating'] as num?)?.toDouble(),
    );
  }
  void saveUser() {
    final box = GetStorage();
    box.write("user", toJSON());
  }

  static User? fromStorage() {
    final box = GetStorage();
    final user = box.read("user");
    if (user == null) return null;
    return User.fromJSON(user);
  }

  static void clearStorage() {
    final box = GetStorage();
    box.remove("user");
  }
}
