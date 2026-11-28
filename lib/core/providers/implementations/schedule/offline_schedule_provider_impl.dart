// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_data.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_platform.dart';

class _StorageKeys {
  static const String cache = 'schedule_cache';
  static const String previousWeeks = 'schedule_weeks';
  static const String previousSchedule = 'offline_schedule';
}

class OfflineScheduleProviderImpl implements OfflineScheduleProvider {
  final StorageService _storage;
  final LoggerService _logger;
  final ScheduleWidgetPlatform _platform;

  OfflineScheduleProviderImpl(this._storage, this._logger, this._platform);

  @override
  Future<ScheduleCacheData> getCache() async {
    try {
      return await _read();
    } catch (error, stack) {
      _logger.logError(error, stack);
      return ScheduleCacheData();
    }
  }

  @override
  Future<void> saveCache(
    ScheduleCacheData data, {
    bool refreshWidgets = true,
  }) async {
    try {
      await _write(data, refreshWidgets: refreshWidgets);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  Future<ScheduleCacheData> _read() async {
    if (_platform.isSupported) {
      return await _platform.readCache() ?? ScheduleCacheData();
    }
    final stored = await _storage.read(key: _StorageKeys.cache);
    return stored == null || stored.isEmpty
        ? ScheduleCacheData()
        : ScheduleCacheData.fromJson(jsonDecode(stored) as JsonMap);
  }

  Future<void> _write(
    ScheduleCacheData data, {
    required bool refreshWidgets,
  }) async {
    if (_platform.isSupported) {
      await _platform.writeCache(data, refreshWidgets: refreshWidgets);
      await _storage.remove(key: _StorageKeys.cache);
    } else {
      await _storage.write(
        key: _StorageKeys.cache,
        value: jsonEncode(data.toJson()),
      );
    }
    await _storage.remove(key: _StorageKeys.previousWeeks);
    await _storage.remove(key: _StorageKeys.previousSchedule);
  }
}
