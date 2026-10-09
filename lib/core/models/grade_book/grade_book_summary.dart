import 'package:unn_mobile/core/models/grade_book/grade_semester.dart';
import 'package:unn_mobile/core/models/grade_book/grade_statistics.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';

class GradeBookSummary {
  final List<GradeSemester> semesters;
  final GradeStatistics overall;

  const GradeBookSummary._({required this.semesters, required this.overall});

  factory GradeBookSummary.fromGradeBook(
    Map<int, List<MarkBySubject>> gradeBook,
  ) {
    final numbers = gradeBook.keys.toList()..sort();
    final semesters = List<GradeSemester>.unmodifiable(
      numbers.map(
        (number) => GradeSemester(number: number, marks: gradeBook[number]!),
      ),
    );
    return GradeBookSummary._(
      semesters: semesters,
      overall: GradeStatistics.combine(
        semesters.map((semester) => semester.statistics),
      ),
    );
  }
}
