// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/string_keys/authors_config_keys.dart';
import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/misc/git/update_last_commit_sha_and_config_if_changed.dart';
import 'package:unn_mobile/core/models/about/author.dart';
import 'package:unn_mobile/core/providers/interfaces/about/authors_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/about/last_commit_sha_authors_provider.dart';
import 'package:unn_mobile/core/services/interfaces/about/authors_config_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/last_commit_sha_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class AboutViewModel extends BaseViewModel {
  final AuthorsConfigService authorsConfigService;
  final AuthorsProvider authorsProvider;
  final LastCommitShaService lastCommitShaService;
  final LastCommitShaAuthorsProvider lastCommitShaProvider;

  Map<String, List<Author>>? _authors;

  List<Author> get authors => _authors?[AuthorsConfigKeys.authors] ?? [];
  List<Author> get pastAuthors =>
      _authors?[AuthorsConfigKeys.pastAuthors] ?? [];

  AboutViewModel(
    this.authorsConfigService,
    this.authorsProvider,
    this.lastCommitShaService,
    this.lastCommitShaProvider,
  );

  Future<void> init() async {
    if (isInitialized) {
      return;
    }
    _authors = await authorsProvider.getData() ??
        await authorsConfigService.getAuthors();

    updateLastCommitShaAndConfigIfChanged(
      lastCommitShaProvider: lastCommitShaProvider,
      lastCommitShaService: lastCommitShaService,
      gitPath: GitPath.authors,
      saveConfig: _saveAuthorsConfigFromGit,
    );

    isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveAuthorsConfigFromGit() async {
    final authors = await authorsConfigService.getAuthors();

    if (authors == null) {
      return;
    }

    authorsProvider.saveData(authors);
  }
}
