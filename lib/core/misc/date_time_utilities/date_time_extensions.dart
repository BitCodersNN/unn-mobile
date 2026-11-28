// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  DateTime get startOfDay =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  DateTime get endOfDay => copyWith(
    hour: 23,
    minute: 59,
    second: 59,
    millisecond: 999,
    microsecond: 999,
  );

  DateTime get startOfWeek =>
      subtract(Duration(days: weekday - DateTime.monday)).startOfDay;

  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6)).startOfDay;

  int get weekdayIndex => weekday - DateTime.monday;

  bool get isWeekend => weekday >= DateTime.saturday;

  DateTime addWeeks(int weeks) => add(Duration(days: 7 * weeks));

  bool isSameDate(DateTime other) =>
      day == other.day && month == other.month && year == other.year;

  String format(String pattern) => DateFormat(pattern, 'ru-RU').format(this);

  bool isBetween(DateTime start, DateTime end) =>
      isAfter(start) && isBefore(end);
}
