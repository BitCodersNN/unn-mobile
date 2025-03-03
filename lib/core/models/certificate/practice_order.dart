import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';
import 'package:unn_mobile/core/models/certificate/certificate.dart';

class _KeysForPracticeOrderJsonConverter {
  static const String type = 'type';
  static const String date1 = 'date1';
  static const String date2 = 'date2';
  static const String num = 'num';
}

class PracticeOrder extends Certificate {
  final String type;
  final DateTimeRange practiceDateTimeRange;
  final int num;

  PracticeOrder({
    required super.name,
    required super.sendtype,
    required super.description,
    required super.certificatePath,
    required this.type,
    required this.practiceDateTimeRange,
    required this.num,
  });

  factory PracticeOrder.fromJson(Map<String, Object?> jsonMap) {
    final certificate = Certificate.fromJson(jsonMap);

    return PracticeOrder(
      name: certificate.name,
      sendtype: certificate.sendtype,
      description: certificate.description,
      certificatePath: certificate.certificatePath,
      type: jsonMap[_KeysForPracticeOrderJsonConverter.type] as String,
      practiceDateTimeRange: DateTimeRange(
        start: DateTimeParser.parse(
          jsonMap[_KeysForPracticeOrderJsonConverter.date1] as String,
          DatePattern.ddmmyyyy,
        ),
        end: DateTimeParser.parse(
          jsonMap[_KeysForPracticeOrderJsonConverter.date2] as String,
          DatePattern.ddmmyyyy,
        ),
      ),
      num: jsonMap[_KeysForPracticeOrderJsonConverter.num] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        _KeysForPracticeOrderJsonConverter.type: type,
        _KeysForPracticeOrderJsonConverter.date1:
            practiceDateTimeRange.start.format(DatePattern.ddmmyyyy),
        _KeysForPracticeOrderJsonConverter.date2:
            practiceDateTimeRange.end.format(DatePattern.ddmmyyyy),
        _KeysForPracticeOrderJsonConverter.num: num,
      };
}
