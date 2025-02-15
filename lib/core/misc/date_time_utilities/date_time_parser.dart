import 'package:intl/intl.dart';

class DateTimeParser {
  static DateTime parse(String input, String pattern) {
    final formatter = DateFormat(pattern);
    return formatter.parse(input);
  }
}
