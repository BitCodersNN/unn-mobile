// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/academic_year.dart';

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
    if (DateTime.february <= now.month && now.month < DateTime.september) {
      return AcademicYear.secondSemester(now.year);
    } else {
      return AcademicYear.firstSemester(now.year);
    }
  }

  static DateTimeRange untilEndOfWeek() {
    final DateTime now = DateTime.now();
    final DateTime endOfWeek = now
        .add(
          Duration(days: DateTime.daysPerWeek - now.weekday),
        )
        .copyWith(
          hour: 23,
          minute: 59,
          second: 59,
        );

    return DateTimeRange(start: now, end: endOfWeek);
  }

  static DateTimeRange untilEndOfMonth() {
    final DateTime now = DateTime.now();
    final DateTime endOfMonth = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(days: 1))
        .copyWith(
          hour: 23,
          minute: 59,
          second: 59,
        );

    return DateTimeRange(start: now, end: endOfMonth);
  }

  static DateTimeRange untilEndOfSemester() {
    final now = DateTime.now();
    final currentYear = now.year;

    DateTime endOfSemester;

    if (now.month >= DateTime.february && now.month <= DateTime.august) {
      endOfSemester = DateTime(currentYear, DateTime.september, 1)
          .subtract(const Duration(milliseconds: 1));
    } else {
      endOfSemester = DateTime(currentYear + 1, DateTime.february, 1)
          .subtract(const Duration(milliseconds: 1));
    }

    return DateTimeRange(start: now, end: endOfSemester);
  }
}
