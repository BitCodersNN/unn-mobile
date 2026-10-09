import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';

enum GradeResultGroup { grades, credits }

extension GradeAssessment on MarkBySubject {
  bool get isExam => controlType.toLowerCase().contains('экзамен');

  bool get requiresRetake => const {
        MarkType.notSatisfactory,
        MarkType.notCredited,
        MarkType.noShow,
      }.contains(markType);
}

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
  });

  double get percentage => count * 100 / total;
}

class GradeStatistics {
  final int subjectCount;
  final int examCount;
  final int retakeCount;
  final double? average;
  final Map<MarkType, int> distribution;
  final List<GradeDistributionEntry> distributionEntries;

  const GradeStatistics._({
    required this.subjectCount,
    required this.examCount,
    required this.retakeCount,
    required this.average,
    required this.distribution,
    required this.distributionEntries,
  });

  factory GradeStatistics.fromMarks(Iterable<MarkBySubject> marks) {
    int subjectCount = 0;
    int examCount = 0;
    int retakeCount = 0;
    int gradedCount = 0;
    int halfPoints = 0;
    final distribution = <MarkType, int>{};
    final groups = {
      for (final group in GradeResultGroup.values) group: <MarkType, int>{},
    };
    for (final mark in marks) {
      subjectCount++;
      final control = mark.controlType.toLowerCase().replaceAll('ё', 'е');
      if (mark.isExam) {
        examCount++;
      }
      if (mark.requiresRetake) {
        retakeCount++;
      }
      distribution.update(
        mark.markType,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      final value = mark.markType.convertToDouble();
      final isCredit = mark.markType == MarkType.credited ||
          mark.markType == MarkType.notCredited ||
          (mark.markType == MarkType.noShow && control.contains('зачет'));
      final group =
          isCredit ? GradeResultGroup.credits : GradeResultGroup.grades;
      groups[group]!
          .update(mark.markType, (count) => count + 1, ifAbsent: () => 1);
      if (!control.contains('зачет') && value >= 2) {
        gradedCount++;
        halfPoints += (value * 2).round();
      }
    }
    final hundredths = gradedCount == 0
        ? null
        : (halfPoints * 100 + gradedCount) ~/ (gradedCount * 2);
    return GradeStatistics._(
      subjectCount: subjectCount,
      examCount: examCount,
      retakeCount: retakeCount,
      average: hundredths == null ? null : hundredths / 100,
      distribution: Map.unmodifiable(distribution),
      distributionEntries: List.unmodifiable([
        for (final group in groups.entries)
          for (final result in group.value.entries)
            GradeDistributionEntry(
              type: result.key,
              group: group.key,
              count: result.value,
              total: group.value.values.fold(0, (sum, count) => sum + count),
            ),
      ]),
    );
  }

  double? averageDifferenceFrom(GradeStatistics reference) {
    final currentAverage = average;
    final referenceAverage = reference.average;
    if (currentAverage == null ||
        referenceAverage == null ||
        referenceAverage == 0) {
      return null;
    }
    return (currentAverage - referenceAverage) * 100 / referenceAverage;
  }
}

class GradeSemester {
  final int number;
  final List<MarkBySubject> marks;
  final GradeStatistics statistics;

  GradeSemester({required this.number, required Iterable<MarkBySubject> marks})
      : marks = List.unmodifiable(
          marks.toList()
            ..sort((first, second) => first.date.compareTo(second.date)),
        ),
        statistics = GradeStatistics.fromMarks(marks);

  Iterable<MarkBySubject> get exams => marks.where((mark) => mark.isExam);

  Iterable<MarkBySubject> get retakes =>
      marks.where((mark) => mark.requiresRetake);
}

class GradeBookSummary {
  final List<GradeSemester> semesters;
  final GradeStatistics overall;

  GradeBookSummary.fromGradeBook(Map<int, List<MarkBySubject>> gradeBook)
      : semesters = List.unmodifiable(
          (gradeBook.keys.toList()..sort()).map(
            (number) =>
                GradeSemester(number: number, marks: gradeBook[number]!),
          ),
        ),
        overall = GradeStatistics.fromMarks(
          gradeBook.values.expand((marks) => marks),
        );
}
