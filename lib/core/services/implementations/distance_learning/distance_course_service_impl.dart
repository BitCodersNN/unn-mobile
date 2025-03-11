import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_course.dart';
import 'package:unn_mobile/core/models/distance_learning/semester.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _QueryParamNames {
  static const String semester = 'semester';
  static const String year = 'year';
}

class DistanceCourseServiceImpl implements DistanceCourseService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  DistanceCourseServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<DistanceCourse>?> getDistanceCourses({
    required Semester semester,
  }) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.materials,
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

    if (jsonMap is List) {
      return null;
    }

    return parseJsonIterable<DistanceCourse>(
      jsonMap.values,
      _processCourse,
      _loggerService,
    );
  }

  DistanceCourse _processCourse(Map<String, dynamic> course) {
    final firstMaterialData = (course.values.first as List).first;

    course[SemesterJsonKeys.semester] =
        firstMaterialData[SemesterJsonKeys.semester];
    course[SemesterJsonKeys.year] =
        firstMaterialData[SemesterJsonKeys.year];
    course[DistanceCourseJsonKeys.discipline] =
        firstMaterialData[DistanceCourseJsonKeys.discipline];
    course[DistanceCourseJsonKeys.login] =
        firstMaterialData[DistanceCourseJsonKeys.login];
    course[DistanceCourseJsonKeys.groups] =
        firstMaterialData[DistanceCourseJsonKeys.groups];

    return DistanceCourse.fromJson(course);
  }
}
