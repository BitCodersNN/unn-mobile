import 'package:flutter/services.dart';
import 'package:unn_mobile/core/misc/auth/auth_request_result.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class AuthorizationRefreshServiceImpl implements AuthorizationRefreshService {
  final AuthDataProvider _authDataProvider;
  final UnnAuthorisationService _authorisationService;
  final StorageService _storage;
  final LoggerService _loggerService;

  AuthorizationRefreshServiceImpl(
    this._authDataProvider,
    this._authorisationService,
    this._storage,
    this._loggerService,
  );

  Future<bool> _userDataExistsInStorage() async {
    try {
      final AuthData authData = await _authDataProvider.getData();
      return !(authData.login == AuthData.getDefaultParameter() ||
          authData.login == AuthData.getDefaultParameter());
    } on PlatformException catch (error, stack) {
      _loggerService.logError(
        error,
        stack,
      );
      _storage.clear();
      return false;
    }
  }

  @override
  Future<AuthRequestResult?> refreshLogin() async {
    if (!await _userDataExistsInStorage()) {
      _authorisationService.logout();
      return null;
    }
    final AuthData authData = await _authDataProvider.getData();

    return await _authorisationService.auth(authData.login, authData.password);
  }
}
