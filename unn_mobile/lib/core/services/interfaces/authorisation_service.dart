
enum AuthRequestResult {
  success,
  noInternet,
  wrongCredentials,
  unknownError,
}

abstract class AuthorisationServiceInterface {
  Future<bool> checkSessionId(String sessionId);

  Future<bool> checkCsrf(String csrf);

  Future<AuthRequestResult> auth(String login, String password);

  bool get isAuthenticated;
  String? get csrf;
  String? get sessionId;
}
