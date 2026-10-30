// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/curriculum_semester.dart';
import 'package:unn_mobile/core/models/grade_book/grade_semester.dart';
import 'package:unn_mobile/core/models/grade_book/grade_statistics.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grade_semester_view_model.dart';

class GradeBookSemesterViewModel {
  final int number;
  final GradeSemesterViewModel? grades;
  final CurriculumSemester? curriculum;

  GradeBookSemesterViewModel.grades(GradeSemesterViewModel model)
    : number = model.semester.number,
      grades = model,
      curriculum = null;

  const GradeBookSemesterViewModel._({
    required this.number,
    required this.grades,
    required this.curriculum,
  });

  factory GradeBookSemesterViewModel.fromCurriculum({
    required int number,
    required CurriculumSemester curriculum,
    required List<MarkBySubject> marks,
    required GradeStatistics overall,
  }) {
    final unmatched = marks.toList();
    final mandatory = _mergeSubjects(curriculum.mandatorySubjects, unmatched);
    final elective = _mergeSubjects(curriculum.electiveSubjects, unmatched);
    final merged = CurriculumSemester(
      mandatorySubjects: [...mandatory, ...unmatched],
      electiveSubjects: elective,
    );
    final subjects = [...merged.mandatorySubjects, ...merged.electiveSubjects];
    return GradeBookSemesterViewModel._(
      number: number,
      curriculum: merged,
      grades: subjects.any((subject) => subject.markType != null)
          ? GradeSemesterViewModel(
              semester: GradeSemester(number: number, marks: subjects),
              overall: overall,
            )
          : null,
    );
  }

  String get title => 'Семестр $number';

  static List<MarkBySubject> _mergeSubjects(
    List<MarkBySubject> subjects,
    List<MarkBySubject> unmatched,
  ) {
    final result = <MarkBySubject>[];
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
          result.addAll(matching);
          unmatched.removeWhere(matching.contains);
        } else {
          result.add(
            controls.length == 1
                ? subject
                : MarkBySubject(
                    subject: subject.subject,
                    controlType: control,
                    date: subject.date,
                    hours: subject.hours,
                    lecturers: subject.lecturers,
                    markType: subject.markType,
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
