// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';

class _WebinarJsonKeys {
  static const id = 'id';
  static const discipline = 'discipline';
  static const title = 'title';
  static const comment = 'comment';
  static const date = 'date';
  static const time = 'time';
  static const finishTime = 'finish_time';
  static const groups = 'groups';
  static const login = 'login';
  static const urlStream = 'url_stream';
  static const urlRecord = 'url_record';
}

final class Webinar {
  final int? id;
  final String discipline;
  final String title;
  final String comment;
  final DateTimeRange dateTimeRange;
  final List<String> groups;
  final String employeeLogin;
  final String? urlStream;
  final String? urlRecord;

  Webinar({
    required this.id,
    required this.discipline,
    required this.title,
    required this.comment,
    required this.dateTimeRange,
    required this.groups,
    required this.employeeLogin,
    required this.urlStream,
    required this.urlRecord,
  });

  factory Webinar.fromJson(Map<String, Object?> jsonMap) => Webinar(
        id: int.tryParse(jsonMap[_WebinarJsonKeys.id] as String),
        discipline: jsonMap[_WebinarJsonKeys.discipline] as String,
        title: jsonMap[_WebinarJsonKeys.title] as String,
        comment: jsonMap[_WebinarJsonKeys.comment] as String,
        dateTimeRange: _parseDateTimeRange(jsonMap),
        groups: (jsonMap[_WebinarJsonKeys.groups] as String)
            .split('|')
            .where((element) => element.isNotEmpty)
            .toSet()
            .toList(),
        employeeLogin: jsonMap[_WebinarJsonKeys.login] as String,
        urlStream: jsonMap[_WebinarJsonKeys.urlStream] as String,
        urlRecord: jsonMap[_WebinarJsonKeys.urlRecord] as String,
      );

  Map<String, Object?> toJson() => {
        _WebinarJsonKeys.id: id?.toString(),
        _WebinarJsonKeys.discipline: discipline,
        _WebinarJsonKeys.title: title,
        _WebinarJsonKeys.comment: comment,
        _WebinarJsonKeys.date: dateTimeRange.start.format(
          DatePattern.yyyymmddDash,
        ),
        _WebinarJsonKeys.time: dateTimeRange.start.format(
          DatePattern.hhmmss,
        ),
        _WebinarJsonKeys.finishTime: dateTimeRange.end.format(
          DatePattern.hhmmss,
        ),
        _WebinarJsonKeys.groups: groups.join('|'),
        _WebinarJsonKeys.login: employeeLogin,
        _WebinarJsonKeys.urlStream: urlStream,
        _WebinarJsonKeys.urlRecord: urlRecord,
      };

  static DateTimeRange _parseDateTimeRange(Map<String, Object?> jsonMap) {
    final dateString = jsonMap[_WebinarJsonKeys.date] as String;
    final timeString = jsonMap[_WebinarJsonKeys.time] as String;
    final finishTimeString = jsonMap[_WebinarJsonKeys.finishTime] as String;

    final startDateTime = DateTime.parse('$dateString $timeString');
    final endDateTime = DateTime.parse('$dateString $finishTimeString');

    return DateTimeRange(start: startDateTime, end: endDateTime);
  }
}
