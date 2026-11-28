// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_enums.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_item.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_keys.dart';

export 'package:unn_mobile/core/models/giveaway_promo/announcement_enums.dart';
export 'package:unn_mobile/core/models/giveaway_promo/announcement_item.dart';
export 'package:unn_mobile/core/models/giveaway_promo/announcement_period.dart';
export 'package:unn_mobile/core/models/giveaway_promo/announcement_policy.dart';
export 'package:unn_mobile/core/models/giveaway_promo/announcement_target.dart';
export 'package:unn_mobile/core/models/giveaway_promo/announcement_user_state.dart';

class AnnouncementCatalog {
  final List<AnnouncementItem> giveaways;
  final List<AnnouncementItem> ads;
  final List<AnnouncementItem> updates;

  AnnouncementCatalog({
    Iterable<AnnouncementItem> giveaways = const [],
    Iterable<AnnouncementItem> ads = const [],
    Iterable<AnnouncementItem> updates = const [],
  }) : giveaways = List.unmodifiable(giveaways),
       ads = List.unmodifiable(ads),
       updates = List.unmodifiable(updates);

  factory AnnouncementCatalog.fromJson(Object? json) {
    if (json is JsonMap &&
        (json.containsKey(AnnouncementJsonKeys.giveaways) ||
            json.containsKey(AnnouncementJsonKeys.ads) ||
            json.containsKey(AnnouncementJsonKeys.updates))) {
      return AnnouncementCatalog(
        giveaways: _parseItemList(
          json[AnnouncementJsonKeys.giveaways],
          defaultCategory: AnnouncementCategory.giveaway,
        ),
        ads: _parseItemList(
          json[AnnouncementJsonKeys.ads],
          defaultCategory: AnnouncementCategory.ad,
        ),
        updates: _parseItemList(
          json[AnnouncementJsonKeys.updates],
          defaultCategory: AnnouncementCategory.update,
        ),
      );
    }

    final rawItems = json is JsonMap ? json[AnnouncementJsonKeys.items] : json;
    final items = _parseItemList(rawItems);
    return AnnouncementCatalog(
      giveaways: items.where(
        (item) => item.category == AnnouncementCategory.giveaway,
      ),
      ads: items.where((item) => item.category == AnnouncementCategory.ad),
      updates: items.where(
        (item) => item.category == AnnouncementCategory.update,
      ),
    );
  }

  factory AnnouncementCatalog.fromCategoryFiles({
    Object? giveawaysJson,
    Object? adsJson,
    Object? updatesJson,
  }) => AnnouncementCatalog(
    giveaways: _parseCategoryFile(giveawaysJson, AnnouncementCategory.giveaway),
    ads: _parseCategoryFile(adsJson, AnnouncementCategory.ad),
    updates: _parseCategoryFile(updatesJson, AnnouncementCategory.update),
  );

  List<AnnouncementItem> get allItems => [...updates, ...giveaways, ...ads];

  Set<String> get imagePaths => {
    for (final item in allItems)
      if (item.enabled) ...item.images,
  };

  JsonMap toJson() => {
    AnnouncementJsonKeys.giveaways: [
      for (final item in giveaways) item.toJson(),
    ],
    AnnouncementJsonKeys.ads: [for (final item in ads) item.toJson()],
    AnnouncementJsonKeys.updates: [for (final item in updates) item.toJson()],
  };

  static List<AnnouncementItem> _parseCategoryFile(
    Object? json,
    AnnouncementCategory category,
  ) {
    final rawList = switch (json) {
      final JsonMap map => map[AnnouncementJsonKeys.items],
      final List list => list,
      _ => null,
    };
    return _parseItemList(rawList, defaultCategory: category);
  }

  static List<AnnouncementItem> _parseItemList(
    Object? rawList, {
    AnnouncementCategory defaultCategory = AnnouncementCategory.giveaway,
  }) {
    if (rawList is! List) {
      return const [];
    }
    return [
      for (final item in rawList)
        if (item is JsonMap)
          AnnouncementItem.fromJson(item, defaultCategory: defaultCategory),
    ];
  }
}
