// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/curriculum_subject.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';

sealed class GradeBookSubject {
  const GradeBookSubject();

  /// Данные для статистики и перехода из summary к дисциплине.
  MarkBySubject get summaryMark;
}

final class GradedSubject extends GradeBookSubject {
  final MarkBySubject mark;

  const GradedSubject(this.mark);

  @override
  MarkBySubject get summaryMark => mark;
}

final class PlannedSubject extends GradeBookSubject {
  final CurriculumSubject subject;

  @override
  final MarkBySubject summaryMark;

  PlannedSubject(this.subject)
    : summaryMark = MarkBySubject(
        subject: subject.subject,
        controlType: subject.controlType,
        hours: subject.hours,
        date: null,
        lecturers: null,
        markType: null,
      );
}
