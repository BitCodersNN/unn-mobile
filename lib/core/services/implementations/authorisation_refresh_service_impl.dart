import 'package:flutter/services.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class AuthorizationRefreshServiceImpl implements AuthorizationRefreshService {
  final AuthDataProvider authDataProvider;
  final AuthorizationService authorisationService;
  final StorageService storage;
  final LoggerService loggerService;

  AuthorizationRefreshServiceImpl(
    this.authDataProvider,
    this.authorisationService,
    this.storage,
    this.loggerService,
  );

  Future<bool> _userDataExistsInStorage() async {
    try {
      final AuthData authData = await authDataProvider.getData();
      return !(authData.login == AuthData.getDefaultParameter() ||
          authData.login == AuthData.getDefaultParameter());
    } on PlatformException catch (error, stack) {
      loggerService.logError(
        error,
        stack,
      );
      storage.clear();
      return false;
    }
  }

  @override
  Future<AuthRequestResult?> refreshLogin() async {
    if (!await _userDataExistsInStorage()) {
      return null;
    }
    final AuthData authData = await authDataProvider.getData();

    return await authorisationService.auth(authData.login, authData.password);
  }
}
