// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/loading_page/last_commit_sha_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _LastCommitShaKeys {
  static const shaKey = 'sha_key';
}

class LastCommitShaProviderImpl implements LastCommitShaProvider {
  final StorageService _storage;

  LastCommitShaProviderImpl(this._storage);

  @override
  Future<String?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    final sha = await _storage.read(
      key: _LastCommitShaKeys.shaKey,
    );

    return sha;
  }

  @override
  Future<void> saveData(String? sha) async {
    if (sha == null) {
      return;
    }

    await _storage.write(
      key: _LastCommitShaKeys.shaKey,
      value: sha,
    );
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(
      key: _LastCommitShaKeys.shaKey,
    );
  }
}
