// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

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

  ScheduleFilter(IdType idType, String id, this._dateTimeRange) {
    _id = IdForSchedule(idType, id);
  }

  IdType get idType => _id._idType;
  String get id => _id._id;
  DateTimeRange get dateTimeRange => _dateTimeRange;

  ScheduleFilter copyWith({
    IdType? idType,
    String? id,
    DateTimeRange? dateTimeRange,
  }) =>
      ScheduleFilter(
        idType ?? this.idType,
        id ?? this.id,
        dateTimeRange ?? this.dateTimeRange,
      );
}

extension IdTypeExtensions on IdType {
  String getDisplayName() => switch (this) {
        IdType.group => 'Группа',
        IdType.student => 'Студент',
        IdType.lecturer => 'Преподаватель',
        IdType.person => 'Преподаватель',
        IdType.auditoriun => 'Аудитория',
      };
}
