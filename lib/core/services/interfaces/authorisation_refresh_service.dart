part of '../library.dart';

abstract interface class AuthorizationRefreshService {
  /// Если логин и пароль есть в хранилище, то авторизует пользователя
  ///
  /// Выбрасывает те же исключения, что и [AuthorizationService.auth]
  ///
  /// Возвращает результат авторизации или 'null', если данных пользователя нет в хранилище
  Future<AuthRequestResult?> refreshLogin();
}
