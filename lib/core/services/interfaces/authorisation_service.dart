enum AuthRequestResult {
  success,
  noInternet,
  wrongCredentials,
  unknownError,
}

abstract interface class AuthorisationService {
  /// Выполняет авторизацию на unn-portal и сохраняет данные авторизации
  ///
  /// [login]: логин на unn-portal, т.е. номер студенческого билета
  /// [password]: пароль
  ///
  /// Возращает результат авторизаци
  Future<AuthRequestResult> auth(String login, String password);

  bool get isAuthorised;
  String? get csrf;
  String? get sessionId;
}
