// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_ranges.dart';

typedef DateRangeBuilder = DateTimeRange Function({
  DateTime? startDate,
  DateTime? referenceDate,
});

enum DateTimeRangeType {
  untilEndOfWeek('Выбранная неделя', DateTimeRanges.untilEndOfWeek),
  untilEndOfMonth('Выбранный месяц', DateTimeRanges.untilEndOfMonth),
  untilEndOfSemester(
    'Выбранный семестр',
    DateTimeRanges.untilEndOfSemester,
  );

  final String label;
  final DateRangeBuilder _builder;

  const DateTimeRangeType(this.label, this._builder);

  DateTimeRange getRange({DateTime? startDate, DateTime? referenceDate}) =>
      _builder(startDate: startDate, referenceDate: referenceDate);
}
