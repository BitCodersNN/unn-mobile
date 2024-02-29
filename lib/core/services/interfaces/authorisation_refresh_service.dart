import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';

abstract interface class AuthorisationRefreshService {
  /// Если логин и пароль есть в хранилище, то авторизует пользователя
  ///
  /// Возвращает результат авторизации или 'null', если данных пользователя нет в хранилище
  Future<AuthRequestResult?> refreshLogin();
}
