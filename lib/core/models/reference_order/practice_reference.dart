import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/reference_order/reference.dart';

class _KeysForPracticeReferenceJsonConverter {
  static const String type = 'type';
  static const String date1 = 'date1';
  static const String date2 = 'date2';
  static const String num = 'num';
}

class PracticeReference extends Reference {
  final String type;
  final DateTimeRange practiceDateTimeRange;
  final int num;

  PracticeReference({
    required super.name,
    required super.sendtype,
    required super.description,
    required super.referencePath,
    required this.type,
    required this.practiceDateTimeRange,
    required this.num,
  });

  factory PracticeReference.fromJson(Map<String, Object?> jsonMap) {
    final reference = Reference.fromJson(jsonMap);

    return PracticeReference(
      name: reference.name,
      sendtype: reference.sendtype,
      description: reference.description,
      referencePath: reference.referencePath,
      type: jsonMap[_KeysForPracticeReferenceJsonConverter.type] as String,
      practiceDateTimeRange: DateTimeRange(
        start: DateTime.parse(
          jsonMap[_KeysForPracticeReferenceJsonConverter.date1] as String,
        ),
        end: DateTime.parse(
          jsonMap[_KeysForPracticeReferenceJsonConverter.date2] as String,
        ),
      ),
      num: jsonMap[_KeysForPracticeReferenceJsonConverter.num] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        _KeysForPracticeReferenceJsonConverter.type: type,
        _KeysForPracticeReferenceJsonConverter.date1:
            practiceDateTimeRange.start.toIso8601String(),
        _KeysForPracticeReferenceJsonConverter.date2:
            practiceDateTimeRange.end.toIso8601String(),
        _KeysForPracticeReferenceJsonConverter.num: num,
      };
}
