// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/grade_assessment.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';

class GradeDistributionEntry {
  final MarkType type;
  final GradeResultGroup group;
  final int count;
  final int total;

  const GradeDistributionEntry({
    required this.type,
    required this.group,
    required this.count,
    required this.total,
  })  : assert(count > 0),
        assert(total >= count);

  double get percentage => count * 100 / total;
}

class GradeDistribution {
  final Map<MarkType, int> counts;
  final List<GradeDistributionEntry> entries;

  const GradeDistribution._({required this.counts, required this.entries});

  factory GradeDistribution.fromMarks(Iterable<MarkBySubject> marks) {
    final groups = <GradeResultGroup, Map<MarkType, int>>{};
    for (final mark in marks) {
      (groups[mark.resultGroup] ??= <MarkType, int>{}).update(
        mark.markType,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return GradeDistribution._fromGroups(groups);
  }

  factory GradeDistribution.combine(Iterable<GradeDistribution> distributions) {
    final groups = <GradeResultGroup, Map<MarkType, int>>{};
    for (final distribution in distributions) {
      for (final entry in distribution.entries) {
        (groups[entry.group] ??= <MarkType, int>{}).update(
          entry.type,
          (count) => count + entry.count,
          ifAbsent: () => entry.count,
        );
      }
    }
    return GradeDistribution._fromGroups(groups);
  }

  factory GradeDistribution._fromGroups(
    Map<GradeResultGroup, Map<MarkType, int>> groups,
  ) {
    final counts = <MarkType, int>{};
    final entries = <GradeDistributionEntry>[];
    for (final group in GradeResultGroup.values) {
      final results = groups[group] ?? const <MarkType, int>{};
      final total = results.values.fold(0, (sum, count) => sum + count);
      for (final result in results.entries) {
        counts.update(
          result.key,
          (count) => count + result.value,
          ifAbsent: () => result.value,
        );
        entries.add(
          GradeDistributionEntry(
            type: result.key,
            group: group,
            count: result.value,
            total: total,
          ),
        );
      }
    }
    return GradeDistribution._(
      counts: Map.unmodifiable(counts),
      entries: List.unmodifiable(entries),
    );
  }
}
