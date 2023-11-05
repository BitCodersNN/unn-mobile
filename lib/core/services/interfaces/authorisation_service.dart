
enum AuthRequestResult {
  success,
  noInternet,
  wrongCredentials,
  unknownError,
}

abstract interface class AuthorisationService {

  Future<AuthRequestResult> auth(String login, String password);

  bool get isAuthorised;
  String? get csrf;
  String? get sessionId;

}
