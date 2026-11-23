// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';

@immutable
class DecodedPaletteLink {
  final CustomPaletteConfig config;
  final Brightness? brightness;

  const DecodedPaletteLink({required this.config, this.brightness});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecodedPaletteLink &&
          config == other.config &&
          brightness == other.brightness;

  @override
  int get hashCode => Object.hash(config, brightness);
}

abstract final class CustomPaletteCodec {
  static const prefix = 'unn-palette:';
  static const shareHost = 'bitcodersnn.github.io';
  static const sharePathPrefix = '/unn-mobile.assets/palette';
  static const sharePath = '$sharePathPrefix/';
  static const deepLinkScheme = 'unnpalette';

  static String encode(CustomPaletteConfig config) {
    final jsonText = jsonEncode(config.toJson());
    final encoded = base64UrlEncode(utf8.encode(jsonText)).replaceAll('=', '');
    return '$prefix$encoded';
  }

  static Uri buildShareUri(
    CustomPaletteConfig config, {
    required Brightness brightness,
  }) {
    final payload = encode(config).substring(prefix.length);
    return Uri.https(shareHost, sharePath, {
      'b': brightness == Brightness.dark ? 'dark' : 'light',
      'c': payload,
    });
  }

  static CustomPaletteConfig? tryDecode(String raw) =>
      tryDecodeLink(raw)?.config;

  static DecodedPaletteLink? tryDecodeLink(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = _extractPaletteUri(trimmed);
    if (uri != null) {
      final fragmentParams = uri.fragment.isEmpty
          ? const <String, String>{}
          : _trySplitQueryString(
              uri.fragment.startsWith('?')
                  ? uri.fragment.substring(1)
                  : uri.fragment,
            );
      final payload = uri.queryParameters['c'] ?? fragmentParams['c'];
      if (payload != null && payload.isNotEmpty) {
        final config = _decodePayload(payload);
        if (config != null) {
          final brightness = _parseBrightness(
            uri.queryParameters['b'] ?? fragmentParams['b'],
          );
          return DecodedPaletteLink(config: config, brightness: brightness);
        }
      }
    }

    final match = RegularExpressions.customPaletteCodeRegExp.firstMatch(
      trimmed,
    );
    if (match != null) {
      final payload = match.group(1);
      if (payload == null) {
        return null;
      }
      final config = _decodePayload(payload);
      return config == null ? null : DecodedPaletteLink(config: config);
    }

    if (trimmed.startsWith('{')) {
      final config = CustomPaletteConfig.tryFromJson(_tryDecodeJson(trimmed));
      return config == null ? null : DecodedPaletteLink(config: config);
    }

    return null;
  }

  static Uri? _extractPaletteUri(String trimmed) {
    final directUri = Uri.tryParse(trimmed);
    if (directUri != null && _isPaletteUri(directUri)) {
      return directUri;
    }
    final match = RegularExpressions.paletteUrlRegExp.firstMatch(trimmed);
    final rawToken = match?.group(0);
    if (rawToken == null) {
      return null;
    }
    final token = rawToken.replaceFirst(
      RegularExpressions.trailingPunctuationRegExp,
      '',
    );
    final parsed = Uri.tryParse(token);
    if (parsed != null && _isPaletteUri(parsed)) {
      return parsed;
    }
    return null;
  }

  static bool _isPaletteUri(Uri uri) =>
      uri.scheme == deepLinkScheme ||
      (uri.scheme == 'https' &&
          uri.host == shareHost &&
          (uri.path == sharePathPrefix || uri.path.startsWith(sharePath)));

  static Brightness? _parseBrightness(String? value) => switch (value) {
    'light' => Brightness.light,
    'dark' => Brightness.dark,
    _ => null,
  };

  static CustomPaletteConfig? _decodePayload(String payload) {
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

  static Map<String, String> _trySplitQueryString(String query) {
    try {
      return Uri.splitQueryString(query);
    } catch (_) {
      return const {};
    }
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
