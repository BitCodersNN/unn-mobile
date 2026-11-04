// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN


import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';

extension GradeFormatters on double? {
  String get formattedAverage =>
      this == null ? '—' : NumberFormat('0.00', 'ru_RU').format(this);
}

extension MarkTypeFormatters on MarkType? {
  String get labelFormatted => switch (this) {
    null => '—',
    MarkType.credited || MarkType.notCredited || MarkType.noShow => this!.label,
    _ => NumberFormat('0.#', 'ru_RU').format(this!.value),
  };
}
