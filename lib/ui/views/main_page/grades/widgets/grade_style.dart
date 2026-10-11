// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';

String formatGradeAverage(double? average) =>
    average == null ? '—' : NumberFormat('0.00', 'ru_RU').format(average);

String gradeLabel(MarkType type) => switch (type) {
      MarkType.credited ||
      MarkType.notCredited ||
      MarkType.noShow =>
        type.label,
      _ => NumberFormat('0.#', 'ru_RU').format(type.value),
    };
