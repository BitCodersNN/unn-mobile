import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_api_helper.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class GettingScheduleServiceImpl implements GettingScheduleService {
  final String _start = 'start';
  final String _finish = 'finish';
  final String _lng = 'lng';
  final String _date = 'date';
  final String _dateFormat = 'y.MM.dd H:m';
  final String _splitPaternForStream = '|';

  final LoggerService _loggerService;
  final BaseApiHelper _baseApiHelper;

  GettingScheduleServiceImpl(
    this._loggerService,
    this._baseApiHelper,
  );

  @override
  Future<List<Subject>?> getSchedule(ScheduleFilter scheduleFilter) async {
    final path =
        '${ApiPaths.schedule}${scheduleFilter.idType.name}/${scheduleFilter.id}';

    Response response;
    try {
      response = await _baseApiHelper.get(
        path: path,
        queryParameters: {
          _start: scheduleFilter.dateTimeRange.start
              .toIso8601String()
              .split('T')[0]
              .replaceAll('-', '.'),
          _finish: scheduleFilter.dateTimeRange.end
              .toIso8601String()
              .split('T')[0]
              .replaceAll('-', '.'),
          _lng: '1',
        },
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }
    final List<dynamic> jsonList = response.data;

    final List<Subject> schedule = [];

    for (final jsonMap in jsonList) {
      schedule.add(_convertFromJson(jsonMap));
    }

    return schedule;
  }

  Subject _convertFromJson(Map<String, Object?> jsonMap) {
    final DateTime startDateTime = DateFormat(_dateFormat).parse(
      '${jsonMap[_date] as String} ${jsonMap[KeysForSubjectJsonConverter.beginLesson] as String}',
    );
    final DateTime endDateTime = DateFormat(_dateFormat).parse(
      '${jsonMap[_date] as String} ${jsonMap[KeysForSubjectJsonConverter.endLesson] as String}',
    );

    return Subject(
      jsonMap[KeysForSubjectJsonConverter.discipline] as String,
      (jsonMap[KeysForSubjectJsonConverter.kindOfWork] ?? '') as String,
      Address(
        jsonMap[KeysForSubjectJsonConverter.auditorium] as String,
        jsonMap[KeysForSubjectJsonConverter.building] as String,
      ),
      ((jsonMap[KeysForSubjectJsonConverter.stream] ?? '') as String)
          .split(_splitPaternForStream),
      (jsonMap[KeysForSubjectJsonConverter.lecturer] ?? '') as String,
      DateTimeRange(start: startDateTime, end: endDateTime),
    );
  }
}
