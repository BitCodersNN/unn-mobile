// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/grade_assessment.dart';
import 'package:unn_mobile/core/models/grade_book/grade_statistics.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';

class GradeSemester {
  final int number;
  final List<MarkBySubject> marks;
  final GradeStatistics statistics;

  factory GradeSemester({
    required int number,
    required Iterable<MarkBySubject> marks,
  }) {
    final indexedMarks = marks.indexed.toList()
      ..sort((first, second) {
        final firstDate = first.$2.date;
        final secondDate = second.$2.date;
        final byDate = firstDate == null
            ? secondDate == null
                  ? 0
                  : 1
            : secondDate == null
            ? -1
            : firstDate.compareTo(secondDate);
        return byDate != 0 ? byDate : first.$1.compareTo(second.$1);
      });
    final snapshot = List<MarkBySubject>.unmodifiable(
      indexedMarks.map((entry) => entry.$2),
    );
    return GradeSemester._(
      number: number,
      marks: snapshot,
      statistics: GradeStatistics.fromMarks(snapshot),
    );
  }

  const GradeSemester._({
    required this.number,
    required this.marks,
    required this.statistics,
  });

  Iterable<MarkBySubject> get exams => marks.where((mark) => mark.isExam);

  Iterable<MarkBySubject> get retakes =>
      marks.where((mark) => mark.requiresRetake);
}
