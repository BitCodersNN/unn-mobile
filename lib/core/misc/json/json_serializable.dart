// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/json/json_key.dart';
import 'package:unn_mobile/core/misc/json/json_key_format.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';

mixin BitrixJsonSerializable on MultiFormatJsonSerializable {
  JsonMap toBitrixJson() => _toJsonForFormat(JsonKeyFormat.bitrix);
}

mixin BlogPostJsonSerializable on MultiFormatJsonSerializable {
  JsonMap toBlogPostJson() => _toJsonForFormat(JsonKeyFormat.blogPost);
}

mixin MessageJsonSerializable on MultiFormatJsonSerializable {
  JsonMap toMessageJson() => _toJsonForFormat(JsonKeyFormat.message);
}

mixin ProfileJsonSerializable on MultiFormatJsonSerializable {
  JsonMap toProfileJson() => _toJsonForFormat(JsonKeyFormat.profile);
}

mixin MultiFormatJsonSerializable {
  Map<JsonKeyFormat, JsonKeys> get availableFormats;

  @protected
  JsonMap _toJsonForFormat(JsonKeyFormat format) {
    final keys = availableFormats[format]!;
    return buildJsonMap(keys);
  }

  @protected
  JsonMap buildJsonMap(JsonKeys keys);

  JsonMap toJson() => _toJsonForFormat(
        JsonKeyFormat.standard,
      );
}
