import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/employee_data.dart';

abstract interface class GettingProfile {
  /// Получает id профиля по id автора поста
  ///
  /// [authorId]: id автора поста
  ///
  /// Возвращает [int] или null, если:
  ///   1. Не вышло получить ответ от портала
  ///   2. statusCode не равен 200
  ///   3. Не вышло декодировать ответ
  Future<int?> getProfileIdByAuthorIdFromPost({required int authorId});

  /// Получает профиль по id
  ///
  /// [userId]: id пользователя, по которому получается профиль
  ///
  /// Возвращает [StudentData] или [EmployeeData] - наследников [UserData] или null, если:
  ///   1. Не вышло получить ответ от портала
  ///   2. statusCode не равен 200
  ///   3. Не вышло декодировать ответ
  Future<UserData?> getProfile({required int userId});

  /// Получает профиль по id автора поста
  ///
  /// [authorId]: id автора поста
  ///
  /// Возвращает [StudentData] или [EmployeeData] - наследников [UserData] или null, если:
  ///   1. [getProfileIdByAuthorIdFromPost] вернул null
  ///   2. [getProfile] вернул null
  Future<UserData?> getProfileByAuthorIdFromPost({required int authorId});
}
