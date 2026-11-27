// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/schedule/schedule_cache_data.dart';

abstract interface class OfflineScheduleProvider {
  /// Читает сохранённый кэш расписания и конфигурацию виджета.
  Future<ScheduleCacheData> getCache();

  /// Сохраняет кэш расписания и при необходимости обновляет нативные виджеты.
  Future<void> saveCache(ScheduleCacheData data, {bool refreshWidgets = true});
}
