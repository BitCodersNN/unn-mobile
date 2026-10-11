// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/grade_book/curriculum_semester.dart';

abstract interface class CurriculumService {
  Future<Map<int, CurriculumSemester>?> getCurriculum();
}
