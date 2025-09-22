// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';
import 'package:unn_mobile/core/models/schedule/address.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';

class _SubjectJsonKeys {
  static const String discipline = 'discipline';
  static const String kindOfWork = 'kindOfWork';
  static const String auditorium = 'auditorium';
  static const String building = 'building';
  static const String stream = 'stream';
  static const String lecturer = 'lecturer';
  static const String lecturerUID = 'lecturerUID';
  static const String beginLesson = 'beginLesson';
  static const String endLesson = 'endLesson';
  static const String date = 'date';
}

class Subject {
  final String name;
  final String subjectType;
  final Address address;
  final List<String> groups;
  final String lecturer;
  final String syncId;
  final DateTimeRange dateTimeRange;

  Subject({
    required this.name,
    required this.subjectType,
    required this.address,
    required this.groups,
    required this.lecturer,
    required this.syncId,
    required this.dateTimeRange,
  });

  SubjectType get subjectTypeEnum {
    final subjectTypeLowerCase = subjectType.toLowerCase();
    for (final entry in typeMapping.entries) {
      if (subjectTypeLowerCase.contains(entry.key)) {
        return entry.value;
      }
    }
    return SubjectType.unknown;
  }

  factory Subject.fromJson(Map<String, dynamic> jsonMap) {
    final String date = _getString(jsonMap, _SubjectJsonKeys.date);
    final String beginLesson =
        _getString(jsonMap, _SubjectJsonKeys.beginLesson);
    final String endLesson = _getString(jsonMap, _SubjectJsonKeys.endLesson);
    final String discipline = _getString(jsonMap, _SubjectJsonKeys.discipline);
    final String kindOfWork = _getString(jsonMap, _SubjectJsonKeys.kindOfWork);
    final String auditorium = _getString(jsonMap, _SubjectJsonKeys.auditorium);
    final String building = _getString(jsonMap, _SubjectJsonKeys.building);
    final String streamString = _getString(jsonMap, _SubjectJsonKeys.stream);
    final String lecturer = _getString(jsonMap, _SubjectJsonKeys.lecturer);
    final String syncId = _getString(jsonMap, _SubjectJsonKeys.lecturerUID);

    return Subject(
      name: discipline,
      subjectType: kindOfWork,
      address: Address(
        auditorium: auditorium,
        building: building,
      ),
      groups: streamString.split('|'),
      lecturer: lecturer,
      syncId: syncId,
      dateTimeRange: DateTimeRange(
        start: _parseDateTime(date, beginLesson),
        end: _parseDateTime(date, endLesson),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        _SubjectJsonKeys.date:
            dateTimeRange.start.format(DatePattern.yyyymmddDash),
        _SubjectJsonKeys.beginLesson:
            dateTimeRange.start.format(DatePattern.hhmm),
        _SubjectJsonKeys.endLesson: dateTimeRange.end.format(DatePattern.hhmm),
        _SubjectJsonKeys.discipline: name,
        _SubjectJsonKeys.kindOfWork: subjectType,
        _SubjectJsonKeys.auditorium: address.auditorium,
        _SubjectJsonKeys.building: address.building,
        _SubjectJsonKeys.stream: groups.join('|'),
        _SubjectJsonKeys.lecturer: lecturer,
        _SubjectJsonKeys.lecturerUID: syncId,
      };

  static DateTime _parseDateTime(String date, String time) {
    return DateTimeParser.parse(
      '$date $time',
      DatePattern.ymmddhm,
    );
  }

  static String _getString(Map<String, dynamic> jsonMap, String key) =>
      jsonMap[key] as String? ?? '';
}
