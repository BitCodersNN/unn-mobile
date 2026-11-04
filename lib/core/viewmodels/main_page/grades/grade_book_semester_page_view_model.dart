// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/curriculum_semester.dart';
import 'package:unn_mobile/core/models/grade_book/curriculum_subject.dart';
import 'package:unn_mobile/core/models/grade_book/grade_book_subject.dart';
import 'package:unn_mobile/core/models/grade_book/grade_semester.dart';
import 'package:unn_mobile/core/models/grade_book/grade_statistics.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grade_book_curriculum_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grade_semester_summary_view_model.dart';

class GradeBookSemesterPageViewModel {
  final int number;
  final GradeSemesterSummaryViewModel? grades;
  final GradeBookCurriculumViewModel? curriculum;

  GradeBookSemesterPageViewModel.grades(GradeSemesterSummaryViewModel model)
    : number = model.semester.number,
      grades = model,
      curriculum = null;

  const GradeBookSemesterPageViewModel._({
    required this.number,
    required this.grades,
    required this.curriculum,
  });

  factory GradeBookSemesterPageViewModel.fromCurriculum({
    required int number,
    required CurriculumSemester curriculum,
    required List<MarkBySubject> marks,
    required GradeStatistics overall,
  }) {
    final unmatched = marks.toList();
    final mandatory = _mergeSubjects(curriculum.mandatorySubjects, unmatched);
    final elective = _mergeSubjects(curriculum.electiveSubjects, unmatched);
    final merged = GradeBookCurriculumViewModel(
      mandatorySubjects: [...mandatory, ...unmatched.map(GradedSubject.new)],
      electiveSubjects: elective,
    );
    final subjects = [
      ...merged.mandatorySubjects,
      ...merged.electiveSubjects,
    ].map((subject) => subject.summaryMark).toList();
    return GradeBookSemesterPageViewModel._(
      number: number,
      curriculum: merged,
      grades: subjects.any((subject) => subject.markType != null)
          ? GradeSemesterSummaryViewModel(
              semester: GradeSemester(number: number, marks: subjects),
              overall: overall,
            )
          : null,
    );
  }

  String get title => 'Семестр $number';

  static List<GradeBookSubject> _mergeSubjects(
    List<CurriculumSubject> subjects,
    List<MarkBySubject> unmatched,
  ) {
    final result = <GradeBookSubject>[];
    for (final subject in subjects) {
      final controls = subject.controlType
          .split(',')
          .map((control) => control.trim())
          .toList();
      for (final control in controls) {
        final matching = unmatched
            .where(
              (mark) =>
                  _normalize(mark.subject) == _normalize(subject.subject) &&
                  (control.isEmpty ||
                      _normalize(mark.controlType) == _normalize(control)),
            )
            .toList();
        if (matching.isNotEmpty) {
          result.addAll(matching.map(GradedSubject.new));
          unmatched.removeWhere(matching.contains);
        } else {
          result.add(
            PlannedSubject(
              controls.length == 1
                  ? subject
                  : CurriculumSubject(
                      subject: subject.subject,
                      controlType: control,
                      hours: subject.hours,
                      hoursBreakdown: subject.hoursBreakdown,
                    ),
            ),
          );
        }
      }
    }
    return result;
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('ё', 'е')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}
