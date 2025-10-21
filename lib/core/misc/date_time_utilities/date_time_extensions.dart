// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  bool isSameDate(DateTime other) =>
      day == other.day && month == other.month && year == other.year;

  bool isBeforeOrEqualIgnoringYear(DateTime other) =>
      other.month > month || (other.month == month && other.day >= day);

  bool isAfterOrEqualIgnoringYear(DateTime other) =>
      month > other.month || (month == other.month && day >= other.day);

  bool isDateInRangeIgnoringYear(DateTimeRange range) =>
      isAfterOrEqualIgnoringYear(range.start) &&
      isBeforeOrEqualIgnoringYear(range.end);

  String format(String pattern) => DateFormat(pattern, 'ru-RU').format(this);

  bool isBetween(DateTime start, DateTime end) =>
      isAfter(start) && isBefore(end);
}
