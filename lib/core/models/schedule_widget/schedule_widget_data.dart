// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';

class ScheduleWidgetLesson {
  final String title;
  final String type;
  final String location;
  final String lecturer;
  final DateTime start;
  final DateTime end;

  const ScheduleWidgetLesson({
    required this.title,
    required this.type,
    required this.location,
    required this.lecturer,
    required this.start,
    required this.end,
  });

  factory ScheduleWidgetLesson.fromSubject(Subject subject) =>
      ScheduleWidgetLesson(
        title: subject.name,
        type: subject.subjectType,
        location: [subject.address.auditorium, subject.address.building]
            .where((part) => part.trim().isNotEmpty)
            .join(' / '),
        lecturer: subject.lecturer,
        start: subject.dateTimeRange.start,
        end: subject.dateTimeRange.end,
      );

  factory ScheduleWidgetLesson.fromJson(JsonMap json) => ScheduleWidgetLesson(
        title: json['title']! as String,
        type: json['type']! as String,
        location: json['location']! as String,
        lecturer: json['lecturer']! as String,
        start: DateTime.fromMillisecondsSinceEpoch(json['start']! as int),
        end: DateTime.fromMillisecondsSinceEpoch(json['end']! as int),
      );

  JsonMap toJson() => {
        'title': title,
        'type': type,
        'location': location,
        'lecturer': lecturer,
        'start': start.millisecondsSinceEpoch,
        'end': end.millisecondsSinceEpoch,
      };
}

class ScheduleWidgetData {
  static const int schemaVersion = 1;

  final int ownerId;
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
  }) : lessons = List.unmodifiable(
          lessons.toList()..sort((a, b) => a.start.compareTo(b.start)),
        );

  factory ScheduleWidgetData.fromJson(JsonMap json) {
    if (json['version'] != schemaVersion) {
      throw const FormatException('Unsupported schedule widget data version');
    }
    return ScheduleWidgetData(
      ownerId: json['ownerId']! as int,
      ownerLabel: json['ownerLabel']! as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']! as int),
      validFrom: DateTime.fromMillisecondsSinceEpoch(json['validFrom']! as int),
      validUntil:
          DateTime.fromMillisecondsSinceEpoch(json['validUntil']! as int),
      lessons: (json['lessons']! as List<Object?>).map(
        (lesson) => ScheduleWidgetLesson.fromJson(lesson! as JsonMap),
      ),
    );
  }

  JsonMap toJson() => {
        'version': schemaVersion,
        'ownerId': ownerId,
        'ownerLabel': ownerLabel,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'validFrom': validFrom.millisecondsSinceEpoch,
        'validUntil': validUntil.millisecondsSinceEpoch,
        'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      };
}
