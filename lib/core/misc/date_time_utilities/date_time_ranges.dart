// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/academic_year.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';

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

  static DateTimeRange untilEndOfWeek({
    DateTime? startDate,
    DateTime? referenceDate,
  }) {
    final anchorDate = referenceDate ?? startDate ?? DateTime.now();
    final startOfDay = (startDate ?? anchorDate).normalizeStartOfDay();

    final endOfWeek = anchorDate
        .normalizeStartOfDay()
        .add(Duration(days: DateTime.daysPerWeek - anchorDate.weekday))
        .endOfDay();

    return DateTimeRange(start: startOfDay, end: endOfWeek);
  }

  static DateTimeRange untilEndOfMonth({
    DateTime? startDate,
    DateTime? referenceDate,
  }) {
    final anchorDate = referenceDate ?? startDate ?? DateTime.now();
    final startOfDay = (startDate ?? anchorDate).normalizeStartOfDay();

    final lastDayOfMonth = DateTime(
      anchorDate.year,
      anchorDate.month + 1,
      0,
    ).day;
    final endOfMonth = anchorDate.copyWith(day: lastDayOfMonth).endOfDay();

    return DateTimeRange(start: startOfDay, end: endOfMonth);
  }

  static DateTimeRange untilEndOfSemester({
    DateTime? startDate,
    DateTime? referenceDate,
  }) {
    final anchorDate = referenceDate ?? startDate ?? DateTime.now();
    final startOfDay = (startDate ?? anchorDate).normalizeStartOfDay();

    final isSpringSummerSemester = anchorDate.month >= DateTime.february &&
        anchorDate.month <= DateTime.august;

    final endOfSemesterDate = isSpringSummerSemester
        ? anchorDate.copyWith(month: DateTime.august, day: 31)
        : anchorDate.copyWith(
            year: anchorDate.year + 1,
            month: DateTime.january,
            day: 31,
          );

    final endOfSemester = endOfSemesterDate.endOfDay();

    return DateTimeRange(start: startOfDay, end: endOfSemester);
  }
}
