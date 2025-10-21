// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class GitConfigLoader {
  final LoggerService loggerService;
  final ApiHelper apiHelper;
  final String path;

  GitConfigLoader(
    this.loggerService,
    this.apiHelper, {
    required this.path,
  });

  Future<Map<String, dynamic>?> getConfig() async {
    Response response;
    try {
      response = await apiHelper.get(
        path: '${ApiPath.gitRepository}/$path',
        options: OptionsWithExpectedTypeFactory.string,
      );
    } catch (error, stackTrace) {
      loggerService.logError(error, stackTrace);
      return null;
    }

    Map<String, dynamic> jsonMap;

    try {
      jsonMap = jsonDecode(response.data);
    } catch (error, stackTrace) {
      loggerService.logError(error, stackTrace);
      return null;
    }

    return jsonMap;
  }
}
