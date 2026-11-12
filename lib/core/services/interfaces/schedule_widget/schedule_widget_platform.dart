// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_data.dart';

abstract interface class ScheduleWidgetPlatform {
  bool get isSupported;

  /// Читает общий кэш, доступный приложению и нативным виджетам.
  Future<ScheduleCacheData?> readCache();

  /// Сохраняет общий кэш и обновляет нативные виджеты.
  Future<void> writeCache(ScheduleCacheData data, {bool refreshWidgets = true});
  Future<bool> consumeLaunch();
  void setOpenHandler(VoidCallback? handler);
}
