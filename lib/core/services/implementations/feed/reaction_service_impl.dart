// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/ajax_action.dart';
import 'package:unn_mobile/core/constants/api/analytics_label.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/rating_list_strings.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_service.dart';

class _KeysForReactionManagerJsonConverter {
  static const String data = 'data';
  static const String userData = 'user_data';
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
  ) =>
      _manageReaction(
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
        path: ApiPath.ajax,
        queryParameters: {
          AnalyticsLabel.b24statAction: AnalyticsLabel.addLike,
          AjaxActionStrings.actionKey: AjaxActionStrings.ratingVote,
        },
        data: body,
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          60,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    dynamic jsonValue;
    try {
      jsonValue =
          ((response.data as JsonMap)[_KeysForReactionManagerJsonConverter.data]
              as JsonMap)[_KeysForReactionManagerJsonConverter.userData];
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    if (jsonValue == false) {
      return null;
    }

    return _currentUserSync.currentUserData! as UserShortInfo;
  }
}
