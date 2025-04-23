// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/json/json_key.dart';
import 'package:unn_mobile/core/misc/json/json_key_format.dart';

mixin BitrixJsonSerializable on MultiFormatJsonSerializable {
  Map<String, dynamic> toBitrixJson() => _toJsonForFormat(JsonKeyFormat.bitrix);
}

mixin BlogPostJsonSerializable on MultiFormatJsonSerializable {
  Map<String, dynamic> toBlogPostJson() =>
      _toJsonForFormat(JsonKeyFormat.blogPost);
}

mixin MessageJsonSerializable on MultiFormatJsonSerializable {
  Map<String, dynamic> toMessageJson() =>
      _toJsonForFormat(JsonKeyFormat.message);
}

mixin MultiFormatJsonSerializable {
  Map<JsonKeyFormat, JsonKeys> get availableFormats;

  @protected
  Map<String, dynamic> _toJsonForFormat(JsonKeyFormat format) {
    final keys = availableFormats[format]!;
    return buildJsonMap(keys);
  }

  @protected
  Map<String, dynamic> buildJsonMap(JsonKeys keys);

  Map<String, dynamic> toJson() => _toJsonForFormat(
        JsonKeyFormat.standard,
      );
}
