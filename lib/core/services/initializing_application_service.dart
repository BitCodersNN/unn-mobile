import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/auth_data_provider.dart';


class InitializingApplicationService {
  final _authDataProvider = AuthDataProvider();
  final _authorisationProvider = Injector.appInstance.get<AuthorisationService>();

  Future<bool> isUserExists() async{
    AuthData authData =  await _authDataProvider.getAuthData();
    return !(authData.login == AuthData.getDefaultParameter() || authData.login == AuthData.getDefaultParameter());
  }

  Future<AuthRequestResult> isAuthorized() async{
    if (await isUserExists()) {
      throw Exception('No authorization data');
    }
    AuthData authData =  await _authDataProvider.getAuthData();
    return _authorisationProvider.auth(authData.login, authData.password);
  }
}