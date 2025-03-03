import 'package:unn_mobile/core/misc/auth/auth_request_result.dart';
import 'package:unn_mobile/core/misc/custom_errors/auth_error_messages.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class AuthPageViewModel extends BaseViewModel {
  final AuthDataProvider _authDataProvider;
  final UnnAuthorisationService _authorisationService;
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
