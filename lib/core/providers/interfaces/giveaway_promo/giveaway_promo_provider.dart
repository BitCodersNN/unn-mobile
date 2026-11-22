// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/giveaway_promo/announcement_catalog.dart';

abstract interface class GiveawayPromoProvider {
  /// Возвращает карту состояний показа объявлений по их идентификаторам.
  Future<Map<String, AnnouncementUserState>> getStates();

  /// Возвращает состояние показа объявления с идентификатором [announcementId].
  Future<AnnouncementUserState> getState(String announcementId);

  /// Сохраняет состояние показа объявления [state] по идентификатору [announcementId].
  Future<void> saveState(String announcementId, AnnouncementUserState state);

  /// Возвращает идентификатор последнего выбранного объявления.
  Future<String?> getLastPickedId();

  /// Сохраняет идентификатор последнего выбранного объявления.
  Future<void> saveLastPickedId(String announcementId);
}
