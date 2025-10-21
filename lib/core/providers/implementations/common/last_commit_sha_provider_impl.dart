// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/camel_case_converter.dart';
import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/providers/interfaces/common/last_commit_sha_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class LastCommitShaProviderImpl implements LastCommitShaProvider {
  final StorageService _storage;
  final GitPath gitPath;

  LastCommitShaProviderImpl(
    this._storage, {
    required this.gitPath,
  });

  @override
  Future<String?> getData() async {
    if (!(await isContained())) {
      return null;
    }

    return _storage.read(
      key: _key,
    );
  }

  @override
  Future<void> saveData(String? sha) async {
    if (sha == null) {
      return;
    }

    await _storage.write(
      key: _key,
      value: sha,
    );
  }

  @override
  Future<bool> isContained() => _storage.containsKey(
        key: _key,
      );

  String get _key => '${gitPath.name.toSnakeCase()}_sha_key';

  @override
  Future<void> removeData() => _storage.remove(key: _key);
}
