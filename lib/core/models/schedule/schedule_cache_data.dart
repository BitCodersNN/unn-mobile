// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_entry.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_configuration.dart';

class _JsonKeys {
  static const String version = 'version';
  static const String widget = 'widget';
  static const String entries = 'entries';
}

class ScheduleCacheData {
  static const int schemaVersion = 1;

  final ScheduleWidgetConfiguration? widget;
  final List<ScheduleCacheEntry> entries;

  ScheduleCacheData({
    this.widget,
    Iterable<ScheduleCacheEntry> entries = const [],
  }) : entries = List.unmodifiable(entries);

  factory ScheduleCacheData.fromJson(JsonMap json) {
    if (json[_JsonKeys.version] != schemaVersion) {
      throw const FormatException('Unsupported schedule cache version');
    }
    final widgetJson = json[_JsonKeys.widget] as JsonMap?;
    return ScheduleCacheData(
      widget: widgetJson == null
          ? null
          : ScheduleWidgetConfiguration.fromJson(widgetJson),
      entries: (json[_JsonKeys.entries]! as List<Object?>).map(
        (entry) => ScheduleCacheEntry.fromJson(entry! as JsonMap),
      ),
    );
  }

  JsonMap toJson() => {
    _JsonKeys.version: schemaVersion,
    _JsonKeys.widget: widget?.toJson(),
    _JsonKeys.entries: entries.map((entry) => entry.toJson()).toList(),
  };
}
