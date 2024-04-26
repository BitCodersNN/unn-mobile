import 'package:flutter/material.dart';

enum IDType {
  group,
  student,
  person,
  lecturer,
  auditoriun,
}

class IDForSchedule {
  final IDType _idType;
  final String _id;

  const IDForSchedule(this._idType, this._id);

  IDType get idType => _idType;
  String get id => _id;
}

class ScheduleFilter {
  final DateTimeRange _dateTimeRange;
  late final IDForSchedule _id;

  ScheduleFilter(idType, id, this._dateTimeRange) {
    _id = IDForSchedule(idType, id);
  }

  IDType get idType => _id._idType;
  String get id => _id._id;
  DateTimeRange get dateTimeRange => _dateTimeRange;
}
