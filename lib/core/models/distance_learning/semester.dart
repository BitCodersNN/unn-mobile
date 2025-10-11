// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/academic_year.dart';
import 'package:unn_mobile/core/misc/bounded_int.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';

class SemesterJsonKeys {
  static const String semester = 'semester';
  static const String year = 'year';
}

class Semester {
  final BoundedInt _semester;
  final BoundedInt _year;

  int get semester => _semester.value;
  int get year => _year.value;

  String get academicYear =>
      semester == 1 ? '$year–${year + 1}' : '${year - 1}–$year';

  Semester({
    required int semester,
    required int year,
  })  : _semester = BoundedInt(
          value: semester,
          min: 1,
          max: 2,
          paramName: 'semester',
          errorMessage: 'Семестр должен быть 1 или 2',
        ),
        _year = BoundedInt(
          value: year,
          min: 2000,
          max: DateTime.now().year,
          paramName: 'year',
          errorMessage: 'Год должен быть от 2000 до ${DateTime.now().year}',
        );

  factory Semester.fromJson(Map<String, Object?> jsonMap) => Semester(
        semester: int.parse(
          jsonMap[SemesterJsonKeys.semester] as String,
        ),
        year: int.parse(
          jsonMap[SemesterJsonKeys.year] as String,
        ),
      );

  Map<String, Object?> toJson() => {
        SemesterJsonKeys.semester: semester.toString(),
        SemesterJsonKeys.year: year.toString(),
      };

  @override
  String toString() => '$academicYear год, $semester семестр';
}

extension SemesterComparable on Semester {
  int compareTo(Semester other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    return other.semester.compareTo(semester);
  }
}

extension SemesterDateRange on Semester {
  bool contains(DateTime date) {
    final range = toDateTimeRange();
    return date.isBetween(range.start, range.end);
  }

  DateTimeRange toDateTimeRange() {
    switch (semester) {
      case 1:
        return AcademicYear.firstSemester(year);
      case 2:
        return AcademicYear.secondSemester(year);
      default:
        throw ArgumentError(
          'Неподдерживаемый семестр: $semester. Ожидается 1 или 2.',
        );
    }
  }
}
