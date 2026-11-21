// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';

class _ScheduleWidgetLessonJsonKeys {
  static const String title = 'title';
  static const String type = 'type';
  static const String location = 'location';
  static const String lecturer = 'lecturer';
  static const String start = 'start';
  static const String end = 'end';
  static const String accentColor = 'accentColor';
  static const String typeKey = 'typeKey';
}

class ScheduleWidgetLesson {
  final String title;
  final String type;
  final String location;
  final String lecturer;
  final DateTime start;
  final DateTime end;
  final int? accentColor;
  final String? typeKey;

  const ScheduleWidgetLesson({
    required this.title,
    required this.type,
    required this.location,
    required this.lecturer,
    required this.start,
    required this.end,
    this.accentColor,
    this.typeKey,
  });

  factory ScheduleWidgetLesson.fromSubject(
    Subject subject, {
    int? accentColor,
  }) => ScheduleWidgetLesson(
    accentColor: accentColor,
    typeKey: subject.subjectTypeEnum.name,
    title: subject.name,
    type: subject.subjectType,
    location: [
      subject.address.auditorium,
      subject.address.building,
    ].where((part) => part.trim().isNotEmpty).join(' / '),
    lecturer: subject.lecturer,
    start: subject.dateTimeRange.start,
    end: subject.dateTimeRange.end,
  );

  factory ScheduleWidgetLesson.fromJson(JsonMap json) => ScheduleWidgetLesson(
    accentColor: json[_ScheduleWidgetLessonJsonKeys.accentColor] as int?,
    typeKey: json[_ScheduleWidgetLessonJsonKeys.typeKey] as String?,
    title: json[_ScheduleWidgetLessonJsonKeys.title]! as String,
    type: json[_ScheduleWidgetLessonJsonKeys.type]! as String,
    location: json[_ScheduleWidgetLessonJsonKeys.location]! as String,
    lecturer: json[_ScheduleWidgetLessonJsonKeys.lecturer]! as String,
    start: DateTime.fromMillisecondsSinceEpoch(
      json[_ScheduleWidgetLessonJsonKeys.start]! as int,
    ),
    end: DateTime.fromMillisecondsSinceEpoch(
      json[_ScheduleWidgetLessonJsonKeys.end]! as int,
    ),
  );

  JsonMap toJson() => {
    _ScheduleWidgetLessonJsonKeys.title: title,
    _ScheduleWidgetLessonJsonKeys.type: type,
    _ScheduleWidgetLessonJsonKeys.location: location,
    _ScheduleWidgetLessonJsonKeys.lecturer: lecturer,
    _ScheduleWidgetLessonJsonKeys.start: start.millisecondsSinceEpoch,
    _ScheduleWidgetLessonJsonKeys.end: end.millisecondsSinceEpoch,
    if (typeKey != null) _ScheduleWidgetLessonJsonKeys.typeKey: typeKey,
    if (accentColor != null)
      _ScheduleWidgetLessonJsonKeys.accentColor: accentColor,
  };
}
