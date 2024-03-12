import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/custom_errors/auth_error_messages.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class AuthPageViewModel extends BaseViewModel {
  final AuthDataProvider _authDataProvider =
      Injector.appInstance.get<AuthDataProvider>();
  final AuthorisationService _authorisationService =
      Injector.appInstance.get<AuthorisationService>();

  bool _hasAuthError = false;
  bool get hasAuthError => _hasAuthError;

  String _authErrorText = '';
  String get authErrorText => _authErrorText;

  Future<bool> login(String user, String password) async {
    setState(ViewState.busy);
    _resetAuthError();

    late AuthRequestResult authResult;

    try {
      authResult = await _authorisationService.auth(user, password);
    } catch (e, stacktrace) {
      await FirebaseCrashlytics.instance
          .log("Exception: $e\nStackTrace: \n$stacktrace");
    } finally {
      if (authResult == AuthRequestResult.success) {
        await _authDataProvider.saveData(AuthData(user, password));
      } else {
        _setAuthError(authResult.errorMessage);
      }
    }

    setState(ViewState.idle);
    return authResult == AuthRequestResult.success;
  }

  void _setAuthError(String text) {
    _hasAuthError = true;
    _authErrorText = text;
  }

  void _resetAuthError() {
    _hasAuthError = false;
    _authErrorText = '';
  }
}
