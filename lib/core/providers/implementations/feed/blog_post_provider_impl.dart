// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/camel_case_converter.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/blog_post_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class BlogPostProviderImpl implements BlogPostProvider {
  final StorageService _storage;
  final LoggerService _loggerService;
  final String _key;

  BlogPostProviderImpl(
    this._storage,
    this._loggerService,
    BlogPostType blogPostType,
  ) : _key = '${blogPostType.stringValue.toSnakeCase()}_blog_posts';

  @override
  Future<List<BlogPost>?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    final jsonString = await _storage.read(key: _key);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    return parseJsonIterable<BlogPost>(
      jsonDecode(jsonString) as List<dynamic>,
      BlogPost.fromJson,
      _loggerService,
    );
  }

  @override
  Future<bool> isContained() => _storage.containsKey(
        key: _key,
      );

  @override
  Future<void> saveData(List<BlogPost>? data) async {
    if (data == null || data.isEmpty) {
      return _storage.write(key: _key, value: '');
    }

    final jsonList = [for (final blogPost in data) blogPost.toJson()];
    final jsonString = jsonEncode(jsonList);

    await _storage.write(key: _key, value: jsonString);
  }

  @override
  Future<void> removeData() => _storage.remove(key: _key);
}
