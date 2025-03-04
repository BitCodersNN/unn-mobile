import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/models/distance_learning/semester.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_semester_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class DistanceCourseSemesterServiceImpl
    implements DistanceCourseSemesterService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  DistanceCourseSemesterServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<Semester>?> getSemesters() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: '',
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.string,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }

    final matches = RegularExpressions.distanceCourseSemesterExp.allMatches(
      response.data,
    );

    try {
      return _parseSemesters(matches);
    } catch (exception, stackTrace) {
      _loggerService.logError(
        exception,
        stackTrace,
        information: [response.data],
      );
      return null;
    }
  }

  List<Semester> _parseSemesters(Iterable<RegExpMatch> matches) {
    return matches.map((match) {
      final year = int.tryParse(match.group(1) ?? '');
      final semester = int.tryParse(match.group(2) ?? '');

      if (year == null || semester == null) {
        throw FormatException('Invalid year or semester in match: $match');
      }

      return Semester(
        year: year,
        semester: semester,
      );
    }).toList();
  }
}
