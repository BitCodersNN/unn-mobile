import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';

class GettingScheduleServiceImpl implements GettingScheduleService {
  final String _start = 'start';
  final String _finish = 'finish';
  final String _lng = 'lng';
  final String _path = 'ruzapi/schedule/';
  final String _date = 'date';
  final String _dateFormat = 'y.MM.dd H:m';
  final String _splitPaternForStream = '|';

  @override
  Future<List<Subject>?> getSchedule(ScheduleFilter scheduleFilter) async {
    final path = '$_path${scheduleFilter.idType.name}/${scheduleFilter.id}';
    final requstSender = HttpRequestSender(path: path, queryParams: {
      _start: scheduleFilter.dateTimeRange.start
          .toIso8601String()
          .split('T')[0]
          .replaceAll('-', '.'),
      _finish: scheduleFilter.dateTimeRange.end
          .toIso8601String()
          .split('T')[0]
          .replaceAll('-', '.'),
      _lng: '1',
    });

    HttpClientResponse response;
    try {
      response = await requstSender.get();
    } catch (e) {
      log(e.toString());
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      return null;
    }
    
    List<dynamic> jsonList;
    
    try {
      jsonList = jsonDecode(await HttpRequestSender.responseToStringBody(response));
    } catch(e) {
      return null;
    }

    List<Subject> schedule = [];

    for (var jsonMap in jsonList) {
      schedule.add(_convertFromJson(jsonMap));
    }

    return schedule;
  }

  Subject _convertFromJson(Map<String, Object?> jsonMap) {
    DateTime startDateTime = DateFormat(_dateFormat).parse(
        '${jsonMap[_date] as String} ${jsonMap[KeysForSubjectJsonConverter.beginLesson] as String}');
    DateTime endDateTime = DateFormat(_dateFormat).parse(
        '${jsonMap[_date] as String} ${jsonMap[KeysForSubjectJsonConverter.endLesson] as String}');

    return Subject(
      jsonMap[KeysForSubjectJsonConverter.discipline] as String,
      (jsonMap[KeysForSubjectJsonConverter.kindOfWork] ?? '') as String,
      Address(jsonMap[KeysForSubjectJsonConverter.auditorium] as String,
          jsonMap[KeysForSubjectJsonConverter.building] as String),
      ((jsonMap[KeysForSubjectJsonConverter.stream] ?? '') as String).split(_splitPaternForStream),
      (jsonMap[KeysForSubjectJsonConverter.lecturer] ?? '') as String,
      DateTimeRange(start: startDateTime, end: endDateTime),
    );
  }
}
