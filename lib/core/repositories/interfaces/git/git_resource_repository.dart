// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/git/cached_git_resource.dart';

abstract interface class GitResourceRepository<T> {
  /// Возвращает кешированный ресурс или загружает его при отсутствии кеша.
  Future<CachedGitResource<T>?> get();

  /// Обновляет ресурс при изменении SHA, сохраняя прежний кеш при ошибке.
  Future<CachedGitResource<T>?> refresh();
}
