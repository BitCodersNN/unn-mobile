// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:intl/intl.dart';

class DateTimeParser {
  static DateTime parse(
    String input,
    String pattern, {
    String local = 'ru_RU',
  }) {
    final formatter = DateFormat(pattern, local);
    return formatter.parse(input);
  }
}
