import 'package:flutter/material.dart';

enum IdType{
  group,
  student,
  person,
  auditoriun,
}

class ScheduleFilter{
  final IdType _idType;
  final String _id;
  final DateTimeRange _dateTimeRange;

  ScheduleFilter(this._idType, this._id, this._dateTimeRange);

  IdType get idType => _idType;
  String get id => _id;
  DateTimeRange get dateTimeRange => _dateTimeRange;
}
