// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/offline_schedule.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _OfflineScheduleProviderKeys {
  static const scheduleKey = 'offline_schedule';
}

class OfflineScheduleProviderImpl implements OfflineScheduleProvider {
  final StorageService _storage;

  OfflineScheduleProviderImpl(this._storage);

  @override
  Future<Map<IdType, OfflineSchedule>> getData() async {
    if (!(await isContained())) {
      return {};
    }

    final JsonMap jsonMap = jsonDecode(
      (await _storage.read(
        key: _OfflineScheduleProviderKeys.scheduleKey,
      ))!,
    );

    return jsonMap.map(
      (key, value) => MapEntry(
        IdType.values[int.parse(key)],
        OfflineSchedule.fromJson(value! as JsonMap),
      ),
    );
  }

  @override
  Future<void> saveData(Map<IdType, OfflineSchedule>? schedule) async {
    if (schedule == null) {
      return;
    }

    final jsonMap = schedule.map(
      (key, value) => MapEntry(key.index.toString(), value.toJson()),
    );
    await _storage.write(
      key: _OfflineScheduleProviderKeys.scheduleKey,
      value: jsonEncode(jsonMap),
    );
  }

  @override
  Future<bool> isContained() => _storage.containsKey(
        key: _OfflineScheduleProviderKeys.scheduleKey,
      );

  @override
  Future<void> removeData() => _storage.remove(
        key: _OfflineScheduleProviderKeys.scheduleKey,
      );
}
