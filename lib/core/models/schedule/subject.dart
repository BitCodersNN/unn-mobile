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
  final DateTimeRange dateTimeRange;

  Subject({
    required this.name,
    required this.subjectType,
    required this.address,
    required this.groups,
    required this.lecturer,
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
    final String date = jsonMap[_SubjectJsonKeys.date] as String? ?? '';
    final String beginLesson =
        jsonMap[_SubjectJsonKeys.beginLesson] as String? ?? '';
    final String endLesson =
        jsonMap[_SubjectJsonKeys.endLesson] as String? ?? '';

    final String discipline =
        jsonMap[_SubjectJsonKeys.discipline] as String? ?? '';

    final String kindOfWork =
        jsonMap[_SubjectJsonKeys.kindOfWork] as String? ?? '';
    final String auditorium =
        jsonMap[_SubjectJsonKeys.auditorium] as String? ?? '';
    final String building = jsonMap[_SubjectJsonKeys.building] as String? ?? '';
    final String streamString =
        jsonMap[_SubjectJsonKeys.stream] as String? ?? '';
    final String lecturer = jsonMap[_SubjectJsonKeys.lecturer] as String? ?? '';

    return Subject(
      name: discipline,
      subjectType: kindOfWork,
      address: Address(
        auditorium: auditorium,
        building: building,
      ),
      groups: streamString.split('|'),
      lecturer: lecturer,
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
      };

  static DateTime _parseDateTime(String date, String time) {
    return DateTimeParser.parse(
      '$date $time',
      DatePattern.ymmddhm,
    );
  }
}
