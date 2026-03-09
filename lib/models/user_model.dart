import 'package:genesis/models/deducton_item.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:genesis/models/licence_model.dart';
import 'package:genesis/models/populated_trip_model.dart';
import 'package:genesis/models/current_vehicle_model.dart';
part 'user_model.g.dart';

@collection
class User {
  int notifications = 0;
  String lastMessage = '';
  final String id;
  final int? trips;
  final int? safety;
  final String role;
  final String email;
  final String country;
  final double payment;
  final String? status;
  final double? rating;
  final String lastName;
  final String firstName;
  final String? password;
  final String? chatToken;
  final String? companyId;
  final String? experience;
  @ignore
  final PopulatedTripModel? trip;
  @ignore
  CurrentVehicleModel? currentVehicle;
  @ignore
  LicenceModel? licence;
  @ignore
  List<DeductionItem> taxes;
  @ignore
  List<DeductionItem> insurance;
  User({
    this.notifications = 0,
    this.lastMessage = '',
    required this.id,
    required this.payment,
    required this.insurance,
    required this.taxes,
    this.licence,
    this.trip,
    this.trips,
    this.safety,
    this.rating,
    this.status,
    this.password,
    this.companyId,
    this.chatToken,
    this.experience,
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
      'licence': licence,
      'rating': rating,
      'status': status,
      'safety': safety,
      "payment": payment,
      'country': country,
      'password': password,
      "taxes": taxes.map((e) => e.toJson()),
      "insurance": insurance.map((e) => e.toJson()),
      'lastName': lastName,
      "trip": trip?.toJSON(),
      'firstName': firstName,
      'companyId': companyId,
      "chatToken": chatToken,
      'experience': experience,
      'currentVehicle': currentVehicle?.toJson(),
    };
  }

  factory User.fromJSON(Map<String, dynamic> data) {
    return User(
      payment: (data['payment'] as num?)?.toDouble() ?? 0,
      taxes: data['taxes'] != null
          ? (data['taxes'] as List<dynamic>)
                .toList()
                .map((e) => DeductionItem.fromJSON(e))
                .toList()
          : [],
      insurance: data['insurance'] != null
          ? (data['insurance'] as List<dynamic>)
                .toList()
                .map((e) => DeductionItem.fromJSON(e))
                .toList()
          : [],
      licence: data['licence'] != null
          ? LicenceModel.fromJSON(data['licence'])
          : null,
      id: data['_id'] ?? new DateTime.now().millisecondsSinceEpoch.toString(),
      chatToken: data['chatToken'],
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
