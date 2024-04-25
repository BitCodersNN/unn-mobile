import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';

class _RegularExpSource {
  static const keySigned = r"keySigned: '.*',";
}

class GettingVoteKeySignedImpl implements GettingVoteKeySigned {
  final String _path = 'company/personal/';
  final String _user = 'user';
  final String _blog = 'blog';
  final String _sessionIdCookieKey = 'PHPSESSID';
  final String _csrfKey = 'X-Bitrix-Csrf-Token';

  @override
  Future<String?> getVoteKeySigned({
    required int authorId,
    required int postId,
  }) async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();
    final path = '$_path$_user/$authorId/$_blog/$postId/';

    final requestSender = HttpRequestSender(
      path: path,
      headers: {
        _csrfKey: authorisationService.csrf ?? '',
      },
      cookies: {
        _sessionIdCookieKey: authorisationService.sessionId ?? '',
      },
    );

    final HttpClientResponse response;

    try {
      response = await requestSender.get(timeoutSeconds: 60);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance
          .log("Exception: $error\nStackTrace: $stackTrace");
      return null;
    }

    if (response.statusCode != 200) {
      await FirebaseCrashlytics.instance.log(
          '${runtimeType.toString()}: statusCode = ${response.statusCode}');
      return null;
    }

    String responseStr;
    try {
      responseStr = await HttpRequestSender.responseToStringBody(response);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    final keySigned = RegExp(
      _RegularExpSource.keySigned,
    );

    String? keySignedMatches;
    try {
      keySignedMatches =
          (keySigned.firstMatch(responseStr)?.group(0) as String);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return null;
    }

    return keySignedMatches.split(' \'')[1].split('\'')[0];
  }
}
