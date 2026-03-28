import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeRangeExtension on DateTimeRange? {
  String formatStart({
    required String pattern,
    String defaultValue = '',
  }) {
    if (this == null) {
      return defaultValue;
    }
    return DateFormat(pattern).format(this!.start);
  }

  String formatEnd({
    required String pattern,
    String defaultValue = '',
  }) {
    if (this == null) {
      return defaultValue;
    }
    return DateFormat(pattern).format(this!.end);
  }
}
