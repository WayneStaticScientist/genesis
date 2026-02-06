import 'package:get_storage/get_storage.dart';

class User {
  final String? id;
  final int? trips;
  final String? status;
  final String? experience;
  final double? rating;
  final int? safety;
  final String role;
  final String email;
  final String country;
  final String lastName;
  final String firstName;
  final String? password;
  final String? companyId;
  User({
    this.id,
    this.password,
    this.status,
    this.experience,
    this.rating,
    this.safety,
    this.companyId,
    this.trips,
    required this.email,
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
      'firstName': firstName,
      'companyId': companyId,
      'experience': experience,
    };
  }

  factory User.fromJSON(Map<String, dynamic> data) {
    return User(
      id: data['_id'],
      email: data['email'],
      role: data['role'],
      country: data['country'],
      lastName: data['lastName'],
      firstName: data['firstName'],
      status: data['status'],
      experience: data['experience'],
      rating: (data['rating'] as num?)?.toDouble(),
      safety: data['safety'],
      companyId: data['companyId'],
      trips: data['trips'],
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
