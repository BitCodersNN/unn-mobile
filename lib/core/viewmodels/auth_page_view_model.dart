import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class AuthPageViewModel extends BaseViewModel {
  final AuthDataProvider _authDataProvider =
      Injector.appInstance.get<AuthDataProvider>();
  final AuthorisationService _authorisationService =
      Injector.appInstance.get<AuthorisationService>();
  Future<bool> login(String user, String password) async {
    setState(ViewState.busy);
    _resetAuthError();
    var authResult = await _authorisationService.auth(user, password);
    switch (authResult) {
      case AuthRequestResult.success:
        break;
      case AuthRequestResult.noInternet:
        _setAuthError('Нет подключения к Интернету');
        break;
      case AuthRequestResult.wrongCredentials:
        _setAuthError('Логин или пароль неверны');
        break;
      case AuthRequestResult.unknownError:
        _setAuthError('Случилась неизвестная ошибка...');
        break;
    }
    if (authResult == AuthRequestResult.success) {
      await _authDataProvider.saveAuthData(AuthData(user, password));
    }
    setState(ViewState.idle);
    return authResult == AuthRequestResult.success;
  }

  bool _hasAuthError = false;
  bool get hasAuthError => _hasAuthError;

  String _authErrorText = '';
  String get authErrorText => _authErrorText;

  void _setAuthError(String text) {
    _hasAuthError = true;
    _authErrorText = text;
  }

  void _resetAuthError() {
    _hasAuthError = false;
    _authErrorText = '';
  }
}
