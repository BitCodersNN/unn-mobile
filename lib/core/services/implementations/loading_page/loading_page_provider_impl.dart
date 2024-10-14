part of '../library.dart';

class _LoadingPageProviderKeys {
  static const loadingPagesKey = 'loading_pages_key';
}

class LoadingPageProviderImpl implements LoadingPageProvider {
  final StorageService _storage;

  LoadingPageProviderImpl(this._storage);

  @override
  Future<List<LoadingPageModel>?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    final jsonList = jsonDecode(
      (await _storage.read(
        key: _LoadingPageProviderKeys.loadingPagesKey,
      ))!,
    );

    final List<LoadingPageModel> loadingPages = [];

    for (final jsonMap in jsonList) {
      loadingPages.add(LoadingPageModel.fromJson(jsonMap));
    }

    return loadingPages;
  }

  @override
  Future<void> saveData(List<LoadingPageModel>? loadingPages) async {
    if (loadingPages == null) {
      return;
    }

    final dynamic jsonList = [];
    for (final loadingPage in loadingPages) {
      jsonList.add(loadingPage.toJson());
    }
    await _storage.write(
      key: _LoadingPageProviderKeys.loadingPagesKey,
      value: jsonEncode(jsonList),
    );
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(
      key: _LoadingPageProviderKeys.loadingPagesKey,
    );
  }
}
