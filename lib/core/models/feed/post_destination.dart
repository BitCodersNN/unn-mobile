import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _PostDestinationJsonKeys {
  static const String id = 'id';
  static const String type = 'type';
  static const String name = 'name';
}

class PostDestination {
  final String type;
  final int id;
  final String name;

  PostDestination({
    required this.type,
    required this.id,
    required this.name,
  });

  JsonMap toJson() => {
        _PostDestinationJsonKeys.type: type,
        _PostDestinationJsonKeys.id: id,
        _PostDestinationJsonKeys.name: name,
      };

  factory PostDestination.fromJson(JsonMap json) => PostDestination(
        type: json[_PostDestinationJsonKeys.type]! as String,
        id: json[_PostDestinationJsonKeys.id]! as int,
        name: json[_PostDestinationJsonKeys.name]! as String,
      );
}
