// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/git/cached_git_resource.dart';
import 'package:unn_mobile/core/providers/interfaces/git/git_resource_cache_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _GitResourceCacheKeys {
  static const String data = 'data';
  static const String sha = 'sha';
}

class GitResourceCacheProviderImpl<T> implements GitResourceCacheProvider<T> {
  final StorageService _storage;
  final LoggerService _logger;
  final T Function(Object? json) _fromJson;
  final JsonMap Function(Object? data) _toJson;
  final String key;
  final String? legacyShaKey;

  GitResourceCacheProviderImpl(
    this._storage,
    this._logger,
    this._fromJson, {
    required this.key,
    required JsonMap Function(T data) toJson,
    this.legacyShaKey,
  }) : _toJson = ((data) => toJson(data as T));

  @override
  Future<CachedGitResource<T>?> getData() async {
    try {
      return await _read();
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }

  Future<CachedGitResource<T>?> _read() async {
    final saved = await _storage.read(key: key);
    if (saved == null) {
      return null;
    }
    final json = jsonDecode(saved);
    if (json is JsonMap && json.containsKey(_GitResourceCacheKeys.data)) {
      return CachedGitResource(
        data: _fromJson(json[_GitResourceCacheKeys.data]),
        sha: json[_GitResourceCacheKeys.sha] as String?,
      );
    }
    final shaKey = legacyShaKey;
    final sha = shaKey == null
        ? (json is JsonMap ? json[_GitResourceCacheKeys.sha] as String? : null)
        : await _storage.read(key: shaKey);
    return CachedGitResource(
      data: _fromJson(json),
      sha: sha,
      isLegacy: true,
    );
  }

  @override
  Future<void> saveData(CachedGitResource<T>? data) async {
    if (data == null) {
      return;
    }
    await _storage.write(
      key: key,
      value: jsonEncode({
        _GitResourceCacheKeys.data: _toJson(data.data),
        _GitResourceCacheKeys.sha: data.sha,
      }),
    );
  }

  @override
  Future<bool> isContained() => _storage.containsKey(key: key);

  @override
  Future<void> removeData() async {
    await _storage.remove(key: key);
    final shaKey = legacyShaKey;
    if (shaKey != null) {
      await _storage.remove(key: shaKey);
    }
  }
}
