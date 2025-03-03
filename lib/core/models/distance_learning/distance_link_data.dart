import 'package:unn_mobile/core/models/distance_learning/distance_material_data.dart';

class _KeysForLinkDataJsonConverter {
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
        link: jsonMap[_KeysForLinkDataJsonConverter.link] as String,
        comment: jsonMap[_KeysForLinkDataJsonConverter.comment] as String,
        dateTime: DateTime.parse(
          jsonMap[_KeysForLinkDataJsonConverter.dateTime] as String,
        ),
      );

  @override
  Map<String, Object?> toJson() => {
        _KeysForLinkDataJsonConverter.link: link,
        _KeysForLinkDataJsonConverter.comment: comment,
        _KeysForLinkDataJsonConverter.dateTime: dateTime.toIso8601String(),
      };
}
