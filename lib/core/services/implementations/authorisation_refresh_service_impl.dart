import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class AuthorisationRefreshServiceImpl implements AuthorisationRefreshService {
  final _loggerService = Injector.appInstance.get<LoggerService>();
  final _authDataProvider = Injector.appInstance.get<AuthDataProvider>();
  final _authorisationService =
      Injector.appInstance.get<AuthorisationService>();
  final _storage = Injector.appInstance.get<StorageService>();

  Future<bool> _userDataExistsInStorage() async {
    try {
      final AuthData authData = await _authDataProvider.getData();
      return !(authData.login == AuthData.getDefaultParameter() ||
          authData.login == AuthData.getDefaultParameter());
    } on PlatformException catch (error, stack) {
      _loggerService.logError(
        error,
        stack,
        fatal: false,
      );
      _storage.clear();
      return false;
    }
  }

  @override
  Future<AuthRequestResult?> refreshLogin() async {
    if (!await _userDataExistsInStorage()) {
      return null;
    }
    final AuthData authData = await _authDataProvider.getData();

    return await _authorisationService.auth(authData.login, authData.password);
  }
}
