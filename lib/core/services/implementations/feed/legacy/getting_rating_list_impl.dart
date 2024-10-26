import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/rating_list_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _JsonKeys {
  static const data = 'data';
  static const reactions = 'reactions';
}

class GettingRatingListImpl implements GettingRatingList {
  final AuthorizationService _authorizationService;
  final LoggerService _loggerService;

  GettingRatingListImpl(
    this._authorizationService,
    this._loggerService,
  );

  @override
  Future<RatingList?> getReactionListByReaction({
    required String voteKeySigned,
    required ReactionType reactionType,
    int pageNumber = 0,
  }) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.ajax,
      queryParams: {
        AjaxActionStrings.actionKey: AjaxActionStrings.ratingList,
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
      RatingListStrings.voteListPage: pageNumber.toString(),
      RatingListStrings.voteReaction: reactionType.name,
      RatingListStrings.pathToUserProfile:
          RatingListStrings.valueOfpathToUserProfile,
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
      )[_JsonKeys.data];
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
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
      _loggerService.logError(e, stackTrace);
    }

    return ratingList;
  }

  @override
  Future<Map<ReactionType, int>?> getNumbersOfReactions({
    required String voteKeySigned,
  }) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.ajax,
      queryParams: {
        AjaxActionStrings.actionKey: AjaxActionStrings.ratingList,
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
      RatingListStrings.pathToUserProfile:
          RatingListStrings.valueOfpathToUserProfile,
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

    dynamic responseJson;
    try {
      responseJson =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final jsonMap = responseJson[_JsonKeys.data][_JsonKeys.reactions];

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

    final futures = <Future<RatingList?>>[];

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
      ratingList?.ratingList.forEach(
        (key, value) => combinedList.addReactions(key, value),
      );
    }

    return combinedList;
  }
}
