// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_settings.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class ScheduleActivitySettingsProvider
    implements DataProvider<ScheduleActivitySettings> {
  /// Читает сохранённые настройки или возвращает значения по умолчанию.
  @override
  Future<ScheduleActivitySettings> getData();

  /// Сохраняет настройки отображения занятия.
  @override
  Future<void> saveData(ScheduleActivitySettings settings);
}
