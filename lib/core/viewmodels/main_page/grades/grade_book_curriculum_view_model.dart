// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/grade_book_subject.dart';

class GradeBookCurriculumViewModel {
  final List<GradeBookSubject> mandatorySubjects;
  final List<GradeBookSubject> electiveSubjects;

  GradeBookCurriculumViewModel({
    required Iterable<GradeBookSubject> mandatorySubjects,
    required Iterable<GradeBookSubject> electiveSubjects,
  }) : mandatorySubjects = List.unmodifiable(mandatorySubjects),
       electiveSubjects = List.unmodifiable(electiveSubjects);
}
