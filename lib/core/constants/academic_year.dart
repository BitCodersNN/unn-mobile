// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class AcademicYear {
  static DateTimeRange firstSemester(int year) => DateTimeRange(
        start: DateTime(year, DateTime.september, 1),
        end: DateTime(year + 1, DateTime.february, 1),
      );

  static DateTimeRange secondSemester(int year) => DateTimeRange(
        start: DateTime(year, DateTime.february, 1),
        end: DateTime(year, DateTime.july, 16),
      );
}
