// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/lru_cache.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

abstract class CachedViewModelFactoryBase<TKey,
    TViewModel extends BaseViewModel> {
  final LRUCache<TKey, TViewModel> _cache;
  CachedViewModelFactoryBase(int cacheSize)
      : _cache = LRUCache<TKey, TViewModel>(cacheSize);

  @protected
  T getService<T>({String dependencyName = ''}) =>
      Injector.appInstance.get<T>(dependencyName: dependencyName);

  void putInCache(TKey key, TViewModel viewModel) {
    _cache.save(key, viewModel);
  }

  TViewModel getViewModel(TKey key) {
    TViewModel? viewmodel = _cache.get(key);
    viewmodel ??= createViewModel(key);
    _cache.save(key, viewmodel);
    return viewmodel;
  }

  @protected
  TViewModel createViewModel(TKey key);
}
