import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/json_list_parser.dart';
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
  Future<List?> getWebinars({
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
        options: Options(
          responseType: ResponseType.plain,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    final jsonMap = jsonDecode(response.data.substring(6));

    if (jsonMap is! List) {
      return null;
    }

    return parseJsonList<Webinar>(
      jsonMap,
      Webinar.fromJson,
      _loggerService,
    );
  }
}
