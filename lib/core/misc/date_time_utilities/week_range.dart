// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _WeekRangeJsonKeys {
  static const weekOffset = 'offset';
  static const reference = 'reference';
}

class WeekRange {
  WeekRange({required this.weekOffset, DateTime? reference})
      : reference = reference ?? DateTime.now();

  final int weekOffset;
  final DateTime reference;

  late final DateTime start = reference.startOfWeek.addWeeks(weekOffset);

  late final DateTime end = start.endOfWeek;

  late final DateTime endExclusive = start.addWeeks(1);

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(endExclusive);

  DateTimeRange get dateTimeRange => DateTimeRange(start: start, end: end);

  factory WeekRange.fromJson(JsonMap jsonMap) => WeekRange(
        weekOffset: jsonMap[_WeekRangeJsonKeys.weekOffset]! as int,
        reference:
            DateTime.parse(jsonMap[_WeekRangeJsonKeys.reference]! as String),
      );

  JsonMap toJson() => {
        _WeekRangeJsonKeys.weekOffset: weekOffset,
        _WeekRangeJsonKeys.reference: reference.toString(),
      };
}
