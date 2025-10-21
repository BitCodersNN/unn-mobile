// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _OfflineScheduleProviderKeys {
  static const scheduleKey = 'schedule_key';
}

class OfflineScheduleProviderImpl implements OfflineScheduleProvider {
  final StorageService _storage;
  final LoggerService _loggerService;

  OfflineScheduleProviderImpl(this._storage, this._loggerService);

  @override
  Future<List<Subject>?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    final jsonList = jsonDecode(
      (await _storage.read(
        key: _OfflineScheduleProviderKeys.scheduleKey,
      ))!,
    );

    return parseJsonIterable<Subject>(
      jsonList,
      Subject.fromJson,
      _loggerService,
    );
  }

  @override
  Future<void> saveData(List<Subject>? schedule) async {
    if (schedule == null) {
      return;
    }

    final List jsonList = [];
    for (final subject in schedule) {
      jsonList.add(subject.toJson());
    }
    await _storage.write(
      key: _OfflineScheduleProviderKeys.scheduleKey,
      value: jsonEncode(jsonList),
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
