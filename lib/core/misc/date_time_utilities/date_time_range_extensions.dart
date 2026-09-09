// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeRangeExtensions on DateTimeRange {
  String formatStart({
    required String pattern,
    String defaultValue = '',
  }) =>
      DateFormat(pattern).format(start);

  String formatEnd({
    required String pattern,
    String defaultValue = '',
  }) =>
      DateFormat(pattern).format(end);

  DateTimeRange shift(Duration dur) => DateTimeRange(
        start: start.add(dur),
        end: end.add(dur),
      );
}
