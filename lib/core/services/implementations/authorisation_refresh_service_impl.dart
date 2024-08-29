import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class AuthorizationRefreshServiceImpl implements AuthorizationRefreshService {
  final AuthDataProvider authDataProvider;
  final AuthorizationService authorisationService;
  final StorageService storage;

  AuthorizationRefreshServiceImpl(
    this.authDataProvider,
    this.authorisationService,
    this.storage,
  );

  Future<bool> _userDataExistsInStorage() async {
    try {
      final AuthData authData = await authDataProvider.getData();
      return !(authData.login == AuthData.getDefaultParameter() ||
          authData.login == AuthData.getDefaultParameter());
    } on PlatformException catch (error) {
      await FirebaseCrashlytics.instance.log(
        'Exception: ${error.message}; code: ${error.code}\nStackTrace: \n${error.stacktrace}',
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
