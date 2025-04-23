// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/models/profile/student_data.dart';
import 'package:unn_mobile/core/models/profile/employee_data.dart';

abstract interface class ProfileOfCurrentUserService {
  /// Получает профиль текущего пользователя
  ///
  /// Возвращает [StudentData] или [EmployeeData] - наследников [UserData] или null,
  /// если не вышло получить ответ от портала или statusCode не равен 200
  Future<UserData?> getProfileOfCurrentUser();
}
