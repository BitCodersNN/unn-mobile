// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class StorageServiceImpl implements StorageService {
  SharedPreferences? _sharedPreferences;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  final Map<String, String?> _secureCache = {};
  final Map<String, String?> _nonSecureCache = {};

  @override
  Future<bool> containsKey({required String key, bool secure = false}) async {
    await _initIfNeeded();
    final cacheMap = secure ? _secureCache : _nonSecureCache;
    if (cacheMap.containsKey(key)) {
      return true;
    }
    return secure
        ? await _secureStorage.containsKey(key: key)
        : _sharedPreferences!.containsKey(key);
  }

  @override
  Future<String?> read({required String key, bool secure = false}) async {
    await _initIfNeeded();
    final cacheMap = secure ? _secureCache : _nonSecureCache;
    if (cacheMap.containsKey(key)) {
      return cacheMap[key];
    }
    final value = secure
        ? await _secureStorage.read(key: key)
        : _sharedPreferences!.getString(key);
    cacheMap.putIfAbsent(key, () => value);
    return value;
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    bool secure = false,
  }) async {
    await _initIfNeeded();
    final cacheMap = secure ? _secureCache : _nonSecureCache;
    cacheMap.update(key, (_) => value, ifAbsent: () => value);
    secure
        ? await _secureStorage.write(key: key, value: value)
        : _sharedPreferences!.setString(key, value);
  }

  @override
  Future<void> clear() async {
    await _initIfNeeded();
    _secureCache.clear();
    _nonSecureCache.clear();
    await _sharedPreferences!.clear();
    await _secureStorage.deleteAll();
  }

  Future<void> _initIfNeeded() async {
    WidgetsFlutterBinding.ensureInitialized();
    _sharedPreferences ??= await SharedPreferences.getInstance();
    if (_sharedPreferences == null) {
      throw Exception('Could not get storage instance');
    }
  }
}
