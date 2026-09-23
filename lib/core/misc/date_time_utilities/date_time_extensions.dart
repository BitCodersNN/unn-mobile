// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  DateTime get normalizeStartOfDay => copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );

  DateTime get endOfDay => copyWith(
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 999,
        microsecond: 999,
      );

  DateTime get startOfWeek =>
      subtract(Duration(days: weekday - DateTime.monday)).normalizeStartOfDay;

  DateTime get endOfWeek =>
      startOfWeek.add(const Duration(days: 6)).normalizeStartOfDay;

  int get weekdayIndex => weekday - DateTime.monday;

  bool get isWeekend => weekday >= DateTime.saturday;

  DateTime addWeeks(int weeks) => add(Duration(days: 7 * weeks));

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
