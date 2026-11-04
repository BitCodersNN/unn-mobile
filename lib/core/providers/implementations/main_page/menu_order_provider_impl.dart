// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/constants/string_keys/app_settings_keys.dart';
import 'package:unn_mobile/core/providers/interfaces/main_page/menu_order_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class MenuOrderProviderImpl implements MenuOrderProvider {
  final StorageService _storage;
  Future<void> _pendingSave = Future.value();

  MenuOrderProviderImpl(this._storage);

  @override
  Future<List<String>> getData() async {
    final value = await _storage.read(key: AppSettingsKeys.moreMenuPaths);
    if (value == null) {
      return const [];
    }
    Object? decoded;
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      return const [];
    }
    return decoded is List
        ? List.unmodifiable(decoded.whereType<String>())
        : const [];
  }

  @override
  Future<void> saveData(List<String> data) {
    final value = jsonEncode(data);
    final save = _pendingSave.then(
      (_) => _storage.write(key: AppSettingsKeys.moreMenuPaths, value: value),
    );
    _pendingSave = save.onError((error, stack) {});
    return save;
  }

  @override
  Future<bool> isContained() =>
      _storage.containsKey(key: AppSettingsKeys.moreMenuPaths);

  @override
  Future<void> removeData() =>
      _storage.remove(key: AppSettingsKeys.moreMenuPaths);
}
