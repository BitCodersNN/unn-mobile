// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/birthday/birthday_greeting_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _BirthdayGreetingProviderKeys {
  static const String shownYearPrefix = 'birthday_greeting';
  static const String lastGreetingIdPrefix = 'birthday_greeting_last_id';
}

class BirthdayGreetingProviderImpl implements BirthdayGreetingProvider {
  final StorageService _storage;
  final Map<int, int?> _shownYears = {};

  BirthdayGreetingProviderImpl(this._storage);

  String _key(int userId) =>
      '${_BirthdayGreetingProviderKeys.shownYearPrefix}.$userId';

  @override
  Future<int?> getShownYear(int userId) async {
    if (_shownYears.containsKey(userId)) {
      return _shownYears[userId];
    }
    final savedYear = await _storage.read(key: _key(userId));
    return _shownYears.putIfAbsent(userId, () => int.tryParse(savedYear ?? ''));
  }

  @override
  Future<void> saveShownYear(int userId, int year) async {
    _shownYears[userId] = year;
    await _storage.write(key: _key(userId), value: year.toString());
  }

  @override
  Future<String?> getLastGreetingId(int userId) => _storage.read(
    key: '${_BirthdayGreetingProviderKeys.lastGreetingIdPrefix}.$userId',
  );

  @override
  Future<void> saveLastGreetingId(int userId, String greetingId) =>
      _storage.write(
        key: '${_BirthdayGreetingProviderKeys.lastGreetingIdPrefix}.$userId',
        value: greetingId,
      );
}
