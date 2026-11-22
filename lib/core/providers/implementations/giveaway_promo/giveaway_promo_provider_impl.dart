// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_catalog.dart';
import 'package:unn_mobile/core/providers/interfaces/giveaway_promo/giveaway_promo_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _GiveawayPromoProviderKeys {
  static const String states = 'giveaway_promo_announcement_states';
  static const String lastPickedId = 'giveaway_promo_last_picked_id';
}

class GiveawayPromoProviderImpl implements GiveawayPromoProvider {
  final StorageService _storage;

  GiveawayPromoProviderImpl(this._storage);

  @override
  Future<Map<String, AnnouncementUserState>> getStates() async {
    final raw = await _storage.read(key: _GiveawayPromoProviderKeys.states);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    return _decodeStates(raw);
  }

  @override
  Future<AnnouncementUserState> getState(String announcementId) async =>
      (await getStates())[announcementId] ?? const AnnouncementUserState();

  @override
  Future<void> saveState(
    String announcementId,
    AnnouncementUserState state,
  ) async {
    final states = await getStates();
    states[announcementId] = state;
    await _storage.write(
      key: _GiveawayPromoProviderKeys.states,
      value: jsonEncode({
        for (final entry in states.entries) entry.key: entry.value.toJson(),
      }),
    );
  }

  @override
  Future<String?> getLastPickedId() =>
      _storage.read(key: _GiveawayPromoProviderKeys.lastPickedId);

  @override
  Future<void> saveLastPickedId(String announcementId) => _storage.write(
    key: _GiveawayPromoProviderKeys.lastPickedId,
    value: announcementId,
  );

  Map<String, AnnouncementUserState> _decodeStates(String raw) {
    try {
      return _parseStates(raw);
    } catch (_) {
      return {};
    }
  }

  Map<String, AnnouncementUserState> _parseStates(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! JsonMap) {
      return {};
    }
    return {
      for (final entry in decoded.entries)
        if (entry.value is JsonMap)
          entry.key: AnnouncementUserState.fromJson(entry.value),
    };
  }
}
