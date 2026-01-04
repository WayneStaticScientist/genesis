import 'package:get_storage/get_storage.dart';

class User {
  final String role;
  final String email;
  final String country;
  final String lastName;
  final String firstName;
  final String? password;
  final String? companyId;
  User({
    this.password,
    this.companyId,
    required this.email,
    this.role = 'default',
    required this.country,
    required this.lastName,
    required this.firstName,
  });

  Map<String, dynamic> toJSON() {
    return {
      'role': role,
      'email': email,
      'country': country,
      'password': password,
      'lastName': lastName,
      'firstName': firstName,
      'companyId': companyId,
    };
  }

  factory User.fromJSON(Map<String, dynamic> data) {
    return User(
      email: data['email'],
      role: data['firstName'],
      country: data['country'],
      lastName: data['lastName'],
      firstName: data['firstName'],
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
