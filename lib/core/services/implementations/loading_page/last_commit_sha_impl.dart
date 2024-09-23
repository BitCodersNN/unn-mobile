import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/last_commit_sha.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class LastCommitShaImpl implements LastCommitSha {
  final _path = 'repos/${ApiPaths.gitRepository}/commits/main?per_page=1';
  final LoggerService _loggerService;

  LastCommitShaImpl(this._loggerService);

  @override
  Future<String?> getSha() async {
    final requestSender = HttpRequestSender(
      host: ApiPaths.gitHubApiHost,
      path: _path,
    );

    HttpClientResponse response;
    try {
      response = await requestSender.get();
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log(
        'statusCode = $statusCode;',
      );
      return null;
    }

    Map<String, dynamic> jsonMap;

    try {
      jsonMap =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    return jsonMap['sha'];
  }
}
