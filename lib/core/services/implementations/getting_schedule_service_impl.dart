part of 'library.dart';

class GettingScheduleServiceImpl implements GettingScheduleService {
  final LoggerService _loggerService;
  final String _start = 'start';
  final String _finish = 'finish';
  final String _lng = 'lng';
  final String _date = 'date';
  final String _dateFormat = 'y.MM.dd H:m';
  final String _splitPaternForStream = '|';

  GettingScheduleServiceImpl(this._loggerService);

  @override
  Future<List<Subject>?> getSchedule(ScheduleFilter scheduleFilter) async {
    final path =
        '${ApiPaths.schedule}${scheduleFilter.idType.name}/${scheduleFilter.id}';
    final requestSender = HttpRequestSender(
      path: path,
      queryParams: {
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

    HttpClientResponse response;
    try {
      response = await requestSender.get();
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      _loggerService.log(
        'statusCode = $statusCode; scheduleId = ${scheduleFilter.id}',
      );
      return null;
    }

    List<dynamic> jsonList;

    try {
      jsonList =
          jsonDecode(await HttpRequestSender.responseToStringBody(response));
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

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
