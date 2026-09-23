// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
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

class _SubjectRaspJsonKeys {
  static const String dis = 'dis';
  static const String typework = 'typework';
  static const String audName = 'aud_name';
  static const String korpusName = 'korpus_name';
  static const String lector = 'lector';
  static const String id = 'id';
  static const String fullStartTime = 'fullstarttime';
  static const String det = 'det';
  static const String tet = 'tet';
  static const String subgroup = 'subgroup';
  static const String group = 'group';
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

    final String streamString =
        getStringFromJson(jsonMap, _SubjectJsonKeys.stream);
    final match =
        RegularExpressions.streamContentRegExp.firstMatch(streamString);
    final streamContent = match?.group(1) ?? streamString;

    return Subject(
      name: getStringFromJson(jsonMap, _SubjectJsonKeys.discipline),
      subjectType: getStringFromJson(jsonMap, _SubjectJsonKeys.kindOfWork),
      address: Address(
        auditorium: getStringFromJson(jsonMap, _SubjectJsonKeys.auditorium),
        building: getStringFromJson(jsonMap, _SubjectJsonKeys.building),
      ),
      groups: streamContent
          .split(RegularExpressions.multiValueSeparatorRegExp)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      lecturer: getStringFromJson(jsonMap, _SubjectJsonKeys.lecturer),
      syncId: getStringFromJson(jsonMap, _SubjectJsonKeys.lecturerUID),
      dateTimeRange: DateTimeRange(
        start: _parseDateTime(
          date,
          getStringFromJson(jsonMap, _SubjectJsonKeys.beginLesson),
        ),
        end: _parseDateTime(
          date,
          getStringFromJson(jsonMap, _SubjectJsonKeys.endLesson),
        ),
      ),
    );
  }

  factory Subject.fromRaspJson(JsonMap jsonMap) {
    final subgroups = getStringFromJson(jsonMap, _SubjectRaspJsonKeys.subgroup);
    final groups = subgroups.isEmpty
        ? getStringFromJson(jsonMap, _SubjectRaspJsonKeys.group)
        : subgroups;

    return Subject(
      name: getStringFromJson(jsonMap, _SubjectRaspJsonKeys.dis),
      subjectType: getStringFromJson(jsonMap, _SubjectRaspJsonKeys.typework),
      address: Address(
        auditorium: getStringFromJson(jsonMap, _SubjectRaspJsonKeys.audName),
        building: getStringFromJson(jsonMap, _SubjectRaspJsonKeys.korpusName),
      ),
      groups: groups
          .split(RegularExpressions.multiValueSeparatorRegExp)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      lecturer: getStringFromJson(jsonMap, _SubjectRaspJsonKeys.lector),
      syncId: getStringFromJson(jsonMap, _SubjectRaspJsonKeys.id),
      dateTimeRange: DateTimeRange(
        start: DateTimeParser.parse(
          getStringFromJson(jsonMap, _SubjectRaspJsonKeys.fullStartTime),
          DatePattern.ddmmyyyyhhmmss,
        ),
        end: _parseDateTime(
          getStringFromJson(jsonMap, _SubjectRaspJsonKeys.det).split(' ').first,
          getStringFromJson(jsonMap, _SubjectRaspJsonKeys.tet),
          pattern: DatePattern.ddmmyyyyhhmmss,
        ),
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
        _SubjectJsonKeys.stream: groups.join(';'),
        _SubjectJsonKeys.lecturer: lecturer,
        _SubjectJsonKeys.lecturerUID: syncId,
      };

  static DateTime _parseDateTime(
    String date,
    String time, {
    pattern = DatePattern.ymmddhm,
  }) =>
      DateTimeParser.parse(
        '$date $time',
        pattern,
      );
}
