// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/authorisation/auth_data.dart';
import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _AuthDataProviderKeys {
  static const _loginKey = 'login_key';
  static const _passwordKey = 'password_key';
}

class AuthorisationDataProviderImpl implements AuthDataProvider {
  final StorageService _storage;

  AuthorisationDataProviderImpl(this._storage);

  @override
  Future<AuthData> getData() async {
    final results = await Future.wait([
      _storage.read(key: _AuthDataProviderKeys._loginKey, secure: true),
      _storage.read(key: _AuthDataProviderKeys._passwordKey, secure: true),
    ]);

    final login = results[0] ?? AuthData.getDefaultParameter();
    final password = results[1] ?? AuthData.getDefaultParameter();

    return AuthData(login, password);
  }

  @override
  Future<void> saveData(AuthData authData) => Future.wait([
        _storage.write(
          key: _AuthDataProviderKeys._loginKey,
          value: authData.login,
          secure: true,
        ),
        _storage.write(
          key: _AuthDataProviderKeys._passwordKey,
          value: authData.password,
          secure: true,
        ),
      ]);

  @override
  Future<bool> isContained() async {
    final results = await Future.wait([
      _storage.containsKey(key: _AuthDataProviderKeys._loginKey, secure: true),
      _storage.containsKey(
        key: _AuthDataProviderKeys._passwordKey,
        secure: true,
      ),
    ]);
    return results.every((isPresent) => isPresent);
  }

  @override
  Future<void> removeData() => Future.wait([
        _storage.remove(key: _AuthDataProviderKeys._loginKey, secure: true),
        _storage.remove(key: _AuthDataProviderKeys._passwordKey, secure: true),
      ]);
}
