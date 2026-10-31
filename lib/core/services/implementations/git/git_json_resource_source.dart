// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/services/interfaces/git/git_config_service.dart';
import 'package:unn_mobile/core/services/interfaces/git/git_resource_source.dart';

class GitJsonResourceSource<T> implements GitResourceSource<T> {
  final GitConfigService _configService;
  final T Function(Object? json) _fromJson;
  @override
  final GitPath path;

  GitJsonResourceSource(
    this._configService,
    this._fromJson, {
    required this.path,
  });

  @override
  Future<T?> load({required String revision}) async {
    final json = await _configService.getConfig(
      path: '${path.directory}/${path.configFile}',
      revision: revision,
    );
    if (json == null) {
      return null;
    }
    return _fromJson(json);
  }
}
