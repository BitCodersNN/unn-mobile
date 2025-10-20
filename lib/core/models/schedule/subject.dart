// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
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

  factory Subject.fromJson(JsonMap jsonMap) {
    final String date = getStringFromJson(jsonMap, _SubjectJsonKeys.date);
    final String beginLesson =
        getStringFromJson(jsonMap, _SubjectJsonKeys.beginLesson);
    final String endLesson =
        getStringFromJson(jsonMap, _SubjectJsonKeys.endLesson);
    final String discipline =
        getStringFromJson(jsonMap, _SubjectJsonKeys.discipline);
    final String kindOfWork =
        getStringFromJson(jsonMap, _SubjectJsonKeys.kindOfWork);
    final String auditorium =
        getStringFromJson(jsonMap, _SubjectJsonKeys.auditorium);
    final String building =
        getStringFromJson(jsonMap, _SubjectJsonKeys.building);
    final String streamString =
        getStringFromJson(jsonMap, _SubjectJsonKeys.stream);
    final String lecturer =
        getStringFromJson(jsonMap, _SubjectJsonKeys.lecturer);
    final String syncId =
        getStringFromJson(jsonMap, _SubjectJsonKeys.lecturerUID);

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

  JsonMap toJson() => {
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
}
