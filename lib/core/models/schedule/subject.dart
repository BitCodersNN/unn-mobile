import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';

class _AbbreviatedNamesOfSubjectTypes {
  static const String lecture = 'лекци';
  static const String practice = 'практик';
  static const String seminar = 'семинарск';
  static const String lab = 'лабораторн';
  static const String exam = 'экзамен';
  static const String credit = 'зачёт';
  static const String consult = 'консультаци';
}

class Address {
  final String auditorium;
  final String building;

  Address({
    required this.auditorium,
    required this.building,
  });
}

enum SubjectType {
  unknown,
  lecture,
  practice,
  lab,
  exam,
  consult,
}

class _SubjectJsonKeys {
  static const String discipline = 'discipline';
  static const String kindOfWork = 'kindOfWork';
  static const String auditorium = 'auditorium';
  static const String building = 'building';
  static const String stream = 'stream';
  static const String lecturer = 'lecturer';
  static const String beginLesson = 'beginLesson';
  static const String endLesson = 'endLesson';
  static const String date = 'date';
}

class Subject {
  final String name;
  final String subjectType;
  final Address address;
  final List<String> groups;
  final String lecturer;
  final DateTimeRange dateTimeRange;

  Subject({
    required this.name,
    required this.subjectType,
    required this.address,
    required this.groups,
    required this.lecturer,
    required this.dateTimeRange,
  });

  SubjectType get subjectTypeEnum {
    final subjectTypeLowerCase = subjectType.toLowerCase();

    if (subjectTypeLowerCase.contains(_AbbreviatedNamesOfSubjectTypes.exam) ||
        subjectTypeLowerCase.contains(_AbbreviatedNamesOfSubjectTypes.credit)) {
      return SubjectType.exam;
    }

    if (subjectTypeLowerCase
        .contains(_AbbreviatedNamesOfSubjectTypes.consult)) {
      return SubjectType.consult;
    }

    if (subjectTypeLowerCase
        .contains(_AbbreviatedNamesOfSubjectTypes.lecture)) {
      return SubjectType.lecture;
    }

    if (subjectTypeLowerCase
            .contains(_AbbreviatedNamesOfSubjectTypes.practice) ||
        (subjectTypeLowerCase
            .contains(_AbbreviatedNamesOfSubjectTypes.seminar))) {
      return SubjectType.practice;
    }

    if (subjectTypeLowerCase.contains(_AbbreviatedNamesOfSubjectTypes.lab)) {
      return SubjectType.lab;
    }

    return SubjectType.unknown;
  }

  factory Subject.fromJson(Map<String, dynamic> jsonMap) {
    final String date =
        jsonMap[_SubjectJsonKeys.date] as String? ?? '';
    final String beginLesson =
        jsonMap[_SubjectJsonKeys.beginLesson] as String? ?? '';
    final String endLesson =
        jsonMap[_SubjectJsonKeys.endLesson] as String? ?? '';

    final String discipline =
        jsonMap[_SubjectJsonKeys.discipline] as String? ?? '';

    final String kindOfWork =
        jsonMap[_SubjectJsonKeys.kindOfWork] as String? ?? '';
    final String auditorium =
        jsonMap[_SubjectJsonKeys.auditorium] as String? ?? '';
    final String building =
        jsonMap[_SubjectJsonKeys.building] as String? ?? '';
    final String streamString =
        jsonMap[_SubjectJsonKeys.stream] as String? ?? '';
    final String lecturer =
        jsonMap[_SubjectJsonKeys.lecturer] as String? ?? '';

    return Subject(
      name: discipline,
      subjectType: kindOfWork,
      address: Address(
        auditorium: auditorium,
        building: building,
      ),
      groups: streamString.split('|'),
      lecturer: lecturer,
      dateTimeRange: DateTimeRange(
        start: _parseDateTime(date, beginLesson),
        end: _parseDateTime(date, endLesson),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _SubjectJsonKeys.date: dateTimeRange.start.toString(),
      _SubjectJsonKeys.beginLesson: _formatTime(dateTimeRange.start),
      _SubjectJsonKeys.endLesson: _formatTime(dateTimeRange.end),
      _SubjectJsonKeys.discipline: name,
      _SubjectJsonKeys.kindOfWork: subjectType,
      _SubjectJsonKeys.auditorium: address.auditorium,
      _SubjectJsonKeys.building: address.building,
      _SubjectJsonKeys.stream: groups.join('|'),
      _SubjectJsonKeys.lecturer: lecturer,
    };
  }

  static DateTime _parseDateTime(String date, String time) {
    return DateTimeParser.parse(
      '$date $time',
      DatePattern.ymmddhm,
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute}';
  }
}
