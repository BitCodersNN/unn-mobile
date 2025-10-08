// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/constants/string_keys/authors_config_keys.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/about/author.dart';
import 'package:unn_mobile/core/providers/interfaces/about/authors_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _AuthorsProviderKeys {
  static const authorsKey = 'authors_key';
}

class AuthorsProviderImpl implements AuthorsProvider {
  final StorageService _storage;
  final LoggerService _loggerService;

  AuthorsProviderImpl(this._storage, this._loggerService);

  @override
  Future<Map<String, List<Author>>?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    final jsonMap = jsonDecode(
      (await _storage.read(
        key: _AuthorsProviderKeys.authorsKey,
      ))!,
    );

    return {
      AuthorsConfigKeys.authors: parseJsonIterable<Author>(
        jsonMap[AuthorsConfigKeys.authors],
        Author.fromJson,
        _loggerService,
      ),
      AuthorsConfigKeys.pastAuthors: parseJsonIterable<Author>(
        jsonMap[AuthorsConfigKeys.pastAuthors],
        Author.fromJson,
        _loggerService,
      ),
    };
  }

  @override
  Future<void> saveData(Map<String, List<Author>>? authors) async {
    if (authors == null) return;

    final Map<String, List<Map<String, dynamic>>> jsonMap = {};
    for (final entry in authors.entries) {
      jsonMap[entry.key] =
          entry.value.map((author) => author.toJson()).toList();
    }

    await _storage.write(
      key: _AuthorsProviderKeys.authorsKey,
      value: jsonEncode(jsonMap),
    );
  }

  @override
  Future<bool> isContained() async => _storage.containsKey(
        key: _AuthorsProviderKeys.authorsKey,
      );
}
