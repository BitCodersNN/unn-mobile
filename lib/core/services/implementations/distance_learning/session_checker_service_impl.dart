import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/session_checker_service.dart';

class SessionCheckerServiceImpl implements SessionCheckerService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  SessionCheckerServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<bool?> isSessionAlive() async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.session,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    return bool.tryParse(response.data.substring(6));
  }
}
