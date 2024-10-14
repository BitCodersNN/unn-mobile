part of '../library.dart';

abstract interface class AuthDataProvider implements DataProvider<AuthData> {
  /// Получает данные, необходимые для авторизации из хранилища
  ///
  /// Возрващает объект AuthData, содержащий логин и пароль пользователя
  @override
  Future<AuthData> getData();

  /// Сохраняет данные, необходимые для авторизации в хранилище
  @override
  Future<void> saveData(AuthData authData);

  /// Проверяет наличие логина и пароля пользователя в хранилище
  @override
  Future<bool> isContained();
}
