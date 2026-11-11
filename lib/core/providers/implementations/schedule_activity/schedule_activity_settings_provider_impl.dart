// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule_activity/schedule_activity_settings.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule_activity/schedule_activity_settings_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class ScheduleActivitySettingsProviderImpl
    implements ScheduleActivitySettingsProvider {
  static const _key = 'scheduleActivitySettings';
  final StorageService _storage;

  ScheduleActivitySettingsProviderImpl(this._storage);

  @override
  Future<ScheduleActivitySettings> load() async {
    final value = await _storage.read(key: _key);
    if (value == null) {
      return const ScheduleActivitySettings();
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      return const ScheduleActivitySettings();
    }
    return decoded is JsonMap
        ? ScheduleActivitySettings.fromJson(decoded)
        : const ScheduleActivitySettings();
  }

  @override
  Future<void> save(ScheduleActivitySettings settings) =>
      _storage.write(key: _key, value: jsonEncode(settings.toJson()));
}
