// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/grade_book/curriculum_hours.dart';

class _JsonKeys {
  static const String subject = 'subject';
  static const String controlType = 'control_type';
  static const String hours = 'hours';
  static const String hoursBreakdown = 'hours_breakdown';
}

class CurriculumSubject {
  static const int _hoursPerCreditedHour = 36;

  final String subject;
  final String controlType;
  final int hours;
  final CurriculumHours hoursBreakdown;

  const CurriculumSubject({
    required this.subject,
    required this.controlType,
    required this.hours,
    required this.hoursBreakdown,
  });

  int get creditedHours => hours ~/ _hoursPerCreditedHour;

  factory CurriculumSubject.fromJson(JsonMap json) => CurriculumSubject(
    subject: json[_JsonKeys.subject]! as String,
    controlType: json[_JsonKeys.controlType]! as String,
    hours: (json[_JsonKeys.hours]! as num).toInt(),
    hoursBreakdown: CurriculumHours.fromJson(
      json[_JsonKeys.hoursBreakdown]! as JsonMap,
    ),
  );

  JsonMap toJson() => {
    _JsonKeys.subject: subject,
    _JsonKeys.controlType: controlType,
    _JsonKeys.hours: hours,
    _JsonKeys.hoursBreakdown: hoursBreakdown.toJson(),
  };
}
