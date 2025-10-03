// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/string_keys/authors_config_keys.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/git_config_loader.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/about/author.dart';
import 'package:unn_mobile/core/services/interfaces/about/authors_config_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class AuthorsConfigServiceImpl implements AuthorsConfigService {
  final GitConfigLoader gitConfigLoader;

  AuthorsConfigServiceImpl(
    LoggerService loggerService,
    ApiHelper apiHelper,
  ) : gitConfigLoader = GitConfigLoader(
          loggerService,
          apiHelper,
          path: '${ApiPath.authors}/authors_config.json',
        );

  @override
  Future<Map<String, List<Author>>?> getAuthors() async {
    final jsonMap = await gitConfigLoader.getConfig();

    if (jsonMap == null) return null;

    return {
      AuthorsConfigKeys.authors: parseJsonIterable<Author>(
        jsonMap[AuthorsConfigKeys.authors],
        Author.fromJson,
        gitConfigLoader.loggerService,
      ),
      AuthorsConfigKeys.pastAuthors: parseJsonIterable<Author>(
        jsonMap[AuthorsConfigKeys.pastAuthors],
        Author.fromJson,
        gitConfigLoader.loggerService,
      ),
    };
  }
}
