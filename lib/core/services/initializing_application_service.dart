import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/initializing_application_service.dart';


class InitializingApplicationServiceImpl implements InitializingApplicationService {
  final _authDataProvider =  Injector.appInstance.get<AuthDataProvider>();
  final _authorisationService = Injector.appInstance.get<AuthorisationService>();

  @override
  Future<bool> isUserDataExistsInStorage() async{
    AuthData authData =  await _authDataProvider.getAuthData();
    return !(authData.login == AuthData.getDefaultParameter() || authData.login == AuthData.getDefaultParameter());
  }

  @override
  Future<AuthRequestResult> isAuthorized() async{
    if (await isUserDataExistsInStorage()) {
      throw Exception('No authorization data');
    }
    AuthData authData =  await _authDataProvider.getAuthData();
    return _authorisationService.auth(authData.login, authData.password);
  }
}