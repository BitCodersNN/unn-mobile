import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';

class GetScheduleServiceImpl implements GetScheduleService {
  final String _start = 'start';
  final String _finish = 'finish';
  final String _lng = '1';
  final String _path = 'ruzapi/schedule/';

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

    List<dynamic> jsonList = jsonDecode(await HttpRequestSender.responseToStringBody(response));

    List<Subject> schedule = [];

    for (var jsonMap in jsonList) {
      schedule.add(_convertFromJson(jsonMap));
    }

    return schedule;
  }

  Subject _convertFromJson(Map<String, Object?> jsonMap) {
    DateTime startDateTime = DateFormat('y.MM.dd H:m').parse(
        '${jsonMap['date'] as String} ${jsonMap[KeysForSubjectJsonConverter.beginLesson] as String}');
    DateTime endDateTime = DateFormat('y.MM.dd H:m').parse(
        '${jsonMap['date'] as String} ${jsonMap[KeysForSubjectJsonConverter.endLesson] as String}');

    final subjectType = switch ((jsonMap[KeysForSubjectJsonConverter.kindOfWork] ?? "Неизвестно") as String) {
      'Лекция' => SubjectType.lecture,
      'Практика (семинарские занятия)' => SubjectType.practice,
      'Лабораторная' => SubjectType.laboratory,
      'Зачёт' => SubjectType.credit,
      'Консультации перед экзаменом' => SubjectType.consultation,
      'Экзамен' => SubjectType.exam,
      'Неизвестно' => SubjectType.unknown,
      String() => null,
    };

    return Subject(
      jsonMap[KeysForSubjectJsonConverter.discipline] as String,
      subjectType!,
      Address(jsonMap[KeysForSubjectJsonConverter.auditorium] as String,
          jsonMap[KeysForSubjectJsonConverter.building] as String),
      ((jsonMap[KeysForSubjectJsonConverter.stream] ?? '') as String).split('|'),
      (jsonMap[KeysForSubjectJsonConverter.lecturer] ?? '')as String,
      DateTimeRange(start: startDateTime, end: endDateTime),
    );
  }
}
