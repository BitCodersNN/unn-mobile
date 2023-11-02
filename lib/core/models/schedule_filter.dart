import 'package:flutter/material.dart';

enum TypeID{
  group,
  student,
  person,
  auditoriun,
}

class ScheduleFilter{
  final TypeID _typeID;
  final DateTimeRange _dateTimeRange;

  ScheduleFilter(this._typeID, this._dateTimeRange);

  TypeID get typeID => _typeID;
  DateTimeRange get dateTimeRange => _dateTimeRange;
}
