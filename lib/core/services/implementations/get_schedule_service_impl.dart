import 'dart:convert';
import 'dart:developer';
import 'dart:io';


import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';

class GetScheduleServiceImpl implements GetScheduleService {
  final String _start = 'start';
  final String _finish = 'finish';
  final String _lng = '1';
  String _path = 'ruzapi/schedule/';

  int? _statusCode;

  int? get statusCode => _statusCode;

  @override
  Future<List<Subject>?> getSchedule(ScheduleFilter scheduleFilter) async {
    _path = '$_path${scheduleFilter.idType.name}/${scheduleFilter.id}';
    final requstSender = HttpRequestSender(path: _path, queryParams: {
      _start: scheduleFilter.dateTimeRange.start.toIso8601String().split('T')[0].replaceAll('-', '.'),
      _finish: scheduleFilter.dateTimeRange.end.toIso8601String().split('T')[0].replaceAll('-', '.'),
      _lng: '1',
    });

    HttpClientResponse response;
    try {
      response = await requstSender.get();
    } catch (e) {
      log(e.toString());
      return null;
    }

    _statusCode = response.statusCode;

    if (_statusCode != 200) {
      return null;
    }
    
    List<dynamic> jsonList = jsonDecode(await responseToStringBody(response));
    
    List<Subject> schedule = [];
    
    for (var jsonMap in jsonList) {
      schedule.add(Subject.fromJson(jsonMap));
    }

    return schedule;
  }
}
