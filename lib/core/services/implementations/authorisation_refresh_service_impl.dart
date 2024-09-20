import 'package:flutter/services.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/loading_page_config.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/logo_uploader_impl.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class AuthorizationRefreshServiceImpl implements AuthorizationRefreshService {
  final AuthDataProvider _authDataProvider;
  final AuthorizationService _authorisationService;
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
    final x = await LoadingPageConfigImpl(_loggerService).getLoadingPages();
    final imagePaths = x!.map((model) => model.imagePath).toList();
    final y = await LogoUploaderImpl(_loggerService).downloadFiles(imagePaths);

    if (!await _userDataExistsInStorage()) {
      return null;
    }
    final AuthData authData = await _authDataProvider.getData();

    return await _authorisationService.auth(authData.login, authData.password);
  }
}
