import 'package:flutter/material.dart';

class DateTimeRanges {
  static DateTimeRange currentWeek() {
    final startOfWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final endOfWeek =
        startOfWeek.add(const Duration(days: DateTime.daysPerWeek - 1));

    return DateTimeRange(start: startOfWeek, end: endOfWeek);
  }

  static DateTimeRange nextWeek() {
    final startOfWeek = DateTime.now()
        .add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday + 1));
    final endOfWeek =
        startOfWeek.add(const Duration(days: DateTime.daysPerWeek - 1));

    return DateTimeRange(start: startOfWeek, end: endOfWeek);
  }

  static DateTimeRange currentMonth() {
    final now = DateTime.now();
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: endOfMonth,
    );
  }

  static DateTimeRange currentSemester() {
    final now = DateTime.now();
    DateTime startOfSemester, endOfSemester;
    if (DateTime.february <= now.month && now.month < DateTime.september) {
      startOfSemester = DateTime(now.year, DateTime.february, 1);
      endOfSemester = DateTime(now.year, DateTime.july, 15);
    } else {
      startOfSemester = DateTime(now.year, DateTime.september, 1);
      endOfSemester = DateTime(now.year + 1, DateTime.february, 1);
    }
    return DateTimeRange(start: startOfSemester, end: endOfSemester);
  }

  static DateTimeRange untilEndOfWeek() {
    final DateTime now = DateTime.now();
    final DateTime endOfWeek =
        now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

    return DateTimeRange(start: now, end: endOfWeek);
  }

  static DateTimeRange untilEndOfMonth() {
    final DateTime now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: 23, minutes: 59, seconds: 59));

    return DateTimeRange(start: now, end: endOfMonth);
  }

  static DateTimeRange untilEndOfSemester() {
    final now = DateTime.now();
    DateTime endOfSemester;
    if (DateTime.february <= now.month && now.month < DateTime.september) {
      endOfSemester = DateTime(now.year, DateTime.july, 15);
    } else {
      endOfSemester = DateTime(now.year + 1, DateTime.february, 1);
    }
    return DateTimeRange(start: now, end: endOfSemester);
  }
}
