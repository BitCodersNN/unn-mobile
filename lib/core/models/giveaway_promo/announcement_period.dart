// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_keys.dart';

class AnnouncementPeriod {
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isEndDateOnly;

  const AnnouncementPeriod({
    this.startAt,
    this.endAt,
    this.isEndDateOnly = false,
  });

  factory AnnouncementPeriod.fromJson(Object? json) {
    if (json is! JsonMap) {
      return const AnnouncementPeriod();
    }
    final rawStart = readOptionalTrimmedString(
      json[AnnouncementJsonKeys.startAt],
    );
    final rawEnd = readOptionalTrimmedString(json[AnnouncementJsonKeys.endAt]);
    final startAt = rawStart == null ? null : DateTime.tryParse(rawStart);
    final endAt = rawEnd == null ? null : DateTime.tryParse(rawEnd);
    final isEndDateOnly =
        rawEnd != null &&
        endAt != null &&
        RegularExpressions.isoDateOnlyRegExp.hasMatch(rawEnd);
    return AnnouncementPeriod(
      startAt: startAt,
      endAt: endAt,
      isEndDateOnly: isEndDateOnly,
    );
  }

  bool isActiveAt(DateTime now) {
    if (startAt != null && now.isBefore(startAt!)) {
      return false;
    }
    if (endAt != null) {
      final effectiveEnd = isEndDateOnly ? endAt!.toLocal().endOfDay : endAt!;
      if (now.isAfter(effectiveEnd)) {
        return false;
      }
    }
    return true;
  }

  JsonMap toJson() => {
    if (startAt != null)
      AnnouncementJsonKeys.startAt: startAt!.toIso8601String(),
    if (endAt != null)
      AnnouncementJsonKeys.endAt: isEndDateOnly
          ? _formatDateOnly(endAt!)
          : endAt!.toIso8601String(),
  };

  static String _formatDateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
