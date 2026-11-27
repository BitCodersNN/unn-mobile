// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math';

import 'package:unn_mobile/core/constants/schedule_cache_limits.dart';
import 'package:unn_mobile/core/misc/cache/lru_cache.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/models/schedule/offline_schedule.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_data.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_entry.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_key.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_configuration.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/offline_schedule_service.dart';

class OfflineScheduleServiceImpl implements OfflineScheduleService {
  final OfflineScheduleProvider _provider;
  Future<void> _pendingOperation = Future.value();

  OfflineScheduleServiceImpl(this._provider);

  @override
  Future<OfflineSchedule?> getSchedule(ScheduleCacheKey key) =>
      _enqueue(() => _getSchedule(key));

  Future<OfflineSchedule?> _getSchedule(ScheduleCacheKey key) async {
    final data = await _provider.getCache();
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
      await _provider.saveCache(
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
      _enqueue(() => _persist(update));

  Future<void> _persist(
    ScheduleCacheData Function(ScheduleCacheData) update,
  ) async {
    final data = update(await _provider.getCache());
    await _provider.saveCache(data);
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _pendingOperation.then((_) => operation());
    _pendingOperation = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
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
