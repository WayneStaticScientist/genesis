import 'package:genesis/models/company_settings.dart';
import 'package:get_storage/get_storage.dart';

class CompanyModel {
  final String owner;
  final String label;
  final String email;
  final String avatar;
  final String country;
  final CompanySettings settings;
  CompanyModel({
    required this.owner,
    required this.label,
    required this.email,
    required this.avatar,
    required this.country,
    required this.settings,
  });
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      owner: json['owner'] ?? '',
      label: json['label'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      country: json['country'] ?? '',
      settings: CompanySettings.fromJson(json['settings']),
    );
  }
  Map<String, dynamic> toJson() => {
    'owner': owner,
    'label': label,
    'email': email,
    'avatar': avatar,
    'country': country,
    'settings': settings.toJson(),
  };
  void saveToStorage() {
    GetStorage().write('company', toJson());
  }

  static CompanyModel? fromStorage() {
    final data = GetStorage().read('company');
    if (data != null) {
      return CompanyModel.fromJson(data);
    }
    return null;
  }
}
