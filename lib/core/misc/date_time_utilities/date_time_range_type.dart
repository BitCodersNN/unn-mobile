// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_ranges.dart';

typedef DateRangeBuilder = DateTimeRange Function({DateTime? startDate});

enum DateTimeRangeType {
  untilEndOfWeek('До конца этой недели', DateTimeRanges.untilEndOfWeek),
  untilEndOfMonth('До конца этого месяца', DateTimeRanges.untilEndOfMonth),
  untilEndOfSemester(
    'До конца этого семестра',
    DateTimeRanges.untilEndOfSemester,
  );

  final String label;
  final DateRangeBuilder _builder;

  const DateTimeRangeType(this.label, this._builder);

  DateTimeRange getRange({DateTime? startDate}) =>
      _builder(startDate: startDate);
}
