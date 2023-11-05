import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';


abstract interface class AuthorisationRefreshService {
  Future<AuthRequestResult?> refreshLogin();
}