import 'package:flutter/material.dart';
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
        start: DateTime.parse(
          jsonMap[_KeysForPracticeOrderJsonConverter.date1] as String,
        ),
        end: DateTime.parse(
          jsonMap[_KeysForPracticeOrderJsonConverter.date2] as String,
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
            practiceDateTimeRange.start.toIso8601String(),
        _KeysForPracticeOrderJsonConverter.date2:
            practiceDateTimeRange.end.toIso8601String(),
        _KeysForPracticeOrderJsonConverter.num: num,
      };
}
