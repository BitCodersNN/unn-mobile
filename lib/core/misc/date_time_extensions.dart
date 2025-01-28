import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  bool isSameDate(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }

  bool isBeforeOrEqualIgnoringYear(DateTime other) {
    return other.month > month || (other.month == month && other.day >= day);
  }

  bool isAfterOrEqualIgnoringYear(DateTime other) {
    return month > other.month || (month == other.month && day >= other.day);
  }

  bool isDateInRangeIgnoringYear(DateTimeRange range) {
    return isAfterOrEqualIgnoringYear(range.start) &&
        isBeforeOrEqualIgnoringYear(range.end);
  }

  String toFormattedDateString() {
    return DateFormat('yyyy.MM.dd').format(this);
  }

  // ignore: non_constant_identifier_names
  String formatDateTime_ddMMyyyy_HHmmss() {
    return DateFormat('dd.MM.yyyy HH:mm:ss').format(this);
  }
}
