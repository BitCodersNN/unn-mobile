// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_enums.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_keys.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_period.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_policy.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_target.dart';

class AnnouncementAction {
  final String label;
  final String url;

  const AnnouncementAction({required this.label, required this.url});

  factory AnnouncementAction.fromJson(JsonMap json) => AnnouncementAction(
    label: (json[AnnouncementJsonKeys.label] as String? ?? '').trim(),
    url: (json[AnnouncementJsonKeys.url] as String? ?? '').trim(),
  );

  JsonMap toJson() => {
    AnnouncementJsonKeys.label: label,
    AnnouncementJsonKeys.url: url,
  };
}

class AnnouncementItem {
  final String id;
  final AnnouncementCategory category;
  final bool enabled;
  final int priority;
  final String? badge;
  final AnnouncementAnimation animation;
  final String title;
  final String text;
  final List<String> images;
  final AnnouncementPeriod period;
  final AnnouncementPolicy policy;
  final AnnouncementAction? action;
  final AnnouncementTarget target;

  const AnnouncementItem({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.text,
    this.enabled = true,
    this.badge,
    this.animation = AnnouncementAnimation.defaultAnimation,
    this.images = const [],
    this.period = const AnnouncementPeriod(),
    this.policy = const AnnouncementPolicy(),
    this.action,
    this.target = const AnnouncementTarget(),
  });

  factory AnnouncementItem.fromJson(
    Object? json, {
    AnnouncementCategory defaultCategory = AnnouncementCategory.giveaway,
  }) {
    final map = json! as JsonMap;
    final category = AnnouncementCategory.fromName(
      map[AnnouncementJsonKeys.category] as String?,
      fallback: defaultCategory,
    );
    final rawAction = map[AnnouncementJsonKeys.action];
    return AnnouncementItem(
      id: (map[AnnouncementJsonKeys.id] as String? ?? '').trim(),
      category: category,
      enabled: parseJsonBool(
        map[AnnouncementJsonKeys.enabled],
        defaultValue: true,
      ),
      priority:
          parseJsonInt(map[AnnouncementJsonKeys.priority]) ??
          category.defaultPriority,
      badge: _parseBadge(map, category),
      animation: AnnouncementAnimation.fromName(
        map[AnnouncementJsonKeys.animation] as String?,
      ),
      title: (map[AnnouncementJsonKeys.title] as String? ?? '').trim(),
      text:
          (map[AnnouncementJsonKeys.text] as String? ??
                  map[AnnouncementJsonKeys.body] as String? ??
                  '')
              .trim(),
      images: parseJsonStringList(map[AnnouncementJsonKeys.images]) ?? const [],
      period: AnnouncementPeriod.fromJson(map[AnnouncementJsonKeys.period]),
      policy: AnnouncementPolicy.fromJson(map[AnnouncementJsonKeys.policy]),
      action: rawAction is JsonMap
          ? AnnouncementAction.fromJson(rawAction)
          : null,
      target: AnnouncementTarget.fromJson(map[AnnouncementJsonKeys.target]),
    );
  }

  static String? _parseBadge(JsonMap json, AnnouncementCategory category) {
    if (!json.containsKey(AnnouncementJsonKeys.badge)) {
      return category.defaultBadge;
    }
    return readOptionalTrimmedString(json[AnnouncementJsonKeys.badge]);
  }

  JsonMap toJson() => {
    AnnouncementJsonKeys.id: id,
    AnnouncementJsonKeys.category: category.name,
    AnnouncementJsonKeys.enabled: enabled,
    AnnouncementJsonKeys.priority: priority,
    AnnouncementJsonKeys.badge: badge,
    AnnouncementJsonKeys.animation: animation.value,
    AnnouncementJsonKeys.title: title,
    AnnouncementJsonKeys.text: text,
    AnnouncementJsonKeys.images: images,
    AnnouncementJsonKeys.period: period.toJson(),
    AnnouncementJsonKeys.policy: policy.toJson(),
    if (action != null) AnnouncementJsonKeys.action: action!.toJson(),
    AnnouncementJsonKeys.target: target.toJson(),
  };
}
