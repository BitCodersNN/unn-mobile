// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
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

abstract final class _QueryKeys {
  static const brightness = 'b';
  static const config = 'c';
}

abstract final class _BrightnessValues {
  static const light = 'light';
  static const dark = 'dark';
}

abstract final class _UriParts {
  static const httpsScheme = 'https';
  static const deepLinkHost = 'import';
}

abstract final class CustomPaletteCodec {
  static const prefix = 'unn-palette:';
  static const shareHost = 'bitcodersnn.github.io';
  static const sharePathPrefix = '/unn-mobile.assets/palette';
  static const sharePath = '$sharePathPrefix/';
  static const deepLinkScheme = 'unnpalette';
  static const _maxLength = 8192;

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
      _QueryKeys.brightness: brightness == Brightness.dark
          ? _BrightnessValues.dark
          : _BrightnessValues.light,
      _QueryKeys.config: payload,
    });
  }

  static CustomPaletteConfig? tryDecode(String raw) =>
      tryDecodeLink(raw)?.config;

  static DecodedPaletteLink? tryDecodeLink(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.length > _maxLength) {
      return null;
    }

    final uriResult = _tryDecodePaletteUris(trimmed);
    if (uriResult != null) {
      return uriResult;
    }

    for (final match in RegularExpressions.customPaletteCodeRegExp.allMatches(
      trimmed,
    )) {
      final payload = match.group(1);
      if (payload == null) {
        continue;
      }
      final config = _decodePayload(payload);
      if (config != null) {
        return DecodedPaletteLink(config: config);
      }
    }

    if (trimmed.startsWith('{')) {
      final config = CustomPaletteConfig.tryFromJson(tryDecodeJson(trimmed));
      return config == null ? null : DecodedPaletteLink(config: config);
    }

    return null;
  }

  static DecodedPaletteLink? _tryDecodePaletteUris(String trimmed) {
    final directUri = Uri.tryParse(trimmed);
    if (directUri != null && _isPaletteUri(directUri)) {
      final decoded = _decodePaletteUri(directUri);
      if (decoded != null) {
        return decoded;
      }
    }

    for (final match in RegularExpressions.paletteUrlRegExp.allMatches(
      trimmed,
    )) {
      final rawToken = match.group(0);
      if (rawToken == null) {
        continue;
      }
      final token = rawToken.replaceFirst(
        RegularExpressions.trailingPunctuationRegExp,
        '',
      );
      final parsed = Uri.tryParse(token);
      if (parsed == null || !_isPaletteUri(parsed)) {
        continue;
      }
      final decoded = _decodePaletteUri(parsed);
      if (decoded != null) {
        return decoded;
      }
    }

    return null;
  }

  static DecodedPaletteLink? _decodePaletteUri(Uri uri) {
    final fragmentParams = uri.fragment.isEmpty
        ? const <String, String>{}
        : _trySplitQueryString(
            uri.fragment.startsWith('?')
                ? uri.fragment.substring(1)
                : uri.fragment,
          );
    final payload =
        uri.queryParameters[_QueryKeys.config] ??
        fragmentParams[_QueryKeys.config];
    if (payload == null || payload.isEmpty) {
      return null;
    }
    final config = _decodePayload(payload);
    if (config == null) {
      return null;
    }
    final brightness = _parseBrightness(
      uri.queryParameters[_QueryKeys.brightness] ??
          fragmentParams[_QueryKeys.brightness],
    );
    return DecodedPaletteLink(config: config, brightness: brightness);
  }

  static bool _isPaletteUri(Uri uri) =>
      (uri.scheme == deepLinkScheme && uri.host == _UriParts.deepLinkHost) ||
      (uri.scheme == _UriParts.httpsScheme &&
          uri.host == shareHost &&
          _isSharePath(uri.path));

  static bool _isSharePath(String path) =>
      path == sharePathPrefix || path.startsWith('$sharePathPrefix/');

  static Brightness? _parseBrightness(String? value) => switch (value) {
    _BrightnessValues.light => Brightness.light,
    _BrightnessValues.dark => Brightness.dark,
    _ => null,
  };

  static CustomPaletteConfig? _decodePayload(String payload) {
    if (payload.isEmpty || payload.length > _maxLength) {
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
    return CustomPaletteConfig.tryFromJson(tryDecodeJson(jsonSource));
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
}
