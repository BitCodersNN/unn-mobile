// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/distance_learning/distance_material_data.dart';

class _LinkDataJsonKeys {
  static const String link = 'link';
  static const String comment = 'comment';
  static const String dateTime = 'datetime';
}

final class DistanceLinkData extends DistanceMaterialData {
  final String link;

  DistanceLinkData({
    required this.link,
    required super.comment,
    required super.dateTime,
  });

  @override
  factory DistanceLinkData.fromJson(Map<String, Object?> jsonMap) =>
      DistanceLinkData(
        link: jsonMap[_LinkDataJsonKeys.link] as String,
        comment: jsonMap[_LinkDataJsonKeys.comment] as String,
        dateTime: DateTime.parse(
          jsonMap[_LinkDataJsonKeys.dateTime] as String,
        ),
      );

  @override
  Map<String, Object?> toJson() => {
        _LinkDataJsonKeys.link: link,
        _LinkDataJsonKeys.comment: comment,
        _LinkDataJsonKeys.dateTime: dateTime.toIso8601String(),
      };
}
