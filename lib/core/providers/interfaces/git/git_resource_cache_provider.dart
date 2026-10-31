// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/git/cached_git_resource.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class GitResourceCacheProvider<T>
    implements DataProvider<CachedGitResource<T>?> {
  /// Читает данные ресурса и его SHA из хранилища.
  @override
  Future<CachedGitResource<T>?> getData();

  /// Сохраняет данные ресурса и SHA одной записью.
  @override
  Future<void> saveData(CachedGitResource<T>? data);

  /// Проверяет наличие кешированного ресурса.
  @override
  Future<bool> isContained();

  /// Удаляет кеш ресурса и прежнюю отдельную запись SHA.
  @override
  Future<void> removeData();
}
