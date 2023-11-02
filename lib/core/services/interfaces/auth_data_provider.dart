import 'package:unn_mobile/core/models/auth_data.dart';


abstract interface class AuthDataProvider {
  Future<AuthData> getAuthData();
  Future<void> saveAuthData(AuthData authData);
}