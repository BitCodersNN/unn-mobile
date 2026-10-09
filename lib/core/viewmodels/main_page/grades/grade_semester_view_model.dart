// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/grade_distribution.dart';
import 'package:unn_mobile/core/models/grade_book/grade_semester.dart';
import 'package:unn_mobile/core/models/grade_book/grade_statistics.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';

class GradeSemesterViewModel {
  static const List<MarkType> _distributionOrder = [
    MarkType.perfect,
    MarkType.excellent,
    MarkType.veryGood,
    MarkType.good,
    MarkType.satisfactory,
    MarkType.notSatisfactory,
    MarkType.credited,
    MarkType.notCredited,
    MarkType.noShow,
  ];

  final GradeSemester semester;
  final GradeStatistics overall;
  final List<GradeDistributionEntry> distributionEntries;

  GradeSemesterViewModel({required this.semester, required this.overall})
      : distributionEntries = List.unmodifiable(
          semester.statistics.distribution.entries.toList()
            ..sort((first, second) {
              final byType = _distributionOrder
                  .indexOf(first.type)
                  .compareTo(_distributionOrder.indexOf(second.type));
              return byType != 0
                  ? byType
                  : first.group.index.compareTo(second.group.index);
            }),
        );

  double? get averageDifference {
    final currentAverage = semester.statistics.average;
    final overallAverage = overall.average;
    if (currentAverage == null ||
        overallAverage == null ||
        overallAverage == 0) {
      return null;
    }
    return (currentAverage - overallAverage) * 100 / overallAverage;
  }
}
