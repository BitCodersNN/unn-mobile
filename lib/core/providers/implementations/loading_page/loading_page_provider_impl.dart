// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';
import 'package:unn_mobile/core/providers/interfaces/loading_page/loading_page_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _LoadingPageProviderKeys {
  static const loadingPagesKey = 'loading_pages_key';
}

class LoadingPageProviderImpl implements LoadingPageProvider {
  final StorageService _storage;
  final LoggerService _loggerService;

  LoadingPageProviderImpl(this._storage, this._loggerService);

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

    final loadingPages = parseJsonIterable<LoadingPageModel>(
      jsonList,
      LoadingPageModel.fromJson,
      _loggerService,
    );

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
