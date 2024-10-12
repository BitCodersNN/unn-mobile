part of '../library.dart';

abstract interface class GettingProfileOfCurrentUser {
  /// Получает профиль текущего пользователя
  ///
  /// Возвращает [StudentData] или [EmployeeData] - наследников [UserData] или null,
  /// если не вышло получить ответ от портала или statusCode не равен 200
  Future<UserData?> getProfileOfCurrentUser();
}
