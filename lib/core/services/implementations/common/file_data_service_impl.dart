import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/file_data_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class FileDataServiceImpl implements FileDataService {
  final UnnAuthorisationService _authorizationService;
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;
  final String _id = 'id';

  FileDataServiceImpl(
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
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          60,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
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
      fileData = FileData.fromBitrixJson(jsonMap);
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }

    return fileData;
  }
}
