import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';

class AuthDataProviderKeys{
  static const _loginKey = 'login_key';
  static const _passwotdKey = 'password_key';
}

class AuthDataProvider {
  final _securityStorage = Injector.appInstance.get<StorageService>();

  Future<AuthData> getAuthData() async {
    var login = await _securityStorage.read(key: AuthDataProviderKeys._loginKey, secure: true) ?? AuthData.getDefaultParameter();
    var password = await _securityStorage.read(key: AuthDataProviderKeys._passwotdKey, secure: true) ?? AuthData.getDefaultParameter();

    return AuthData(login, password);
  }

  Future<void> saveAuthData(AuthData authData) async{
    await _securityStorage.write(key: AuthDataProviderKeys._loginKey, value: authData.login, secure: true);
    await _securityStorage.write(key: AuthDataProviderKeys._passwotdKey, value: authData.password, secure: true);
  }
}