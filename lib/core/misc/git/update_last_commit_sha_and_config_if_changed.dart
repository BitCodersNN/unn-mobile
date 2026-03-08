// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/providers/interfaces/common/last_commit_sha_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/last_commit_sha_service.dart';

Future<void> updateLastCommitShaAndConfigIfChanged({
  required LastCommitShaProvider lastCommitShaProvider,
  required LastCommitShaService lastCommitShaService,
  required GitPath gitPath,
  required Future<void> Function() saveConfig,
}) async {
  final [shaFromService, shaFromProvider] = await Future.wait([
    lastCommitShaService.getSha(gitPath: gitPath),
    lastCommitShaProvider.getData(),
  ]);

  if (shaFromProvider == null || shaFromService != shaFromProvider) {
    unawaited(
      Future.wait([
        saveConfig(),
        lastCommitShaProvider.saveData(shaFromService),
      ]),
    );
  }
}
