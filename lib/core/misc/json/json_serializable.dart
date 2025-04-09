import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/json/json_key.dart';
import 'package:unn_mobile/core/misc/json/json_key_format.dart';

abstract class JsonSerializable {
  @protected
  Map<JsonKeyFormat, JsonKeys> get formatToKeys;

  @protected
  Map<String, dynamic> buildJsonMap(JsonKeys jsonKeys);

  Map<String, dynamic> toJson({
    JsonKeyFormat format = JsonKeyFormat.standard,
  }) {
    final jsonKeys = formatToKeys[format];

    if (jsonKeys == null) {
      throw ArgumentError.value(
        format,
        'format',
        'Unsupported JsonKeyFormat. Expected one of: ${formatToKeys.keys.join(', ')}',
      );
    }

    return buildJsonMap(jsonKeys);
  }
}
