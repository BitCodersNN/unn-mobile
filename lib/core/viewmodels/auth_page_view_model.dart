part of 'package:unn_mobile/core/viewmodels/library.dart';

class AuthPageViewModel extends BaseViewModel {
  final AuthDataProvider _authDataProvider;
  final AuthorizationService _authorisationService;
  final LoggerService _loggerService;

  bool _hasAuthError = false;

  String _authErrorText = '';

  AuthPageViewModel(
    this._authDataProvider,
    this._authorisationService,
    this._loggerService,
  );

  String get authErrorText => _authErrorText;
  bool get hasAuthError => _hasAuthError;

  Future<bool> login(String user, String password) async {
    setState(ViewState.busy);
    _resetAuthError();

    AuthRequestResult? authResult;

    try {
      authResult = await _authorisationService.auth(user, password);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    if (authResult == AuthRequestResult.success) {
      await _authDataProvider.saveData(AuthData(user, password));
    } else {
      authResult != null
          ? _setAuthError(text: authResult.errorMessage)
          : _setAuthError();
    }

    setState(ViewState.idle);
    return authResult == AuthRequestResult.success;
  }

  void _resetAuthError() {
    _hasAuthError = false;
    _authErrorText = '';
  }

  void _setAuthError({String text = 'Неизвестная ошибка'}) {
    _hasAuthError = true;
    _authErrorText = text;
  }
}
