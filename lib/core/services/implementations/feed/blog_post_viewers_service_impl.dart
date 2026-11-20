// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/models/feed/blog_post_viewer.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_viewers_service.dart';

class _DataKeys {
  static const String contentId = 'params[contentId]';
  static const String page = 'params[page]';
}

class _DataValues {
  static const String contentIdPrefix = 'BLOG_POST-';
}

class _JsonKeys {
  static const String data = 'data';
  static const String items = 'items';
}

class _ErrorMessages {
  static const String invalidItems = 'Invalid post viewers collection';
}

class BlogPostViewersServiceImpl implements BlogPostViewersService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  BlogPostViewersServiceImpl(this._loggerService, this._apiHelper);

  @override
  Future<List<BlogPostViewer>?> getViewers({
    required int postId,
    int pageNumber = 1,
  }) async {
    final Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.getContentViewList,
        },
        data: {
          _DataKeys.contentId: '${_DataValues.contentIdPrefix}$postId',
          _DataKeys.page: pageNumber,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          15,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    try {
      return _parseResponse(response.data);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }
  }

  List<BlogPostViewer>? _parseResponse(Object? responseData) {
    final json = responseData! as JsonMap;
    if (!ResponseStatusValidator.validate(json, _loggerService)) {
      return null;
    }
    final data = json[_JsonKeys.data]! as JsonMap;
    final items = switch (data[_JsonKeys.items]) {
      final JsonMap items => items.values,
      final List<Object?> items => items,
      _ => throw const FormatException(_ErrorMessages.invalidItems),
    };
    return parseJsonIterable<BlogPostViewer>(
      items,
      BlogPostViewer.fromJson,
      _loggerService,
    );
  }
}
