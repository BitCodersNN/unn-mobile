// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';
import 'dart:math';

import 'package:unn_mobile/core/constants/schedule_cache_limits.dart';
import 'package:unn_mobile/core/misc/cache/lru_cache.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/offline_schedule.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_data.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_entry.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_key.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_configuration.dart';
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
  Future<void> _pendingOperation = Future.value();

  OfflineScheduleProviderImpl(this._storage, this._logger, this._platform);

  @override
  Future<OfflineSchedule?> getSchedule(ScheduleCacheKey key) =>
      _enqueue(() => _getSchedule(key));

  Future<OfflineSchedule?> _getSchedule(ScheduleCacheKey key) async {
    final data = await _readSafely();
    final cache = LRUCache<ScheduleCacheKey, ScheduleCacheEntry>(
      max(ScheduleCacheLimits.maxEntries, data.entries.length),
    );
    for (final entry in data.entries) {
      cache.save(entry.key, entry);
    }
    final entry = cache.get(key);
    if (entry == null) {
      return null;
    }
    if (data.entries.last.key != key) {
      await _writeSafely(
        ScheduleCacheData(
          widget: data.widget,
          entries: _trim(
            cache.entries.map((entry) => entry.value).toList(),
            data.widget,
          ),
        ),
        refreshWidgets: false,
      );
    }
    return entry.schedule;
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _pendingOperation.then((_) => operation());
    _pendingOperation = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<ScheduleCacheData> _readSafely() async {
    try {
      return await _read();
    } catch (error, stack) {
      _logger.logError(error, stack);
      return ScheduleCacheData();
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

  @override
  Future<void> saveSchedule(ScheduleCacheKey key, OfflineSchedule schedule) =>
      saveSchedules({key: schedule});

  @override
  Future<void> saveSchedules(Map<ScheduleCacheKey, OfflineSchedule> schedules) {
    final snapshot = Map<ScheduleCacheKey, OfflineSchedule>.of(schedules);
    return _update(
      (data) => ScheduleCacheData(
        widget: data.widget,
        entries: _trim([
          ...data.entries.where((entry) => !snapshot.containsKey(entry.key)),
          for (final entry in snapshot.entries)
            ScheduleCacheEntry(entry.key, entry.value),
        ], data.widget),
      ),
    );
  }

  @override
  Future<void> configureWidget(ScheduleWidgetConfiguration? configuration) =>
      _update(
        (data) =>
            ScheduleCacheData(widget: configuration, entries: data.entries),
      );

  Future<void> _update(ScheduleCacheData Function(ScheduleCacheData) update) =>
      _enqueue(() => _updateSafely(update));

  Future<void> _updateSafely(
    ScheduleCacheData Function(ScheduleCacheData) update,
  ) async {
    try {
      await _persist(update);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  Future<void> _persist(
    ScheduleCacheData Function(ScheduleCacheData) update,
  ) async {
    final data = update(await _readSafely());
    await _writeData(data);
  }

  Future<void> _writeSafely(
    ScheduleCacheData data, {
    required bool refreshWidgets,
  }) async {
    try {
      await _writeData(data, refreshWidgets: refreshWidgets);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  Future<void> _writeData(
    ScheduleCacheData data, {
    bool refreshWidgets = true,
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

  List<ScheduleCacheEntry> _trim(
    List<ScheduleCacheEntry> entries,
    ScheduleWidgetConfiguration? widget,
  ) {
    if (entries.length <= ScheduleCacheLimits.maxEntries) {
      return entries;
    }
    final week = WeekRange(weekOffset: 0);
    bool isWidgetWeek(ScheduleCacheEntry entry) =>
        widget != null &&
        entry.key.ownerId == widget.ownerId &&
        entry.key.type == widget.type &&
        entry.key.useRasp == widget.useRasp &&
        entry.key.id == null &&
        (entry.key.weekStart == week.start ||
            entry.key.weekStart ==
                WeekRange(weekOffset: 1, reference: week.reference).start);
    final protectedKeys = entries
        .where(isWidgetWeek)
        .map((entry) => entry.key)
        .toSet();
    final cache = LRUCache<ScheduleCacheKey, ScheduleCacheEntry>(
      ScheduleCacheLimits.maxEntries - protectedKeys.length,
    );
    for (final entry in entries) {
      if (!protectedKeys.contains(entry.key)) {
        cache.save(entry.key, entry);
      }
    }
    final retainedKeys = {
      ...protectedKeys,
      ...cache.entries.map((entry) => entry.key),
    };
    return entries.where((entry) => retainedKeys.contains(entry.key)).toList();
  }
}
