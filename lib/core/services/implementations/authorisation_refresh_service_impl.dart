import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/models/auth_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';


class AuthorisationRefreshServiceImpl implements AuthorisationRefreshService {
  final _authDataProvider =  Injector.appInstance.get<AuthDataProvider>();
  final _authorisationService = Injector.appInstance.get<AuthorisationService>();

  Future<bool> _userDataExistsInStorage() async{
    AuthData authData =  await _authDataProvider.getData();
    return !(authData.login == AuthData.getDefaultParameter() || authData.login == AuthData.getDefaultParameter());
  }

  @override
  Future<AuthRequestResult?> refreshLogin() async{
    if (!await _userDataExistsInStorage()) {
      return null;
    }
    AuthData authData =  await _authDataProvider.getData();
    return _authorisationService.auth(authData.login, authData.password);
  }
}