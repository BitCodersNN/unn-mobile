// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:intl/intl.dart';

class DateTimeParser {
  static DateTime parse(
    String input,
    String pattern, {
    String local = 'ru_RU',
  }) =>
      DateFormat(pattern, local).parse(input);

  static String format(
    DateTime dateTime,
    String pattern, {
    String local = 'ru_RU',
  }) =>
      DateFormat(pattern, local).format(dateTime);
}
