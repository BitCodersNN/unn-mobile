import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/models/profile/student_data.dart';
import 'package:unn_mobile/core/models/profile/employee_data.dart';

abstract interface class ProfileService {
  /// Получает id профиля по id автора поста
  ///
  /// [authorId]: id автора поста
  ///
  /// Возвращает [int] или null, если:
  ///   1. Не вышло получить ответ от портала
  ///   2. statusCode не равен 200
  ///   3. Не вышло декодировать ответ
  Future<int?> getProfileIdByBitrixID({required int bitrixID});

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
  ///   1. [getProfileIdByBitrixID] вернул null
  ///   2. [getProfile] вернул null
  Future<UserData?> getProfileByAuthorIdFromPost({required int authorId});
}
