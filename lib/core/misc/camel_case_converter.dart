// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/regular_expressions.dart';

extension CamelCaseConverter on String {
  String toSnakeCase() {
    final result = replaceAllMapped(
      RegularExpressions.uppercaseLettersRegExp,
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
    return result.startsWith('_') ? result.substring(1) : result;
  }

  String toKebabCase() {
    final result = replaceAllMapped(
      RegularExpressions.uppercaseLettersRegExp,
      (match) => '-${match.group(0)!.toLowerCase()}',
    );
    return result.startsWith('-') ? result.substring(1) : result;
  }
}
