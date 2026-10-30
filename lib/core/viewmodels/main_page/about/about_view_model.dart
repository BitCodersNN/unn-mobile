// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

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

  FutureOr<void> init() => busyCallAsync(() async {
    _updateAuthors(await _authorsRepository.get());
    unawaited(_refresh());
  });

  Future<void> _refresh() async {
    _updateAuthors(await _authorsRepository.refresh());
  }

  void _updateAuthors(CachedGitResource<AuthorsCatalog>? resource) {
    if (resource == null) {
      return;
    }
    final revision = resource.sha ?? GitPath.branch;
    final baseUrl =
        'https://${Host.gitHub}/${ApiPath.gitRepository}/${GitPath.authors.pathAt(revision)}';
    _authors = resource.data.withAvatarBaseUrl(baseUrl);
    notifyListeners();
  }
}
