// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';

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
}
