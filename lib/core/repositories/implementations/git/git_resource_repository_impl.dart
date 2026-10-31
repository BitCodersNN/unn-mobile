// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/models/git/cached_git_resource.dart';
import 'package:unn_mobile/core/providers/interfaces/git/git_resource_cache_provider.dart';
import 'package:unn_mobile/core/repositories/interfaces/git/git_resource_repository.dart';
import 'package:unn_mobile/core/services/interfaces/common/last_commit_sha_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/git/git_resource_source.dart';

class GitResourceRepositoryImpl<T> implements GitResourceRepository<T> {
  final GitResourceCacheProvider<T> _cache;
  final GitResourceSource<T> _source;
  final LastCommitShaService _shaService;
  final LoggerService _logger;
  Future<CachedGitResource<T>?>? _refreshing;

  GitResourceRepositoryImpl(
    this._cache,
    this._source,
    this._shaService,
    this._logger,
  );

  @override
  Future<CachedGitResource<T>?> get() async =>
      await _cache.getData() ?? await refresh();

  @override
  Future<CachedGitResource<T>?> refresh() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<CachedGitResource<T>?> _refresh() async {
    CachedGitResource<T>? cached;
    try {
      cached = await _cache.getData();
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
    try {
      return await _loadUpdate(cached);
    } catch (error, stack) {
      _logger.logError(error, stack);
      return cached;
    }
  }

  Future<CachedGitResource<T>?> _loadUpdate(
    CachedGitResource<T>? cached,
  ) async {
    final sha = await _shaService.getSha(gitPath: _source.path);
    if (cached != null &&
        (sha == null || (!cached.isLegacy && sha == cached.sha))) {
      return cached;
    }
    final data = await _source.load(revision: sha ?? GitPath.branch);
    if (data == null) {
      return cached;
    }
    final updated = CachedGitResource(data: data, sha: sha);
    await _cache.saveData(updated);
    return updated;
  }
}
