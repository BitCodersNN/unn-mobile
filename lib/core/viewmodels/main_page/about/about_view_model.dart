// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/models/about/author.dart';
import 'package:unn_mobile/core/models/about/authors_catalog.dart';
import 'package:unn_mobile/core/models/git/cached_git_resource.dart';
import 'package:unn_mobile/core/repositories/interfaces/git/git_resource_repository.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class AboutViewModel extends BaseViewModel {
  final GitResourceRepository<AuthorsCatalog> _authorsRepository;
  AuthorsCatalog? _authors;

  AboutViewModel(this._authorsRepository);

  List<Author> get authors => _authors?.authors ?? [];
  List<Author> get pastAuthors => _authors?.pastAuthors ?? [];
  bool get hasAuthorsCatalog => _authors != null;

  FutureOr<void> init() => busyCallAsync(() async {
    final refreshed = _authorsRepository.refresh();
    final cached = CancelableOperation.fromFuture(_authorsRepository.get());
    try {
      await Future.wait([
        cached.valueOrCancellation().then(_updateAuthors),
        refreshed.then((resource) async {
          if (resource != null) {
            await cached.cancel();
          }
          _updateAuthors(resource);
        }),
      ]);
    } finally {
      await cached.cancel();
    }
  });

  void _updateAuthors(CachedGitResource<AuthorsCatalog>? resource) {
    if (resource == null) {
      return;
    }
    final revision = resource.sha ?? GitPath.branch;
    final baseUrl =
        'https://${Host.gitHub}/${ApiPath.gitRepository}/${GitPath.authors.pathAt(revision)}';
    final updated = resource.data.withAvatarBaseUrl(baseUrl);
    if (_authors != null &&
        _sameAuthors(authors, updated.authors) &&
        _sameAuthors(pastAuthors, updated.pastAuthors)) {
      return;
    }
    _authors = updated;
    notifyListeners();
  }

  bool _sameAuthors(List<Author> first, List<Author> second) => listEquals(
    [for (final author in first) _authorValues(author)],
    [for (final author in second) _authorValues(author)],
  );

  (int?, String, String?, String) _authorValues(Author author) =>
      (author.userId, author.fullname, author.educationGroup, author.avatar);
}
