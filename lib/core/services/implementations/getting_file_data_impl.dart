import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class GettingFileDataImpl implements GettingFileData {
  final AuthorizationService _authorizationService;
  final LoggerService _loggerService;
  final String _id = 'id';

  GettingFileDataImpl(
    this._authorizationService,
    this._loggerService,
  );

  @override
  Future<FileData?> getFileData({
    required int id,
  }) async {
    final requestSender = HttpRequestSender(
      path: ApiPaths.diskAttachedObjectGet,
      queryParams: {
        SessionIdentifierStrings.sessid: _authorizationService.csrf ?? '',
        _id: id.toString(),
      },
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            _authorizationService.sessionId ?? '',
      },
    );

    HttpClientResponse response;
    try {
      response = await requestSender.get(timeoutSeconds: 60);
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log('statusCode = $statusCode; fileId = $id');
      return null;
    }

    dynamic jsonMap;
    try {
      jsonMap = jsonDecode(
        await HttpRequestSender.responseToStringBody(response),
      )['result'];
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    FileData? fileData;
    try {
      fileData = FileData.fromJson(jsonMap);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    return fileData;
  }
}
