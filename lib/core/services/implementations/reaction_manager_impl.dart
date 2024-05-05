import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/rating_list_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';

class _KeysForReactionManagerJsonConverter {
  static const String data = 'data';
  static const String userData = 'user_data';
  static const String nameFromatted = 'NAME_FORMATTED';
  static const String photo = 'PERSONAL_PHOTO';
  static const String src = 'SRC';
}

class ReactionManagerImpl implements ReactionManager {
  final _authorisationService =
      Injector.appInstance.get<AuthorisationService>();
  final _userDataProvider = Injector.appInstance.get<UserDataProvider>();

  @override
  Future<ReactionUserInfo?> addReaction(
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

  Future<ReactionUserInfo?> _manageReaction(
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
        SessionIdentifierStrings.csrfToken: _authorisationService.csrf ?? '',
      },
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            _authorisationService.sessionId ?? '',
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
      await FirebaseCrashlytics.instance
          .log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    if (response.statusCode != 200) {
      await FirebaseCrashlytics.instance.log(
        '${runtimeType.toString()}: statusCode = ${response.statusCode}',
      );
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap = jsonDecode(
        await HttpRequestSender.responseToStringBody(response),
      )[_KeysForReactionManagerJsonConverter.data]
          [_KeysForReactionManagerJsonConverter.userData];
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    if (jsonMap == false) {
      return null;
    }

    final userData = await _userDataProvider.getData();

    return ReactionUserInfo(
      userData!.bitrixId,
      jsonMap[_KeysForReactionManagerJsonConverter.nameFromatted],
      jsonMap[_KeysForReactionManagerJsonConverter.photo]
          [_KeysForReactionManagerJsonConverter.src],
    );
  }
}
