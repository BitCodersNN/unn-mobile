// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _OfflineScheduleJsonKeys {
  static const week = 'week';
  static const subjects = 'subjects';
  static const useRasp = 'useRasp';
}

class OfflineSchedule {
  final WeekRange week;
  final List<Subject> subjects;
  final bool useRasp;
  OfflineSchedule(this.week, this.subjects, {this.useRasp = false});

  factory OfflineSchedule.fromJson(JsonMap jsonMap) {
    final logger = Injector.appInstance.get<LoggerService>();
    return OfflineSchedule(
      WeekRange.fromJson(jsonMap[_OfflineScheduleJsonKeys.week]! as JsonMap),
      parseJsonIterable<Subject>(
        jsonMap[_OfflineScheduleJsonKeys.subjects]! as List<dynamic>,
        Subject.fromJson,
        logger,
      ),
      useRasp: jsonMap[_OfflineScheduleJsonKeys.useRasp] as bool? ?? false,
    );
  }

  JsonMap toJson() => {
    _OfflineScheduleJsonKeys.week: week.toJson(),
    _OfflineScheduleJsonKeys.useRasp: useRasp,
    _OfflineScheduleJsonKeys.subjects: subjects.map((e) => e.toJson()).toList(),
  };
}
