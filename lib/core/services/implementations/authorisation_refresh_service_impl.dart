part of 'library.dart';

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
    if (!await _userDataExistsInStorage()) {
      _authorisationService.logout();
      return null;
    }
    final AuthData authData = await _authDataProvider.getData();

    return await _authorisationService.auth(authData.login, authData.password);
  }
}
