import 'package:get_storage/get_storage.dart';

class TokenModel {
  final String accessToken;
  final String refreshToken;
  TokenModel({required this.accessToken, required this.refreshToken});
  factory TokenModel.fromJSON(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  String get accessTokenHeader => 'Bearer $accessToken';
  String get refreshTokenHeader => 'Bearer $refreshToken';

  factory TokenModel.fromStorage() {
    final storage = GetStorage();
    final accessToken = storage.read('accessToken') ?? "";
    final refreshToken = storage.read('refreshToken') ?? "";
    return TokenModel(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> saveToStorage() async {
    final storage = GetStorage();
    await storage.write('accessToken', accessToken);
    await storage.write('refreshToken', refreshToken);
  }

  static Future<void> clearStorage() async {
    final storage = GetStorage();
    await storage.remove('accessToken');
    await storage.remove('refreshToken');
  }
}
