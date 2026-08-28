// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

enum DateTimeRangeType {
  untilEndOfWeek('До конца этой недели'),
  untilEndOfMonth('До конца этого месяца'),
  untilEndOfSemester('До конца этого семестра');

  final String label;

  const DateTimeRangeType(this.label);
}
