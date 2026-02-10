class PopulatedDriverModel {
  String id;
  String email;
  String firstName;
  String lastName;
  PopulatedDriverModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });
  Map<String, dynamic> toJSON() {
    return {
      "_id": id,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
    };
  }

  factory PopulatedDriverModel.fromJSON(Map<String, dynamic> json) {
    return PopulatedDriverModel(
      id: json['_id'],
      email: json['email'] ?? '',
      lastName: json['lastName'] ?? '',
      firstName: json['firstName'] ?? '',
    );
  }
}
