import 'package:genesis/models/company_settings.dart';

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
}
