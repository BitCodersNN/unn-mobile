import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/rating_list_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_service.dart';

class _KeysForReactionManagerJsonConverter {
  static const String data = 'data';
  static const String userData = 'user_data';
  static const String nameFromatted = 'NAME_FORMATTED';
  static const String photo = 'PERSONAL_PHOTO';
  static const String src = 'SRC';
}

class ReactionServiceImpl implements ReactionService {
  final LoggerService _loggerService;
  final CurrentUserSyncStorage _currentUserSync;
  final ApiHelper _apiHelper;

  ReactionServiceImpl(
    this._currentUserSync,
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<UserShortInfo?> addReaction(
    ReactionType reactionType,
    String voteKeySigned,
  ) async =>
      await _manageReaction(
        reactionType,
        voteKeySigned,
        RatingListStrings.plus,
      );

  @override
  Future<bool> removeReaction(
    String voteKeySigned,
  ) async =>
      await _manageReaction(
        ReactionType.like,
        voteKeySigned,
        RatingListStrings.cancel,
      ) !=
      null;

  Future<UserShortInfo?> _manageReaction(
    ReactionType reactionType,
    String voteKeySigned,
    String action,
  ) async {
    final Map<String, dynamic> body = {
      RatingListStrings.voteTypeId: voteKeySigned.split('-')[0],
      RatingListStrings.voteKeySigned: voteKeySigned,
      RatingListStrings.voteEntityId: voteKeySigned.split('-')[1].split('.')[0],
      RatingListStrings.ratingVoteAction: action,
      RatingListStrings.voteReaction: reactionType.name,
    };

    final Response response;

    try {
      response = await _apiHelper.post(
        path: ApiPaths.ajax,
        queryParameters: {
          AnalyticsLabel.b24statAction: AnalyticsLabel.addLike,
          AjaxActionStrings.actionKey: AjaxActionStrings.ratingVote,
        },
        data: body,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap = response.data[_KeysForReactionManagerJsonConverter.data]
          [_KeysForReactionManagerJsonConverter.userData];
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    if (jsonMap == false) {
      return null;
    }

    final userData = _currentUserSync.currentUserData;
    final photoSrc = jsonMap[_KeysForReactionManagerJsonConverter.photo]
        [_KeysForReactionManagerJsonConverter.src];
    return UserShortInfo(
      userData!.bitrixId,
      jsonMap[_KeysForReactionManagerJsonConverter.nameFromatted],
      photoSrc != false ? photoSrc : null,
    );
  }
}
