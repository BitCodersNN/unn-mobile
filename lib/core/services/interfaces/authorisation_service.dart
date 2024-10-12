part of '../library.dart';

enum AuthRequestResult {
  success,
  noInternet,
  wrongCredentials,
  unknown,
}

abstract interface class AuthorizationService extends Listenable {
  /// Выполняет авторизацию на unn-portal и сохраняет данные авторизации
  ///
  /// [login]: логин на unn-portal, т.е. номер студенческого билета
  /// [password]: пароль
  ///
  /// Выбрасывает исключения:
  ///   1. [SessionCookieException] - если session cookie имеет значени null
  ///   2. [CsrfValueException] - если csrf value имеет значени null
  ///   3. [Exception] - если возникло непредвиденное исключение
  ///
  /// Возвращает результат авторизаци
  Future<AuthRequestResult> auth(String login, String password);

  void logout();

  bool get isAuthorised;
  String? get csrf;
  String? get sessionId;
  String? get guestId;
}
