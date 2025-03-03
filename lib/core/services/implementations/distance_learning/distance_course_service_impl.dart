import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_course.dart';
import 'package:unn_mobile/core/models/distance_learning/semester.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

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
    required int semester,
    required int year,
  }) async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.materials,
        queryParameters: {
          _QueryParamNames.semester: semester,
          _QueryParamNames.year: year,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
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

    final distanceCourses = <DistanceCourse>[];
    jsonMap.values?.forEach((course) {
      try {
        distanceCourses.add(_processCourse(course));
      } catch (exception, stack) {
        _loggerService.logError(
          exception,
          stack,
          information: [course],
        );
      }
    });

    return distanceCourses;
  }

  DistanceCourse _processCourse(Map<String, dynamic> course) {
    final firstMaterialData = (course.values.first as List).first;

    course[KeysForSemesterJsonConverter.semester] =
        firstMaterialData[KeysForSemesterJsonConverter.semester];
    course[KeysForSemesterJsonConverter.year] =
        firstMaterialData[KeysForSemesterJsonConverter.year];
    course[KeysForDistanceCourseJsonConverter.discipline] =
        firstMaterialData[KeysForDistanceCourseJsonConverter.discipline];
    course[KeysForDistanceCourseJsonConverter.login] =
        firstMaterialData[KeysForDistanceCourseJsonConverter.login];
    course[KeysForDistanceCourseJsonConverter.groups] =
        firstMaterialData[KeysForDistanceCourseJsonConverter.groups];

    return DistanceCourse.fromJson(course);
  }
}
