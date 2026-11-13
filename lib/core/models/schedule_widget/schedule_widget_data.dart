// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_lesson.dart';

class _ScheduleWidgetDataJsonKeys {
  static const String version = 'version';
  static const String ownerId = 'ownerId';
  static const String ownerLabel = 'ownerLabel';
  static const String updatedAt = 'updatedAt';
  static const String validFrom = 'validFrom';
  static const String validUntil = 'validUntil';
  static const String lessons = 'lessons';
  static const String useRasp = 'useRasp';
}

class ScheduleWidgetData {
  static const int schemaVersion = 1;

  final int ownerId;
  final bool? useRasp;
  final String ownerLabel;
  final DateTime updatedAt;
  final DateTime validFrom;
  final DateTime validUntil;
  final List<ScheduleWidgetLesson> lessons;

  ScheduleWidgetData({
    required this.ownerId,
    required this.ownerLabel,
    required this.updatedAt,
    required this.validFrom,
    required this.validUntil,
    required Iterable<ScheduleWidgetLesson> lessons,
    this.useRasp,
  }) : lessons = List.unmodifiable(
         lessons.toList()..sort((a, b) => a.start.compareTo(b.start)),
       );

  factory ScheduleWidgetData.fromJson(JsonMap json) {
    if (json[_ScheduleWidgetDataJsonKeys.version] != schemaVersion) {
      throw const FormatException('Unsupported schedule widget data version');
    }
    return ScheduleWidgetData(
      useRasp: json[_ScheduleWidgetDataJsonKeys.useRasp] as bool?,
      ownerId: json[_ScheduleWidgetDataJsonKeys.ownerId]! as int,
      ownerLabel: json[_ScheduleWidgetDataJsonKeys.ownerLabel]! as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json[_ScheduleWidgetDataJsonKeys.updatedAt]! as int,
      ),
      validFrom: DateTime.fromMillisecondsSinceEpoch(
        json[_ScheduleWidgetDataJsonKeys.validFrom]! as int,
      ),
      validUntil: DateTime.fromMillisecondsSinceEpoch(
        json[_ScheduleWidgetDataJsonKeys.validUntil]! as int,
      ),
      lessons: (json[_ScheduleWidgetDataJsonKeys.lessons]! as List<Object?>)
          .map((lesson) => ScheduleWidgetLesson.fromJson(lesson! as JsonMap)),
    );
  }

  JsonMap toJson() => {
    _ScheduleWidgetDataJsonKeys.version: schemaVersion,
    _ScheduleWidgetDataJsonKeys.ownerId: ownerId,
    _ScheduleWidgetDataJsonKeys.useRasp: useRasp,
    _ScheduleWidgetDataJsonKeys.ownerLabel: ownerLabel,
    _ScheduleWidgetDataJsonKeys.updatedAt: updatedAt.millisecondsSinceEpoch,
    _ScheduleWidgetDataJsonKeys.validFrom: validFrom.millisecondsSinceEpoch,
    _ScheduleWidgetDataJsonKeys.validUntil: validUntil.millisecondsSinceEpoch,
    _ScheduleWidgetDataJsonKeys.lessons: lessons
        .map((lesson) => lesson.toJson())
        .toList(),
  };
}
