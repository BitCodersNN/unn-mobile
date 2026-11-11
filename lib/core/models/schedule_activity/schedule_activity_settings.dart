// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_mode.dart';

class _JsonKeys {
  static const mode = 'mode';
  static const beforeMinutes = 'beforeMinutes';
  static const initialMinutes = 'initialMinutes';
}

class ScheduleActivitySettings {
  static const minimumMinutes = 0;
  static const maximumMinutes = 60;

  final ScheduleActivityMode mode;
  final int beforeMinutes;
  final int initialMinutes;

  const ScheduleActivitySettings({
    this.mode = ScheduleActivityMode.disabled,
    this.beforeMinutes = 10,
    this.initialMinutes = 10,
  });

  Duration get notice => Duration(minutes: beforeMinutes);

  factory ScheduleActivitySettings.fromJson(JsonMap json) =>
      ScheduleActivitySettings(
        mode:
            ScheduleActivityMode.values
                .where((mode) => mode.key == json[_JsonKeys.mode])
                .firstOrNull ??
            ScheduleActivityMode.disabled,
        beforeMinutes: _minutes(json[_JsonKeys.beforeMinutes]),
        initialMinutes: _minutes(json[_JsonKeys.initialMinutes]),
      );

  ScheduleActivitySettings copyWith({
    ScheduleActivityMode? mode,
    int? beforeMinutes,
    int? initialMinutes,
  }) => ScheduleActivitySettings(
    mode: mode ?? this.mode,
    beforeMinutes: beforeMinutes ?? this.beforeMinutes,
    initialMinutes: initialMinutes ?? this.initialMinutes,
  );

  JsonMap toJson() => {
    _JsonKeys.mode: mode.key,
    _JsonKeys.beforeMinutes: beforeMinutes,
    _JsonKeys.initialMinutes: initialMinutes,
  };

  static int _minutes(Object? value) =>
      value is int && value >= minimumMinutes && value <= maximumMinutes
      ? value
      : 10;
}
