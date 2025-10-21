// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/providers/implementations/common/last_commit_sha_provider_impl.dart';
import 'package:unn_mobile/core/providers/interfaces/about/last_commit_sha_authors_provider.dart';

class LastCommitShaAuthorsProviderImpl extends LastCommitShaProviderImpl
    implements LastCommitShaAuthorsProvider {
  LastCommitShaAuthorsProviderImpl(super._storage)
      : super(gitPath: GitPath.authors);
}
