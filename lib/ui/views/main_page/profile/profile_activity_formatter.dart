// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';

String formatProfileActivity(DateTime activity, {String? sex, DateTime? now}) {
  final date = activity.toLocal();
  final today = (now ?? DateTime.now()).toLocal().startOfDay;
  final day = switch (date) {
    final value when value.isSameDate(today) => 'сегодня',
    final value when value.isSameDate(today.copyWith(day: today.day - 1)) =>
      'вчера',
    _ => date.format(DatePattern.ddmmyyyy),
  };
  final prefix = switch (sex) {
    'M' => 'Был',
    'F' => 'Была',
    _ => 'Был(а)',
  };
  return '$prefix $day в ${date.format(DatePattern.hhmm)}';
}
