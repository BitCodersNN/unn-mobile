import 'dart:convert';

import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/services/interfaces/post_with_loaded_info_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class _PostWithLoadedInfoProviderKeys {
  static const postWithLoadedInfoKey = 'post_with_loaded_info_key';
  static const dateTimeWhenPostsWereLastSaved =
      'time_when_posts_were_last_saved';
}

class PostWithLoadedInfoProviderImpl implements PostWithLoadedInfoProvider {
  final StorageService storage;

  PostWithLoadedInfoProviderImpl(this.storage);

  @override
  Future<List<PostWithLoadedInfo>?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    final jsonList = jsonDecode(
      (await storage.read(
        key: _PostWithLoadedInfoProviderKeys.postWithLoadedInfoKey,
      ))!,
    );

    final List<PostWithLoadedInfo> postWithLoadedInfo = [];

    for (final jsonMap in jsonList) {
      postWithLoadedInfo.add(PostWithLoadedInfo.fromJson(jsonMap));
    }

    return postWithLoadedInfo;
  }

  @override
  Future<DateTime?> getDateTimePublishedPost() async {
    if (!(await isContained())) {
      return null;
    }

    final dateTimeString = await storage.read(
      key: _PostWithLoadedInfoProviderKeys.dateTimeWhenPostsWereLastSaved,
    );

    if (dateTimeString == null) {
      return null;
    }

    return DateTime.parse(dateTimeString);
  }

  @override
  Future<bool> isContained() async {
    return await storage.containsKey(
      key: _PostWithLoadedInfoProviderKeys.postWithLoadedInfoKey,
    );
  }

  @override
  Future<void> saveData(List<PostWithLoadedInfo>? data) async {
    if (data == null) {
      return;
    }

    final dynamic jsonList = [];
    for (final postWithLoadedInfo in data) {
      jsonList.add(postWithLoadedInfo.toJson());
    }

    await storage.write(
      key: _PostWithLoadedInfoProviderKeys.postWithLoadedInfoKey,
      value: jsonEncode(jsonList),
    );
  }

  @override
  Future<void> saveDateTimePublishedPost(DateTime dateTime) async {
    await storage.write(
      key: _PostWithLoadedInfoProviderKeys.dateTimeWhenPostsWereLastSaved,
      value: dateTime.toString(),
    );
  }
}
