// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';

abstract final class CustomPaletteCodec {
  static const prefix = 'unn-palette:';

  static String encode(CustomPaletteConfig config) {
    final jsonText = jsonEncode(config.toJson());
    final encoded = base64UrlEncode(utf8.encode(jsonText)).replaceAll('=', '');
    return '$prefix$encoded';
  }

  static CustomPaletteConfig? tryDecode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final match = RegularExpressions.customPaletteCodeRegExp.firstMatch(
      trimmed,
    );
    if (match != null) {
      final payload = match.group(1);
      if (payload == null) {
        return null;
      }
      final bytes = _tryDecodeBase64(payload);
      if (bytes == null) {
        return null;
      }
      final jsonSource = _tryDecodeUtf8(bytes);
      if (jsonSource == null) {
        return null;
      }
      return CustomPaletteConfig.tryFromJson(_tryDecodeJson(jsonSource));
    }
    if (trimmed.startsWith('{')) {
      return CustomPaletteConfig.tryFromJson(_tryDecodeJson(trimmed));
    }
    return null;
  }

  static List<int>? _tryDecodeBase64(String payload) {
    try {
      return base64Url.decode(base64Url.normalize(payload));
    } on FormatException {
      return null;
    }
  }

  static String? _tryDecodeUtf8(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return null;
    }
  }

  static Object? _tryDecodeJson(String source) {
    try {
      return jsonDecode(source);
    } on FormatException {
      return null;
    }
  }
}
