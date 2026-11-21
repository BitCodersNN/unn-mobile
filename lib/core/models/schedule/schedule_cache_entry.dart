// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/offline_schedule.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_key.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';

class _JsonKeys {
  static const String ownerId = 'ownerId';
  static const String type = 'type';
  static const String id = 'id';
  static const String useRasp = 'useRasp';
  static const String schedule = 'schedule';
}

class ScheduleCacheEntry {
  final ScheduleCacheKey key;
  final OfflineSchedule schedule;

  const ScheduleCacheEntry(this.key, this.schedule);

  factory ScheduleCacheEntry.fromJson(JsonMap json) {
    final schedule = OfflineSchedule.fromJson(
      json[_JsonKeys.schedule]! as JsonMap,
    );
    return ScheduleCacheEntry((
      ownerId: json[_JsonKeys.ownerId]! as int,
      type: IdType.values.byName(json[_JsonKeys.type]! as String),
      id: json[_JsonKeys.id] as String?,
      useRasp: json[_JsonKeys.useRasp]! as bool,
      weekStart: schedule.week.start,
    ), schedule);
  }

  JsonMap toJson() => {
    _JsonKeys.ownerId: key.ownerId,
    _JsonKeys.type: key.type.name,
    _JsonKeys.id: key.id,
    _JsonKeys.useRasp: key.useRasp,
    _JsonKeys.schedule: schedule.toJson(),
  };
}
