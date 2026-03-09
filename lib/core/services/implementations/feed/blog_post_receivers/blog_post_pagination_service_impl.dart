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
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_pagination_service.dart';

class _DataVelues {
  static const String y = 'Y';
  static const String bitrix24 = 'bitrix24';
}

class BlogPostPaginationServiceImpl implements BlogPostPaginationService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;
  final CurrentUserSyncStorage _currentUserSync;

  BlogPostPaginationServiceImpl(
    this._loggerService,
    this._apiHelper,
    this._currentUserSync,
  );

  @override
  Future<Map<BlogPostType, List<BlogPost>>?> loadNextPageBlogPosts({
    required int pageNumber,
    required Set<int> pinIds,
    required String signedParameters,
    required String commentFormUID,
    required String blogCommentFormUID,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.getNextPage,
          AjaxActionStrings.c: AjaxActionStrings.logBlogPosts,
        },
        data: {
          DataKeys.logajax: _DataVelues.y,
          DataKeys.noblog: DataVelues.n,
          DataKeys.pageNumber: pageNumber,
          DataKeys.lastLogTimestamp:
              DateTime.now().millisecondsSinceEpoch ~/ 1000,
          DataKeys.prevPageLogId: pinIds.join('|'),
          DataKeys.siteTemplateId: _DataVelues.bitrix24,
          DataKeys.useBXMainFilter: _DataVelues.y,
          DataKeys.presentFilterTopId: '',
          DataKeys.presentFilterId: '',
          DataKeys.commentFormUID: commentFormUID,
          DataKeys.blogCommentFormUID: blogCommentFormUID,
          DataKeys.context: '',
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
