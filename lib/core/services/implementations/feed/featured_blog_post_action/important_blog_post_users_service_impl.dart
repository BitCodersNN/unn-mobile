import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/blog_post_response_validator.dart';
import 'package:unn_mobile/core/models/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_users_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _DataKeys {
  static const String postId = 'params[POST_ID]';
  static const String name = 'params[NAME]';
  static const String value = 'params[VALUE]';
  static const String pageNumber = 'params[PAGE_NUMBER]';
  static const String pathToUser = 'params[PATH_TO_USER]';
  static const String nameTemplate = 'params[NAME_TEMPLATE]';
}

class _DataValue {
  static const String name = 'BLOG_POST_IMPRTNT';
  static const String value = 'Y';
  static const String pathToUser = '/company/personal/user/#user_id#/';
  static const String nameTemplate = '#LAST_NAME# #NAME# #SECOND_NAME#';
}

class _JsonKeys {
  static const String recordCount = 'RecordCount';
  static const String data = 'data';
  static const String items = 'items';
}

class ImportantBlogPostUsersServiceImpl
    implements ImportantBlogPostUsersService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  ImportantBlogPostUsersServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<int?> getTotalUserCount(int postId) async {
    final responseData = await _getResponseData(postId);
    if (responseData == null) {
      return null;
    }
    return responseData[_JsonKeys.recordCount];
  }

  @override
  Future<List<UserShortInfo>?> getUsers(
    int postId, [
    int pageNumber = 0,
  ]) async {
    final responseData = await _getResponseData(postId, pageNumber);
    if (responseData == null) {
      return null;
    }

    final usersJson = responseData[_JsonKeys.items];

    return usersJson.values
        .map<UserShortInfo>(
          (value) => UserShortInfo.fromJsonImportantBlogPost(value),
        )
        .toList();
  }

  Future<Map?> _getResponseData(
    int postId, [
    int pageNumber = 0,
  ]) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPaths.ajax,
        queryParameters: {
          AjaxActionStrings.actionKey: AjaxActionStrings.importantBlogPostUsers,
        },
        data: {
          _DataKeys.postId: postId,
          _DataKeys.pageNumber: pageNumber,
          _DataKeys.name: _DataValue.name,
          _DataKeys.value: _DataValue.value,
          _DataKeys.pathToUser: _DataValue.pathToUser,
          _DataKeys.nameTemplate: _DataValue.nameTemplate,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    if (!FeedResponseValidator.validate(response.data, _loggerService)) {
      return null;
    }

    return response.data[_JsonKeys.data];
  }
}
