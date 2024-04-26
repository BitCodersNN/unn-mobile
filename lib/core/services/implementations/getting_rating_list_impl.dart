import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';

class GettingRatingListImpl implements GettingRatingList {
  final _authorisationService =
      Injector.appInstance.get<AuthorisationService>();
  final String _path = 'bitrix/services/main/ajax.php';
  final String _actionKey = 'action';
  final String _action = 'main.rating.list';
  final String _sessionIdCookieKey = 'PHPSESSID';
  final String _csrfKey = 'X-Bitrix-Csrf-Token';
  final String _ratingVoteTypeId = 'params[RATING_VOTE_TYPE_ID]';
  final String _ratingVoteKeySigned = 'params[RATING_VOTE_KEY_SIGNED]';
  final String _ratingVoteEntityId = 'params[RATING_VOTE_ENTITY_ID]';
  final String _ratingVoteListPage = 'params[RATING_VOTE_LIST_PAGE]';
  final String _ratingVoteReaction = 'params[RATING_VOTE_REACTION]';
  final String _pathToUserProfile = 'params[PATH_TO_USER_PROFILE]';
  final String _valueOfpathToUserProfile = '/company/personal/user/#user_id#/';
  final String _data = 'data';
  final String _reactions = 'reactions';

  @override
  Future<RatingList?> getReactionListByReaction({
    required String voteKeySigned,
    required ReactionType reactionType,
    int pageNumber = 0,
  }) async {
    final requestSender = HttpRequestSender(
      path: _path,
      queryParams: {
        _actionKey: _action,
      },
      headers: {
        _csrfKey: _authorisationService.csrf ?? '',
      },
      cookies: {
        _sessionIdCookieKey: _authorisationService.sessionId ?? '',
      },
    );

    final Map<String, dynamic> body = {
      _ratingVoteTypeId: voteKeySigned.split('-')[0],
      _ratingVoteKeySigned: voteKeySigned,
      _ratingVoteEntityId: voteKeySigned.split('-')[1].split('.')[0],
      _ratingVoteListPage: pageNumber.toString(),
      _ratingVoteReaction: reactionType.name,
      _pathToUserProfile: _valueOfpathToUserProfile,
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
      )[_data];
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    final json = {
      reactionType.toString():
          jsonMap['items'].whereType<Map<String, Object?>>().toList(),
    };

    RatingList? ratingList;
    try {
      ratingList = RatingList.fromJson(json);
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }

    return ratingList;
  }

  @override
  Future<Map<ReactionType, int>?> getNumbersOfReactions({
    required String voteKeySigned,
  }) async {
    final requestSender = HttpRequestSender(
      path: _path,
      queryParams: {
        _actionKey: _action,
      },
      headers: {
        _csrfKey: _authorisationService.csrf ?? '',
      },
      cookies: {
        _sessionIdCookieKey: _authorisationService.sessionId ?? '',
      },
    );

    final Map<String, dynamic> body = {
      _ratingVoteTypeId: voteKeySigned.split('-')[0],
      _ratingVoteKeySigned: voteKeySigned,
      _ratingVoteEntityId: voteKeySigned.split('-')[1].split('.')[0],
      _pathToUserProfile: _valueOfpathToUserProfile,
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

    dynamic responseJson;
    try {
      responseJson =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    final jsonMap = responseJson[_data][_reactions];

    if (jsonMap is List) {
      return null;
    }

    final numbersOfReactions = jsonMap.map<ReactionType, int>((key, value) {
      return MapEntry(
        ReactionType.values.firstWhere(
          (e) => e.toString().split('.').last == key,
        ),
        value as int,
      );
    });

    return numbersOfReactions;
  }

  @override
  Future<RatingList?> getRatingList({
    required String voteKeySigned,
  }) async {
    const int reactionCountPerPage = 20;

    if (voteKeySigned == '') {
      return null;
    }

    final numbersOfReactions =
        await getNumbersOfReactions(voteKeySigned: voteKeySigned);

    if (numbersOfReactions == null) {
      return null;
    }

    final futures = <Future>[];

    numbersOfReactions.forEach((key, value) {
      for (var pageNumber = 1;
          pageNumber <= value ~/ reactionCountPerPage + 1;
          pageNumber++) {
        futures.add(
          getReactionListByReaction(
            voteKeySigned: voteKeySigned,
            reactionType: key,
            pageNumber: pageNumber,
          ),
        );
      }
    });

    final ratingLists = await Future.wait(futures);

    final combinedList = RatingList();
    for (final ratingList in ratingLists) {
      ratingList.ratingList.forEach(
        (key, value) => combinedList.addReactions(key, value),
      );
    }

    return combinedList;
  }
}
