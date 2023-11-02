import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';


abstract interface class InitializingApplicationService {
  Future<bool> isUserDataExistsInStorage();
  Future<AuthRequestResult> isAuthorized();
}