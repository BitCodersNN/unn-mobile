// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_settings.dart';

abstract interface class ScheduleActivitySettingsProvider {
  /// Читает сохранённые настройки отображения занятия.
  Future<ScheduleActivitySettings> load();

  /// Сохраняет настройки отображения занятия.
  Future<void> save(ScheduleActivitySettings settings);
}
