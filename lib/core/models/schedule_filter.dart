import 'package:flutter/material.dart';

enum IDType{
  group,
  student,
  person,
  auditoriun,
}

class ScheduleFilter{
  final IDType _typeID;
  final DateTimeRange _dateTimeRange;

  ScheduleFilter(this._typeID, this._dateTimeRange);

  IDType get typeID => _typeID;
  DateTimeRange get dateTimeRange => _dateTimeRange;
}
