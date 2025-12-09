// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';

abstract interface class ProfileService {
  /// Получает профиль по id
  ///
  /// [userId]: id пользователя, по которому получается профиль
  ///
  /// Возвращает [StudentData] или [EmployeeData] - наследников [UserData] или null, если:
  ///   1. Не вышло получить ответ от портала
  ///   2. statusCode не равен 200
  ///   3. Не вышло декодировать ответ
  Future<UserData?> getProfile({required int userId});

  /// Получает профиль по bitrixId
  ///
  /// [bitrixId]: bitrixId пользователя, по которому сначала определяется userId, а затем запрашивается профиль
  ///
  /// Возвращает [StudentData] или [EmployeeData] — наследников [UserData], или null, если:
  ///   1. Не удалось получить userId по bitrixId (ошибка API, отсутствие id в ответе)
  ///   2. Не вышло получить профиль по найденному userId (ошибка API, некорректный ответ, ошибка декодирования)
  Future<UserData?> getProfileByBitrixId({required int bitrixId});

  /// Получает профиль по id автора поста или комменатрия
  ///
  /// [authorId]: id автора поста или комментария
  ///
  /// Возвращает [StudentData] или [EmployeeData] - наследников [UserData] или null, если:
  ///   1. [getProfileByBitrixId] вернул null
  Future<UserData?> getProfileByAuthorId({required int authorId});

  /// Получает профиль по id [UserDialog]
  ///
  /// [dialogId]: id диалога с пользователем
  ///
  /// Возвращает [StudentData] или [EmployeeData] - наследников [UserData] или null, если:
  ///   1. [getProfileByBitrixId] вернул null
  Future<UserData?> getProfileByDialogId({required int dialogId});
}
