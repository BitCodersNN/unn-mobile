// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/schedule/offline_schedule.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_key.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_configuration.dart';

abstract interface class OfflineScheduleProvider {
  /// Получает сохранённую неделю для выбранного пользователя и источника.
  Future<OfflineSchedule?> getSchedule(ScheduleCacheKey key);

  /// Сохраняет неделю, не заменяя кэш других недель и результатов поиска.
  Future<void> saveSchedule(ScheduleCacheKey key, OfflineSchedule schedule);

  /// Сохраняет несколько недель одним обновлением общего хранилища.
  Future<void> saveSchedules(Map<ScheduleCacheKey, OfflineSchedule> schedules);

  /// Выбирает расписание виджета; null отключает его отображение.
  Future<void> configureWidget(ScheduleWidgetConfiguration? configuration);
}
