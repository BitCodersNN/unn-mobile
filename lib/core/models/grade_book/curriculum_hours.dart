// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _JsonKeys {
  static const String lectures = 'lections';
  static const String practice = 'practice';
  static const String labs = 'labs';
  static const String independent = 'self';
}

class CurriculumHours {
  final int lectures;
  final int practice;
  final int labs;
  final int independent;

  const CurriculumHours({
    required this.lectures,
    required this.practice,
    required this.labs,
    required this.independent,
  });

  factory CurriculumHours.fromJson(JsonMap json) => CurriculumHours(
    lectures: (json[_JsonKeys.lectures] as num?)?.toInt() ?? 0,
    practice: (json[_JsonKeys.practice] as num?)?.toInt() ?? 0,
    labs: (json[_JsonKeys.labs] as num?)?.toInt() ?? 0,
    independent: (json[_JsonKeys.independent] as num?)?.toInt() ?? 0,
  );

  factory CurriculumHours.fromTerms(Iterable<JsonMap> terms) {
    final hours = terms.map(CurriculumHours.fromJson).toList();
    return CurriculumHours(
      lectures: hours.fold(0, (total, term) => total + term.lectures),
      practice: hours.fold(0, (total, term) => total + term.practice),
      labs: hours.fold(0, (total, term) => total + term.labs),
      independent: hours.fold(0, (total, term) => total + term.independent),
    );
  }

  JsonMap toJson() => {
    _JsonKeys.lectures: lectures,
    _JsonKeys.practice: practice,
    _JsonKeys.labs: labs,
    _JsonKeys.independent: independent,
  };
}
