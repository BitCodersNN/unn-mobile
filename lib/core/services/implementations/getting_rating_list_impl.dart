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
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';

class GettingRatingListImpl implements GettingRatingList {
  final _authorisationService =
      Injector.appInstance.get<AuthorisationService>();
  final String _data = 'data';
  final String _reactions = 'reactions';

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
      path: ApiPaths.ajax,
      queryParams: {
        AjaxActionStrings.actionKey: AjaxActionStrings.ratingList,
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
