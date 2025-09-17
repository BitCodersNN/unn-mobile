// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/regular_expressions.dart';

String camelToSnake(String text) {
  final result = text.replaceAllMapped(
    RegularExpressions.uppercaseLettersRegExp,
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
  return result.startsWith('_') ? result.substring(1) : result;
}

String camelToKebab(String text) {
  final result = text.replaceAllMapped(
    RegularExpressions.uppercaseLettersRegExp,
    (match) => '-${match.group(0)!.toLowerCase()}',
  );
  return result.startsWith('-') ? result.substring(1) : result;
}
