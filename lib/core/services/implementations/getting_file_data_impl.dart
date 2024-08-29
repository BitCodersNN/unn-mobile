import 'dart:convert';
import 'dart:io';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class GettingFileDataImpl implements GettingFileData {
  final _loggerService = Injector.appInstance.get<LoggerService>();
  final String _id = 'id';

  @override
  Future<FileData?> getFileData({
    required int id,
  }) async {
    final authorisationService =
        Injector.appInstance.get<AuthorisationService>();

    final requestSender = HttpRequestSender(
      path: ApiPaths.diskAttachedObjectGet,
      queryParams: {
        SessionIdentifierStrings.sessid: authorisationService.csrf ?? '',
        _id: id.toString(),
      },
      cookies: {
        SessionIdentifierStrings.sessionIdCookieKey:
            authorisationService.sessionId ?? '',
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
      _loggerService.log(
        '${runtimeType.toString()}: statusCode = $statusCode; fileId = $id',
      );
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
