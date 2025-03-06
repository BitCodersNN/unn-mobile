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

class KeysForSubjectJsonConverter {
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
        jsonMap[KeysForSubjectJsonConverter.date] as String? ?? '';
    final String beginLesson =
        jsonMap[KeysForSubjectJsonConverter.beginLesson] as String? ?? '';
    final String endLesson =
        jsonMap[KeysForSubjectJsonConverter.endLesson] as String? ?? '';

    final String discipline =
        jsonMap[KeysForSubjectJsonConverter.discipline] as String? ?? '';

    final String kindOfWork =
        jsonMap[KeysForSubjectJsonConverter.kindOfWork] as String? ?? '';
    final String auditorium =
        jsonMap[KeysForSubjectJsonConverter.auditorium] as String? ?? '';
    final String building =
        jsonMap[KeysForSubjectJsonConverter.building] as String? ?? '';
    final String streamString =
        jsonMap[KeysForSubjectJsonConverter.stream] as String? ?? '';
    final String lecturer =
        jsonMap[KeysForSubjectJsonConverter.lecturer] as String? ?? '';

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
      KeysForSubjectJsonConverter.date: dateTimeRange.start.toString(),
      KeysForSubjectJsonConverter.beginLesson: _formatTime(dateTimeRange.start),
      KeysForSubjectJsonConverter.endLesson: _formatTime(dateTimeRange.end),
      KeysForSubjectJsonConverter.discipline: name,
      KeysForSubjectJsonConverter.kindOfWork: subjectType,
      KeysForSubjectJsonConverter.auditorium: address.auditorium,
      KeysForSubjectJsonConverter.building: address.building,
      KeysForSubjectJsonConverter.stream: groups.join('|'),
      KeysForSubjectJsonConverter.lecturer: lecturer,
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
