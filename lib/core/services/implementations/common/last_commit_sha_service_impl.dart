// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/camel_case_converter.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/services/interfaces/common/last_commit_sha_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class LastCommitShaServiceImpl implements LastCommitShaService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  LastCommitShaServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<String?> getSha({
    required GitPath gitPath,
  }) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: _path(gitPath.name.toSnakeCase()),
        options: OptionsWithExpectedTypeFactory.jsonMap,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    try {
      return (response.data as JsonMap)['sha'];
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }
  }

  String _path(String filePath) =>
      'repos/${ApiPath.gitRepository}/commits/develop?path={file_path}&paths=$filePath&per_page=1';
}
