// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_keys.dart';

class AnnouncementUserState {
  final int showCount;
  final DateTime? lastShownAt;
  final bool actionClicked;
  final bool dismissed;

  const AnnouncementUserState({
    this.showCount = 0,
    this.lastShownAt,
    this.actionClicked = false,
    this.dismissed = false,
  });

  factory AnnouncementUserState.fromJson(Object? json) {
    if (json is! JsonMap) {
      return const AnnouncementUserState();
    }
    final rawLastShown = json[AnnouncementJsonKeys.lastShownAt] as String?;
    return AnnouncementUserState(
      showCount: parseJsonInt(json[AnnouncementJsonKeys.showCount]) ?? 0,
      lastShownAt: rawLastShown == null
          ? null
          : DateTime.tryParse(rawLastShown),
      actionClicked: parseJsonBool(json[AnnouncementJsonKeys.actionClicked]),
      dismissed: parseJsonBool(json[AnnouncementJsonKeys.dismissed]),
    );
  }

  AnnouncementUserState copyWith({
    int? showCount,
    DateTime? lastShownAt,
    bool? actionClicked,
    bool? dismissed,
  }) => AnnouncementUserState(
    showCount: showCount ?? this.showCount,
    lastShownAt: lastShownAt ?? this.lastShownAt,
    actionClicked: actionClicked ?? this.actionClicked,
    dismissed: dismissed ?? this.dismissed,
  );

  JsonMap toJson() => {
    AnnouncementJsonKeys.showCount: showCount,
    if (lastShownAt != null)
      AnnouncementJsonKeys.lastShownAt: lastShownAt!.toIso8601String(),
    AnnouncementJsonKeys.actionClicked: actionClicked,
    AnnouncementJsonKeys.dismissed: dismissed,
  };
}
