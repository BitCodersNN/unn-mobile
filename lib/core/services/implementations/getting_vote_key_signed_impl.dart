import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';

class GettingVoteKeySignedImpl implements GettingVoteKeySigned {
  final String _blog = 'blog';

  @override
  Future<String?> getVoteKeySigned({
    required int authorId,
    required int postId,
  }) async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();
    final path = '${ApiPaths.companyPersonalUser}/$authorId/$_blog/$postId/';

    final requestSender = HttpRequestSender(
      path: path,
      headers: {
        SessionIdentifierStrings.csrfToken: authorisationService.csrf ?? '',
      },
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            authorisationService.sessionId ?? '',
      },
    );

    final HttpClientResponse response;

    try {
      response = await requestSender.get(timeoutSeconds: 60);
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

    String responseStr;
    try {
      responseStr = await HttpRequestSender.responseToStringBody(response);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    String? keySignedMatches;
    try {
      keySignedMatches = (RegularExpressions.keySignedRegExp
          .firstMatch(responseStr)
          ?.group(0) as String);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    return keySignedMatches.split(' \'')[1].split('\'')[0];
  }
}
