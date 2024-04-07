import 'dart:convert';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/services/interfaces/post_with_loaded_info_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class _PostWithLoadedInfoProviderKeys {
  static const postWithLoadedInfoKey = 'post_with_loaded_info_key';
  static const dateTimeWhenPostsWereLastSaved =
      'time_when_posts_were_last_saved';
}

class PostWithLoadedInfoProviderImpl implements PostWithLoadedInfoProvider {
  final _securityStorage = Injector.appInstance.get<StorageService>();

  @override
  Future<List<PostWithLoadedInfo>?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    final jsonList = jsonDecode(
      (await _securityStorage.read(
        key: _PostWithLoadedInfoProviderKeys.postWithLoadedInfoKey,
      ))!,
    );

    List<PostWithLoadedInfo> postWithLoadedInfo = [];

    for (final jsonMap in jsonList) {
      postWithLoadedInfo.add(PostWithLoadedInfo.fromJson(jsonMap));
    }

    return postWithLoadedInfo;
  }

  @override
  Future<DateTime?> getDateTimeWhenPostsWereLastSaved() async {
    if (!(await isContained())) {
      return null;
    }

    final dateTimeString = await _securityStorage.read(
      key: _PostWithLoadedInfoProviderKeys.dateTimeWhenPostsWereLastSaved,
    );

    if (dateTimeString == null) {
      return null;
    }

    return DateTime.parse(dateTimeString);
  }

  @override
  Future<bool> isContained() async {
    return await _securityStorage.containsKey(
        key: _PostWithLoadedInfoProviderKeys.postWithLoadedInfoKey);
  }

  @override
  Future<void> saveData(List<PostWithLoadedInfo>? data) async {
    if (data == null) {
      return;
    }

    dynamic jsonList = [];
    for (final postWithLoadedInfo in data) {
      jsonList.add(postWithLoadedInfo.toJson());
    }

    await _securityStorage.write(
      key: _PostWithLoadedInfoProviderKeys.postWithLoadedInfoKey,
      value: jsonEncode(jsonList),
    );
  }

  @override
  Future<void> saveDateTimeWhenPostsWereLastSaved(DateTime dateTime) async {
        await _securityStorage.write(
      key: _PostWithLoadedInfoProviderKeys.dateTimeWhenPostsWereLastSaved,
      value: dateTime.toString(),
    );
  }
}
