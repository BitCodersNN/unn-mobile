import 'package:flutter/material.dart';

class Address {
  final String _auditorium;
  final String _building;

  Address(this._auditorium, this._building);

  String get auditorium => _auditorium;
  String get building => _building;
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
}

class Subject {
  final String _name;
  final String _kindOfWork;
  final Address _address;
  final List<String> _groups;
  final String _lecturer;
  final DateTimeRange _dateTimeRange;

  const Subject(this._name, this._kindOfWork, this._address, this._groups,
      this._lecturer, this._dateTimeRange);

  String get name => _name;
  String get subjectType => _kindOfWork;
  Address get address => _address;
  List<String> get groups => _groups;
  String get lecturer => _lecturer;
  DateTimeRange get dateTimeRange => _dateTimeRange;

  factory Subject.fromJson(Map<String, Object?> jsonMap) {
    return Subject(
      jsonMap[KeysForSubjectJsonConverter.discipline] as String,
      jsonMap[KeysForSubjectJsonConverter.kindOfWork] as String,
      Address(jsonMap[KeysForSubjectJsonConverter.auditorium] as String, jsonMap[KeysForSubjectJsonConverter.building] as String),
      (jsonMap[KeysForSubjectJsonConverter.stream] as String).split('|'),
      jsonMap[KeysForSubjectJsonConverter.lecturer] as String,
      DateTimeRange(
          start: DateTime.parse(jsonMap[KeysForSubjectJsonConverter.beginLesson] as String),
          end: DateTime.parse(jsonMap[KeysForSubjectJsonConverter.endLesson] as String)),
    );
  }

  Map<String, dynamic> toJson() => {
        KeysForSubjectJsonConverter.discipline: _name,
        KeysForSubjectJsonConverter.kindOfWork: _kindOfWork,
        KeysForSubjectJsonConverter.building: _address.building,
        KeysForSubjectJsonConverter.auditorium: _address.auditorium,
        KeysForSubjectJsonConverter.stream: _groups.join('|'),
        KeysForSubjectJsonConverter.lecturer: _lecturer,
        KeysForSubjectJsonConverter.beginLesson:_dateTimeRange.start.toString(),
        KeysForSubjectJsonConverter.endLesson: _dateTimeRange.end.toString(),
      };
}
