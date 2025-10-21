// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/git/git_config_loader.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_config_service.dart';

class LoadingPageConfigServiceImpl implements LoadingPageConfigService {
  final GitConfigLoader gitConfigLoader;

  LoadingPageConfigServiceImpl(
    loggerService,
    apiHelper,
  ) : gitConfigLoader = GitConfigLoader(
          loggerService,
          apiHelper,
          path: '${ApiPath.loadingScreen}/loading_page_config.json',
        );

  @override
  Future<List<LoadingPageModel>?> getLoadingPages() async {
    final jsonMap = await gitConfigLoader.getConfig();

    if (jsonMap == null) {
      return null;
    }

    final loadingPages = [
      for (final list in jsonMap.values) ...list,
    ];

    return parseJsonIterable<LoadingPageModel>(
      loadingPages,
      LoadingPageModel.fromJson,
      gitConfigLoader.loggerService,
    );
  }
}
