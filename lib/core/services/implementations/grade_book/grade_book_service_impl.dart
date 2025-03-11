import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/services/interfaces/grade_book/grade_book_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _JsonKeys {
  static const String semesters = 'semesters';
  static const String semester = 'semester';
  static const String data = 'data';
}

class GradeBookServiceImpl implements GradeBookService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  GradeBookServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<Map<int, List<MarkBySubject>>?> getGradeBook() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.marks,
        options: OptionsWithExpectedTypeFactory.list,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    final Map<int, List<MarkBySubject>> marks = {};
    for (final course in response.data) {
      for (final semesterInfo in course[_JsonKeys.semesters] ?? []) {
        final semester = semesterInfo[_JsonKeys.semester]?.toInt();
        final data = semesterInfo[_JsonKeys.data] ?? [];
        if (semester != null) {
          marks[semester] = parseJsonIterable<MarkBySubject>(
            data,
            MarkBySubject.fromJson,
            _loggerService,
          );
        }
      }
    }
    return marks;
  }
}
