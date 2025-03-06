import 'package:flutter/material.dart';

enum IdType {
  group,
  student,
  person,
  lecturer,
  auditoriun,
}

class IdForSchedule {
  final IdType _idType;
  final String _id;

  const IdForSchedule(this._idType, this._id);

  IdType get idType => _idType;
  String get id => _id;
}

class ScheduleFilter {
  final DateTimeRange _dateTimeRange;
  late final IdForSchedule _id;

  ScheduleFilter(idType, id, this._dateTimeRange) {
    _id = IdForSchedule(idType, id);
  }

  IdType get idType => _id._idType;
  String get id => _id._id;
  DateTimeRange get dateTimeRange => _dateTimeRange;
}
