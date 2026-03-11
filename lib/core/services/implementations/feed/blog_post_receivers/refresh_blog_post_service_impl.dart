// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/feed_data_keys_and_values.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/html_utils/blog_post_html_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/refresh_blog_post_service.dart';

class RefreshBlogPostServiceImpl implements RefreshBlogPostService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;
  final CurrentUserSyncStorage _currentUserSync;

  RefreshBlogPostServiceImpl(
    this._loggerService,
    this._apiHelper,
    this._currentUserSync,
  );

  @override
  Future<Map<BlogPostType, List<BlogPost>>?> refreshBlogPosts({
    required String assetsCheckSum,
    required String signedParameters,
    required String commentFormUID,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.refreshBlogPosts,
          AjaxActionStrings.c: AjaxActionStrings.logBlogPosts,
        },
        data: {
          DataKeys.logajax: DataVelues.y,
          DataKeys.reload: DataVelues.y,
          DataKeys.useBXMainFilter: DataVelues.y,
          DataKeys.siteTemplateId: DataVelues.bitrix24,
          DataKeys.assetsCheckSum: assetsCheckSum,
          DataKeys.context: '',
          DataKeys.commentFormUID: commentFormUID,
          DataKeys.signedParameters: signedParameters,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          30,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }
    final htmlText =
        ((response.data as JsonMap)['data']! as JsonMap)['html'] as String?;

    return BlogPostHtmlParser.parse(
      htmlText,
      _currentUserSync.currentUserData ?? UserShortInfo(),
    );
  }
}
