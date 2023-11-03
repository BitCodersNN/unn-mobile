import 'package:flutter/material.dart';

enum SubjectType{
  practice,
  lecture,
  credit,
  exam,
}

class Address{
  final String _auditorium;
  final String _building;
  
  Address(this._auditorium, this._building);

  String get auditorium => _auditorium;
  String get building => _building;
}

class Subject{
  final String _name;
  final SubjectType _subjectType;
  final Address _address;
  final List<String> _groups;
  final String _lecturer;
  final DateTimeRange _dateTimeRange;

  Subject(this._name, this._subjectType, this._address, this._groups, this._lecturer, this._dateTimeRange);

  String get name => _name;
  SubjectType get subjectType => _subjectType;
  Address get address => _address;
  List<String> get groups => _groups;
  String get lecturer => _lecturer;
  DateTimeRange get dateTimeRange => _dateTimeRange;


  factory Subject.fromJson(Map<String, Object?> jsonMap){
    List<int> date = (jsonMap['date'] as String).split('.').map(int.parse).toList();
    List<int> startTime = (jsonMap['beginLesson'] as String).split(':').map(int.parse).toList();
    List<int> endTime = (jsonMap['endLesson'] as String).split(':').map(int.parse).toList();

    DateTime startDateTime = DateTime(date[0], date[1], date[2], startTime[0], startTime[1]);
    DateTime endDateTime = DateTime(date[0], date[1], date[2], endTime[0], endTime[1]);

    return Subject(
      jsonMap['name'] as String,
      SubjectType.values.byName(jsonMap['kindOfWork'] as String), 
      Address(jsonMap['auditorium'] as String, jsonMap['building'] as String),
      (jsonMap['stream'] as String).split('|'),
      jsonMap['lecturer'] as String,
      DateTimeRange(start: startDateTime, end: endDateTime),
      );
  }

  Map toJson() => { 
    'name': _name, 
    'subjectType': _subjectType.name,
    'building': _address.building,
    'auditorium': _address.auditorium,
    'groups': _groups.join('|'),
    'lecturer': _lecturer,
    'beginLesson': _dateTimeRange.start,
    'endLesson': _dateTimeRange.end,
    };

}