import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';

class AuthorisationServiceImpl implements AuthorisationService {  @override
  Future<AuthRequestResult> auth(String login, String password) {
    // TODO: implement auth
    throw UnimplementedError();
  }

  @override
  // TODO: implement csrf
  String? get csrf => throw UnimplementedError();

  @override
  // TODO: implement isAuthorised
  bool get isAuthorised => throw UnimplementedError();

  @override
  // TODO: implement sessionId
  String? get sessionId => throw UnimplementedError();
}
