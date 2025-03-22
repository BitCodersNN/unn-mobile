import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_for_distance_course_factory.dart';
import 'package:unn_mobile/core/misc/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/distance_learning/semester.dart';
import 'package:unn_mobile/core/models/distance_learning/webinar.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/webinar_service.dart';

class _QueryParamNames {
  static const String semester = 'semester';
  static const String year = 'year';
}

class WebinarServiceImpl implements WebinarService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  WebinarServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<Webinar>?> getWebinars({
    required Semester semester,
  }) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.webinars,
        queryParameters: {
          _QueryParamNames.semester: semester.semester,
          _QueryParamNames.year: semester.year,
        },
        options: OptionsForDistanceCourseFactory.options(
          10,
          ResponseDataType.list,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    return parseJsonIterable<Webinar>(
      response.data,
      Webinar.fromJson,
      _loggerService,
    );
  }
}
