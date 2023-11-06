import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


enum SubjectType {
  practice,
  laboratory,
  consultation,
  lecture,
  credit,
  exam,
}


class Address {
  final String _auditorium;
  final String _building;

  Address(this._auditorium, this._building);

  String get auditorium => _auditorium;
  String get building => _building;
}

class Subject {
  final String _name;
  final SubjectType _subjectType;
  final Address _address;
  final List<String> _groups;
  final String _lecturer;
  final DateTimeRange _dateTimeRange;

  Subject(this._name, this._subjectType, this._address, this._groups,
      this._lecturer, this._dateTimeRange);

  String get name => _name;
  SubjectType get subjectType => _subjectType;
  Address get address => _address;
  List<String> get groups => _groups;
  String get lecturer => _lecturer;
  DateTimeRange get dateTimeRange => _dateTimeRange;

  factory Subject.fromJson(Map<String, Object?> jsonMap) {
    DateTime startDateTime = DateFormat('y.MM.dd H:m').parse('${jsonMap['date'] as String} ${jsonMap['beginLesson'] as String}');
    DateTime endDateTime = DateFormat('y.MM.dd H:m').parse('${jsonMap['date'] as String} ${jsonMap['endLesson'] as String}');
    
    final subjectType = switch(jsonMap['kindOfWork'] as String) {
      'Лекция' => SubjectType.lecture,
      'Практика (семинарские занятия)' => SubjectType.practice,
      'Лабораторная' => SubjectType.laboratory,
      'Зачёт' => SubjectType.credit,
      'Консультации перед экзаменом' => SubjectType.consultation,
      'Экзамен' => SubjectType.exam,
      String() => null,
    };

    return Subject(
      jsonMap['discipline'] as String,
      subjectType!,
      Address(jsonMap['auditorium'] as String, jsonMap['building'] as String),
      (jsonMap['stream'] as String).split('|'),
      jsonMap['lecturer'] as String,
      DateTimeRange(start: startDateTime, end: endDateTime),
    );
  }

  Map toJson() => {
        'discipline': _name,
        'subjectType': _subjectType.name,
        'building': _address.building,
        'auditorium': _address.auditorium,
        'groups': _groups.join('|'),
        'lecturer': _lecturer,
        'beginLesson': _dateTimeRange.start,
        'endLesson': _dateTimeRange.end,
      };
}
