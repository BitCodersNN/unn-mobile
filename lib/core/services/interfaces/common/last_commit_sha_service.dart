// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/git/git_folder.dart';

abstract interface class LastCommitShaService {
  /// Получает SHA-хеш последнего коммита каталога [gitPath] в ветке `develop`.
  Future<String?> getSha({
    required GitPath gitPath,
  });
}
