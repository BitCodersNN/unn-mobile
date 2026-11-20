// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';

String formatRelativeDateTime(DateTime date, {DateTime? now}) {
  final local = date.toLocal();
  final today = (now ?? DateTime.now()).toLocal();
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  final day = local.isSameDate(today)
      ? 'сегодня'
      : local.isSameDate(yesterday)
      ? 'вчера'
      : '${local.format(DatePattern.dMMMM)}${local.year == today.year ? '' : ' ${local.year}'}';
  return '$day, ${local.format(DatePattern.hhmm)}';
}
