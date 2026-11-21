// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';

class _JsonKeys {
  static const String ownerId = 'ownerId';
  static const String ownerLabel = 'ownerLabel';
  static const String type = 'type';
  static const String useRasp = 'useRasp';
}

class ScheduleWidgetConfiguration {
  final int ownerId;
  final String ownerLabel;
  final IdType type;
  final bool useRasp;

  const ScheduleWidgetConfiguration({
    required this.ownerId,
    required this.ownerLabel,
    required this.type,
    required this.useRasp,
  });

  factory ScheduleWidgetConfiguration.fromJson(JsonMap json) =>
      ScheduleWidgetConfiguration(
        ownerId: json[_JsonKeys.ownerId]! as int,
        ownerLabel: json[_JsonKeys.ownerLabel]! as String,
        type: IdType.values.byName(json[_JsonKeys.type]! as String),
        useRasp: json[_JsonKeys.useRasp]! as bool,
      );

  JsonMap toJson() => {
    _JsonKeys.ownerId: ownerId,
    _JsonKeys.ownerLabel: ownerLabel,
    _JsonKeys.type: type.name,
    _JsonKeys.useRasp: useRasp,
  };
}
