import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/rating_list_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';

class _KeysForReactionManagerJsonConverter {
  static const String data = 'data';
  static const String userData = 'user_data';
  static const String nameFromatted = 'NAME_FORMATTED';
  static const String photo = 'PERSONAL_PHOTO';
  static const String src = 'SRC';
}

class ReactionManagerImpl implements ReactionManager {
  final LoggerService _loggerService;
  final AuthorizationService _authorizationService;
  final CurrentUserSyncStorage _currentUserSync;

  ReactionManagerImpl(
    this._authorizationService,
    this._currentUserSync,
    this._loggerService,
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
    final requestSender = HttpRequestSender(
      path: ApiPaths.ajax,
      queryParams: {
        RatingListStrings.analyticsLabel: AjaxActionStrings.addLike,
        AjaxActionStrings.actionKey: AjaxActionStrings.ratingVote,
      },
      headers: {
        SessionIdentifierStrings.csrfToken: _authorizationService.csrf ?? '',
      },
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            _authorizationService.sessionId ?? '',
      },
    );

    final Map<String, dynamic> body = {
      RatingListStrings.voteTypeId: voteKeySigned.split('-')[0],
      RatingListStrings.voteKeySigned: voteKeySigned,
      RatingListStrings.voteEntityId: voteKeySigned.split('-')[1].split('.')[0],
      RatingListStrings.ratingVoteAction: action,
      RatingListStrings.voteReaction: reactionType.name,
    };

    final HttpClientResponse response;

    try {
      response = await requestSender.postForm(
        body,
        timeoutSeconds: 60,
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    if (response.statusCode != 200) {
      _loggerService.log('statusCode = ${response.statusCode}');
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap = jsonDecode(
        await HttpRequestSender.responseToStringBody(response),
      )[_KeysForReactionManagerJsonConverter.data]
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
