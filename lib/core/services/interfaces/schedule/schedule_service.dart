// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';

abstract interface class ScheduleService {
  /// Получение расписания
  ///
  /// [scheduleFilter]: Фильтр, по которому происходит получение расписания
  ///
  /// Возвращает список предметов или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<List<Subject>?> getSchedule(ScheduleFilter scheduleFilter);

  /// Получение расписания текущего пользователя
  ///
  /// [date]: Дата, по которой определяется неделя
  /// [login]: Логин пользователя
  ///
  /// Возвращает список предметов или 'null', если не вышло получить ответ от портала или statusCode не равен 200
  Future<List<Subject>?> getCurrentUserSchedule(DateTime date, String login);
}
