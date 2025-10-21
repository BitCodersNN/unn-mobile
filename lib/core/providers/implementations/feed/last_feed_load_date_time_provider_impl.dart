// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _LastFeedLoadDateTimeProviderKeys {
  static const String feedTimeStorageKey = 'last_feed_load_date_time';
}

class LastFeedLoadDateTimeProviderImpl implements LastFeedLoadDateTimeProvider {
  final StorageService _storage;

  DateTime? _storedTime;

  LastFeedLoadDateTimeProviderImpl(this._storage);

  @override
  DateTime? get lastFeedLoadDateTime => _storedTime;

  @override
  Future<DateTime?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    return _storedTime = DateTime.tryParse(
      (await _storage.read(
            key: _LastFeedLoadDateTimeProviderKeys.feedTimeStorageKey,
          )) ??
          '_',
    );
  }

  @override
  Future<bool> isContained() => _storage.containsKey(
        key: _LastFeedLoadDateTimeProviderKeys.feedTimeStorageKey,
      );

  @override
  Future<void> saveData(DateTime? data) async {
    await _storage.write(
      key: _LastFeedLoadDateTimeProviderKeys.feedTimeStorageKey,
      value: data?.toIso8601String() ?? '_',
    );
    _storedTime = data;
  }

  @override
  Future<void> removeData() => _storage.remove(
        key: _LastFeedLoadDateTimeProviderKeys.feedTimeStorageKey,
      );
}
