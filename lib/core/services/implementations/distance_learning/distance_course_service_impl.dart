import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/custom_errors/response_type_exception.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_for_distance_course_factory.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
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
        options: OptionsForDistanceCourseFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (exception, stackTrace) {
      if (exception is DioException &&
          exception.error is ResponseTypeException) {
        final responseTypeException = exception.error as ResponseTypeException;
        if (responseTypeException.actualType == List<dynamic>) {
          return [];
        }
      }
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    return parseJsonIterable<DistanceCourse>(
      response.data.values,
      _processCourse,
      _loggerService,
    );
  }

  DistanceCourse _processCourse(Map<String, dynamic> course) {
    final firstMaterialData = (course.values.first as List).first;

    course[SemesterJsonKeys.semester] =
        firstMaterialData[SemesterJsonKeys.semester];
    course[SemesterJsonKeys.year] = firstMaterialData[SemesterJsonKeys.year];
    course[DistanceCourseJsonKeys.discipline] =
        firstMaterialData[DistanceCourseJsonKeys.discipline];
    course[DistanceCourseJsonKeys.login] =
        firstMaterialData[DistanceCourseJsonKeys.login];
    course[DistanceCourseJsonKeys.groups] =
        firstMaterialData[DistanceCourseJsonKeys.groups];

    return DistanceCourse.fromJson(course);
  }
}
