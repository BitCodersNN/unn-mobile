import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _QueryParameterKeys {
  static const String _start = 'start';
  static const String _finish = 'finish';
  static const String _lng = 'lng';
}

class GettingScheduleServiceImpl implements GettingScheduleService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  GettingScheduleServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<List<Subject>?> getSchedule(ScheduleFilter scheduleFilter) async {
    final path =
        '${ApiPath.schedule}${scheduleFilter.idType.name}/${scheduleFilter.id}';

    Response response;
    try {
      response = await _apiHelper.get(
        path: path,
        queryParameters: {
          _QueryParameterKeys._start: scheduleFilter.dateTimeRange.start
              .toIso8601String()
              .split('T')[0]
              .replaceAll('-', '.'),
          _QueryParameterKeys._finish: scheduleFilter.dateTimeRange.end
              .toIso8601String()
              .split('T')[0]
              .replaceAll('-', '.'),
          _QueryParameterKeys._lng: '1',
        },
        options: OptionsWithExpectedTypeFactory.list,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }
    final List<dynamic> jsonList = response.data;

    final List<Subject> schedule = [];

    for (final jsonMap in jsonList) {
      schedule.add(Subject.fromJson(jsonMap));
    }

    return schedule;
  }
}
