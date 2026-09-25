// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _ScheduleSearchSuggestionJsonKeys {
  static const String id = 'id';
  static const String label = 'label';
  static const String description = 'description';
}

class ScheduleSearchSuggestionItem {
  final String id;
  final String label;
  final String description;
  final bool isHistory;

  const ScheduleSearchSuggestionItem(
    this.id,
    this.label,
    this.description, {
    this.isHistory = false,
  });

  @override
  bool operator ==(Object other) =>
      other is ScheduleSearchSuggestionItem && (id == other.id);

  @override
  int get hashCode => Object.hash(id, label, description);

  factory ScheduleSearchSuggestionItem.fromJson(
    JsonMap jsonMap, {
    bool isHistory = false,
  }) =>
      ScheduleSearchSuggestionItem(
        jsonMap[_ScheduleSearchSuggestionJsonKeys.id]! as String,
        jsonMap[_ScheduleSearchSuggestionJsonKeys.label]! as String,
        jsonMap[_ScheduleSearchSuggestionJsonKeys.description]! as String,
        isHistory: isHistory,
      );

  JsonMap toJson() => {
        _ScheduleSearchSuggestionJsonKeys.id: id,
        _ScheduleSearchSuggestionJsonKeys.label: label,
        _ScheduleSearchSuggestionJsonKeys.description: description,
      };

  ScheduleSearchSuggestionItem copyWith({
    String? id,
    String? label,
    String? description,
    bool? isHistory,
  }) =>
      ScheduleSearchSuggestionItem(
        id ?? this.id,
        label ?? this.label,
        description ?? this.description,
        isHistory: isHistory ?? this.isHistory,
      );
}
