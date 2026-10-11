// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';

class _MarkBySubjectJsonKeys {
  static const String controlType = 'control_type';
  static const String date = 'date';
  static const String hours = 'hours';
  static const String lecturers = 'lecturers';
  static const String mark = 'mark';
  static const String subject = 'subject';
}

class MarkBySubject {
  static const int _hoursPerCreditedHour = 36;

  final String controlType;
  final DateTime date;
  final int hours;
  final String? lecturers;
  final MarkType markType;
  final String subject;

  const MarkBySubject({
    required this.controlType,
    required this.date,
    required this.hours,
    required this.lecturers,
    required this.markType,
    required this.subject,
  });

  int get creditedHours => hours ~/ _hoursPerCreditedHour;

  factory MarkBySubject.fromJson(JsonMap jsonMap) => MarkBySubject(
        controlType: jsonMap[_MarkBySubjectJsonKeys.controlType]! as String,
        date: DateTime.parse(jsonMap[_MarkBySubjectJsonKeys.date]! as String),
        hours: int.parse(jsonMap[_MarkBySubjectJsonKeys.hours]! as String),
        lecturers: jsonMap[_MarkBySubjectJsonKeys.lecturers] as String?,
        markType: MarkType.fromDouble(
          (jsonMap[_MarkBySubjectJsonKeys.mark]! as num).toDouble(),
        ),
        subject: jsonMap[_MarkBySubjectJsonKeys.subject]! as String,
      );

  JsonMap toJson() => {
        _MarkBySubjectJsonKeys.controlType: controlType,
        _MarkBySubjectJsonKeys.date: date.toIso8601String(),
        _MarkBySubjectJsonKeys.hours: hours.toString(),
        _MarkBySubjectJsonKeys.lecturers: lecturers,
        _MarkBySubjectJsonKeys.mark: markType.value,
        _MarkBySubjectJsonKeys.subject: subject,
      };
}
