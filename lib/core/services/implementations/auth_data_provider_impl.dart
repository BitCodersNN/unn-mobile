import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';

class _AuthDataProviderKeys {
  static const _loginKey = 'login_key';
  static const _passwotdKey = 'password_key';
}

class AuthDataProviderImpl implements AuthDataProvider {
  final _securityStorage = Injector.appInstance.get<StorageService>();

  @override
  Future<AuthData> getData() async {
    final login = await _securityStorage.read(
          key: _AuthDataProviderKeys._loginKey,
          secure: true,
        ) ??
        AuthData.getDefaultParameter();
    final password = await _securityStorage.read(
          key: _AuthDataProviderKeys._passwotdKey,
          secure: true,
        ) ??
        AuthData.getDefaultParameter();

    return AuthData(login, password);
  }

  @override
  Future<void> saveData(AuthData authData) async {
    await _securityStorage.write(
      key: _AuthDataProviderKeys._loginKey,
      value: authData.login,
      secure: true,
    );
    await _securityStorage.write(
      key: _AuthDataProviderKeys._passwotdKey,
      value: authData.password,
      secure: true,
    );
  }

  @override
  Future<bool> isContained() async {
    return (await _securityStorage.containsKey(
          key: _AuthDataProviderKeys._loginKey,
        ) &&
        await _securityStorage.containsKey(
          key: _AuthDataProviderKeys._passwotdKey,
        ));
  }
}
