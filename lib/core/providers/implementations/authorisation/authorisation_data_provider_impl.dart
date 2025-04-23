// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';
import 'package:unn_mobile/core/models/authorisation/auth_data.dart';

class _AuthDataProviderKeys {
  static const _loginKey = 'login_key';
  static const _passwotdKey = 'password_key';
}

class AuthorisationDataProviderImpl implements AuthDataProvider {
  final StorageService _storage;

  AuthorisationDataProviderImpl(this._storage);

  @override
  Future<AuthData> getData() async {
    final login = await _storage.read(
          key: _AuthDataProviderKeys._loginKey,
          secure: true,
        ) ??
        AuthData.getDefaultParameter();
    final password = await _storage.read(
          key: _AuthDataProviderKeys._passwotdKey,
          secure: true,
        ) ??
        AuthData.getDefaultParameter();

    return AuthData(login, password);
  }

  @override
  Future<void> saveData(AuthData authData) async {
    await _storage.write(
      key: _AuthDataProviderKeys._loginKey,
      value: authData.login,
      secure: true,
    );
    await _storage.write(
      key: _AuthDataProviderKeys._passwotdKey,
      value: authData.password,
      secure: true,
    );
  }

  @override
  Future<bool> isContained() async {
    return (await _storage.containsKey(
          key: _AuthDataProviderKeys._loginKey,
          secure: true,
        ) &&
        await _storage.containsKey(
          key: _AuthDataProviderKeys._passwotdKey,
          secure: true,
        ));
  }
}
