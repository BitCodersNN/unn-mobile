// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';

class WeekRange {
  WeekRange({required this.weekOffset, DateTime? reference})
      : _reference = reference ?? DateTime.now();

  final int weekOffset;
  final DateTime _reference;

  DateTime get start => _reference.startOfWeek.addWeeks(weekOffset);

  DateTime get end => start.endOfWeek;

  DateTime get endExclusive => start.addWeeks(1);

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(endExclusive);
}
