import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/build_object_by_id_map.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_reaction_service.dart';

class MessageReactionServiceImpl implements MessageReactionService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageReactionServiceImpl(
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
          'sessid': (_apiHelper as AuthenticatedApiHelper).sessionId,
          'messageId': messageId,
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

    final usersById = buildObjectByIdMap(response.data['result']['users']);

    final List<Map<String, dynamic>> users = [];
    for (final reaction in response.data['result']['reactions']) {
      users.add(
        {
          'reaction': (reaction['reaction'] as String).toLowerCase(),
          'id': reaction['userId'],
          'fio': usersById[reaction['userId']]!['name'],
          'avatar': usersById[reaction['userId']]!['avatar'],
        },
      );
    }

    return RatingList.fromJson(
      {
        'users': users,
      },
    );
  }

  @override
  Future<UserShortInfo?> addReaction(
    ReactionType reactionType,
    String voteKeySigned,
  ) {
    #TODO;
    throw UnimplementedError();
  }

  @override
  Future<bool> removeReaction(
    String voteKeySigned,
  ) {
    #TODO;
    throw UnimplementedError();
  }
}
