// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/grade_assessment.dart';
import 'package:unn_mobile/core/models/grade_book/grade_distribution.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';

class GradeStatistics {
  final int subjectCount;
  final int examCount;
  final int retakeCount;
  final GradeDistribution distribution;
  final _GradeAverage _average;

  const GradeStatistics._({
    required this.subjectCount,
    required this.examCount,
    required this.retakeCount,
    required this.distribution,
    required _GradeAverage average,
  }) : _average = average;

  factory GradeStatistics.fromMarks(Iterable<MarkBySubject> marks) {
    final snapshot = marks.toList();
    return GradeStatistics._(
      subjectCount: snapshot.length,
      examCount: snapshot.where((mark) => mark.isExam).length,
      retakeCount: snapshot.where((mark) => mark.requiresRetake).length,
      distribution: GradeDistribution.fromMarks(snapshot),
      average: _GradeAverage.fromMarks(snapshot),
    );
  }

  factory GradeStatistics.combine(Iterable<GradeStatistics> statistics) {
    final snapshot = statistics.toList();
    return GradeStatistics._(
      subjectCount: snapshot.fold(0, (sum, item) => sum + item.subjectCount),
      examCount: snapshot.fold(0, (sum, item) => sum + item.examCount),
      retakeCount: snapshot.fold(0, (sum, item) => sum + item.retakeCount),
      distribution: GradeDistribution.combine(
        snapshot.map((item) => item.distribution),
      ),
      average: _GradeAverage.combine(snapshot.map((item) => item._average)),
    );
  }

  double? get average => _average.value;
}

class _GradeAverage {
  final int _halfPoints;
  final int _count;

  const _GradeAverage(this._halfPoints, this._count);

  factory _GradeAverage.fromMarks(Iterable<MarkBySubject> marks) {
    int halfPoints = 0;
    int count = 0;
    for (final mark in marks) {
      final value = mark.averageValue;
      if (value != null) {
        halfPoints += (value * 2).round();
        count++;
      }
    }
    return _GradeAverage(halfPoints, count);
  }

  factory _GradeAverage.combine(Iterable<_GradeAverage> averages) {
    int halfPoints = 0;
    int count = 0;
    for (final average in averages) {
      halfPoints += average._halfPoints;
      count += average._count;
    }
    return _GradeAverage(halfPoints, count);
  }

  double? get value =>
      _count == 0 ? null : ((_halfPoints * 100 + _count) ~/ (_count * 2)) / 100;
}
