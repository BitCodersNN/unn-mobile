// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as time_zones;
import 'package:timezone/timezone.dart' as tz;

class ScheduleTime {
  static const zoneId = 'Europe/Moscow';
  static final tz.Location _location = _loadLocation();

  static tz.Location _loadLocation() {
    time_zones.initializeTimeZones();
    return tz.getLocation(zoneId);
  }

  static tz.TZDateTime now() => tz.TZDateTime.now(_location);

  static tz.TZDateTime inZone(DateTime instant) =>
      tz.TZDateTime.from(instant, _location);

  static tz.TZDateTime startOfDay(DateTime instant) {
    final date = inZone(instant);
    return tz.TZDateTime(_location, date.year, date.month, date.day);
  }

  static tz.TZDateTime parse(String input, String pattern) {
    final fields = DateFormat(pattern, 'ru_RU').parseUtc(input);
    return tz.TZDateTime(
      _location,
      fields.year,
      fields.month,
      fields.day,
      fields.hour,
      fields.minute,
      fields.second,
      fields.millisecond,
      fields.microsecond,
    );
  }
}
