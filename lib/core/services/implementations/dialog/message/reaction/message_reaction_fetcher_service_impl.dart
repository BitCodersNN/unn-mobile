import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/object_by_id_map.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/reaction/message_reaction_fetcher_service.dart';

class _DataKeys {
  static const String sessid = 'sessid';
  static const String messageId = 'messageId';
}

class _JsonKeys {
  static const String result = 'result';
  static const String users = 'users';
  static const String reactions = 'reactions';
  static const String reaction = 'reaction';
  static const String userId = 'userId';
  static const String name = 'name';
  static const String avatar = 'avatar';
}

class MessageReactionFetcherServiceImpl
    implements MessageReactionFetcherService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageReactionFetcherServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<RatingList?> fetch(int messageId) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.messageReactions,
        data: {
          _DataKeys.sessid: (_apiHelper as AuthenticatedApiHelper).sessionId,
          _DataKeys.messageId: messageId,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    final result = response.data[_JsonKeys.result];
    final usersById = buildObjectByIdMap(result[_JsonKeys.users]);
    const defaultUserInfoKeys = DefaultUserInfoKeys();

    final users = parseJsonIterable<Map<String, dynamic>>(
      result[_JsonKeys.reactions],
      (reaction) {
        final userId = reaction[_JsonKeys.userId];
        return {
          _JsonKeys.reaction:
              (reaction[_JsonKeys.reaction] as String).toLowerCase(),
          defaultUserInfoKeys.id: userId,
          defaultUserInfoKeys.fullname: usersById[userId]![_JsonKeys.name],
          defaultUserInfoKeys.photoSrc: usersById[userId]![_JsonKeys.avatar],
        };
      },
      _loggerService,
    );

    return RatingList.fromJson(
      {
        _JsonKeys.users: users,
      },
    );
  }
}
