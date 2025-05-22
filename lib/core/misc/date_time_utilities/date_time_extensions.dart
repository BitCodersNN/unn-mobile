// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  bool isSameDate(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }

  bool isBeforeOrEqualIgnoringYear(DateTime other) {
    return other.month > month || (other.month == month && other.day >= day);
  }

  bool isAfterOrEqualIgnoringYear(DateTime other) {
    return month > other.month || (month == other.month && day >= other.day);
  }

  bool isDateInRangeIgnoringYear(DateTimeRange range) {
    return isAfterOrEqualIgnoringYear(range.start) &&
        isBeforeOrEqualIgnoringYear(range.end);
  }

  String format(String pattern) {
    return DateFormat(pattern, 'ru-RU').format(this);
  }

  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }

  String getShortDayOfWeek() {
    const List<String> days = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
    return days[weekday - 1];
  }
}
