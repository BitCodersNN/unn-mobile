// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_enums.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_keys.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_user_state.dart';

class AnnouncementPolicy {
  final AnnouncementFrequency frequency;
  final int? intervalHours;
  final int? maxShows;
  final bool stopOnAction;
  final AnnouncementFrequency? frequencyAfterAction;
  final bool stopOnDismiss;

  const AnnouncementPolicy({
    this.frequency = AnnouncementFrequency.oncePerDay,
    this.intervalHours,
    this.maxShows,
    this.stopOnAction = true,
    this.frequencyAfterAction,
    this.stopOnDismiss = false,
  });

  factory AnnouncementPolicy.fromJson(Object? json) {
    if (json is! JsonMap) {
      return const AnnouncementPolicy();
    }
    final rawAfterAction =
        json[AnnouncementJsonKeys.frequencyAfterAction] as String?;
    return AnnouncementPolicy(
      frequency: AnnouncementFrequency.fromName(
        json[AnnouncementJsonKeys.frequency] as String?,
      ),
      intervalHours: parseJsonInt(json[AnnouncementJsonKeys.intervalHours]),
      maxShows: parseJsonInt(json[AnnouncementJsonKeys.maxShows]),
      stopOnAction: parseJsonBool(
        json[AnnouncementJsonKeys.stopOnAction],
        defaultValue: true,
      ),
      frequencyAfterAction: rawAfterAction == null
          ? null
          : AnnouncementFrequency.fromName(rawAfterAction),
      stopOnDismiss: parseJsonBool(json[AnnouncementJsonKeys.stopOnDismiss]),
    );
  }

  bool isEligible(AnnouncementUserState state, DateTime now) {
    if (stopOnAction && state.actionClicked) {
      return false;
    }
    if (stopOnDismiss && state.dismissed) {
      return false;
    }
    if (maxShows != null && state.showCount >= maxShows!) {
      return false;
    }
    final effectiveFreq =
        state.actionClicked && !stopOnAction && frequencyAfterAction != null
        ? frequencyAfterAction!
        : frequency;
    return switch (effectiveFreq) {
      AnnouncementFrequency.once => state.showCount == 0,
      AnnouncementFrequency.everyLaunch => true,
      AnnouncementFrequency.oncePerDay =>
        state.lastShownAt == null ||
            !state.lastShownAt!.toLocal().isSameDate(now.toLocal()),
      AnnouncementFrequency.intervalHours =>
        state.lastShownAt == null ||
            now.difference(state.lastShownAt!).inHours >= (intervalHours ?? 24),
    };
  }

  JsonMap toJson() => {
    AnnouncementJsonKeys.frequency: frequency.value,
    if (intervalHours != null)
      AnnouncementJsonKeys.intervalHours: intervalHours,
    if (maxShows != null) AnnouncementJsonKeys.maxShows: maxShows,
    AnnouncementJsonKeys.stopOnAction: stopOnAction,
    if (frequencyAfterAction != null)
      AnnouncementJsonKeys.frequencyAfterAction: frequencyAfterAction!.value,
    AnnouncementJsonKeys.stopOnDismiss: stopOnDismiss,
  };
}
