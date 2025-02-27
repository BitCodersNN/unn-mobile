import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class GettingFileDataImpl implements GettingFileData {
  final AuthorizationService _authorizationService;
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;
  final String _id = 'id';

  GettingFileDataImpl(
    this._authorizationService,
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<FileData?> getFileData({
    required int id,
  }) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.diskAttachedObjectGet,
        queryParameters: {
          SessionIdentifierStrings.sessid: _authorizationService.csrf ?? '',
          _id: id.toString(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    dynamic jsonMap;

    try {
      jsonMap = response.data['result'];
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    FileData? fileData;
    try {
      fileData = FileData.fromJsonLegacy(jsonMap);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    return fileData;
  }
}
