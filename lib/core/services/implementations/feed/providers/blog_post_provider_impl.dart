import 'dart:convert';

import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/services/interfaces/feed/providers/blog_post_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class BlogPostProviderImpl implements BlogPostProvider {
  final StorageService _storage;
  final String _key;

  BlogPostProviderImpl(this._storage, BlogPostType blogPostType)
      : _key = '${blogPostType.stringValue}BlogPosts';

  @override
  Future<List<BlogPost>?> getData() async {
    if (!(await isContained())) {
      return null;
    }
    final jsonString = await _storage.read(key: _key);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    final jsonList = jsonDecode(jsonString) as List<dynamic>;

    return jsonList.map<BlogPost>((jsonMap) {
      return BlogPost.fromJson(jsonMap);
    }).toList();
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(
      key: _key,
    );
  }

  @override
  Future<void> saveData(List<BlogPost>? data) async {
    if (data == null || data.isEmpty) {
      await _storage.write(key: _key, value: '');
      return;
    }
    final jsonList = data.map((blogPost) => blogPost.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await _storage.write(key: _key, value: jsonString);
  }
}
