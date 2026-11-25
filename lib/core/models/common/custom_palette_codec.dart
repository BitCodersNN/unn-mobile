// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/palette_codec_constants.dart';
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

abstract final class _QueryKeys {
  static const config = 'c';
}

abstract final class _UriParts {
  static const httpsScheme = 'https';
  static const deepLinkHost = 'import';
}

abstract final class _BinaryFormat {
  static const version = 1;
  static const versionMask = 0x3F;
  static const hasBrightnessFlag = 0x40;
  static const darkFlag = 0x80;
  static const headerLength = 10;
  static const bytesPerColor = 3;

  // Stable bit order for binary serialization; append new slots at the end.
  static const List<PaletteColorSlot> overrideSlots = [
    PaletteColorSlot.surface,
    PaletteColorSlot.cardSurface,
    PaletteColorSlot.importantPostHighlight,
    PaletteColorSlot.onSurface,
    PaletteColorSlot.onSurfaceVariant,
    PaletteColorSlot.outlineVariant,
    PaletteColorSlot.wideButtonBottom,
    PaletteColorSlot.subjectLecture,
    PaletteColorSlot.subjectPractice,
    PaletteColorSlot.subjectLab,
    PaletteColorSlot.subjectExam,
    PaletteColorSlot.subjectConsult,
    PaletteColorSlot.subjectUnknown,
    PaletteColorSlot.markExcellent,
    PaletteColorSlot.markGood,
    PaletteColorSlot.markSatisfactory,
    PaletteColorSlot.markUnsatisfactory,
    PaletteColorSlot.markCredited,
    PaletteColorSlot.markNoShow,
    PaletteColorSlot.shimmerBase,
    PaletteColorSlot.shimmerHighlight,
  ];
}

abstract final class CustomPaletteCodec {
  static const prefix = PaletteCodecConstants.prefix;
  static const shareHost = PaletteCodecConstants.shareHost;
  static const sharePathPrefix = PaletteCodecConstants.sharePathPrefix;
  static const sharePath = PaletteCodecConstants.sharePath;
  static const deepLinkScheme = PaletteCodecConstants.deepLinkScheme;
  static const _maxLength = 8192;

  static String encode(CustomPaletteConfig config, {Brightness? brightness}) =>
      '$prefix${_encodePayload(config, brightness: brightness)}';

  static String _encodePayload(
    CustomPaletteConfig config, {
    Brightness? brightness,
  }) {
    var mask = 0;
    final orderedOverrides = <Color>[];
    for (var i = 0; i < _BinaryFormat.overrideSlots.length; i++) {
      final color = config.overrides[_BinaryFormat.overrideSlots[i]];
      if (color != null) {
        mask |= 1 << i;
        orderedOverrides.add(color);
      }
    }

    final bytes = Uint8List(
      _BinaryFormat.headerLength +
          orderedOverrides.length * _BinaryFormat.bytesPerColor,
    );
    var header = _BinaryFormat.version;
    if (brightness != null) {
      header |= _BinaryFormat.hasBrightnessFlag;
      if (brightness == Brightness.dark) {
        header |= _BinaryFormat.darkFlag;
      }
    }
    bytes[0] = header;
    _writeRgb(bytes, 1, config.primary);
    _writeRgb(bytes, 4, config.secondary);
    bytes[7] = (mask >> 16) & 0xFF;
    bytes[8] = (mask >> 8) & 0xFF;
    bytes[9] = mask & 0xFF;

    var offset = _BinaryFormat.headerLength;
    for (final color in orderedOverrides) {
      _writeRgb(bytes, offset, color);
      offset += _BinaryFormat.bytesPerColor;
    }

    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static Uri buildShareUri(
    CustomPaletteConfig config, {
    required Brightness brightness,
  }) => Uri.https(shareHost, sharePath, {
    _QueryKeys.config: _encodePayload(config, brightness: brightness),
  });

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
      final decoded = _decodePayload(payload);
      if (decoded != null) {
        return decoded;
      }
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
    return _decodePayload(payload);
  }

  static bool _isPaletteUri(Uri uri) =>
      (uri.scheme == deepLinkScheme && uri.host == _UriParts.deepLinkHost) ||
      (uri.scheme == _UriParts.httpsScheme &&
          uri.host == shareHost &&
          _isSharePath(uri.path));

  static bool _isSharePath(String path) =>
      path == sharePathPrefix || path.startsWith('$sharePathPrefix/');

  static DecodedPaletteLink? _decodePayload(String payload) {
    if (payload.isEmpty || payload.length > _maxLength) {
      return null;
    }
    final bytes = _tryDecodeBase64(payload);
    if (bytes == null || bytes.length < _BinaryFormat.headerLength) {
      return null;
    }
    final header = bytes[0];
    if ((header & _BinaryFormat.versionMask) != _BinaryFormat.version) {
      return null;
    }

    final brightness = (header & _BinaryFormat.hasBrightnessFlag) == 0
        ? null
        : (header & _BinaryFormat.darkFlag) != 0
        ? Brightness.dark
        : Brightness.light;

    final primary = _readRgb(bytes, 1);
    final secondary = _readRgb(bytes, 4);
    final mask = (bytes[7] << 16) | (bytes[8] << 8) | bytes[9];
    final slotCount = _BinaryFormat.overrideSlots.length;
    if ((mask >> slotCount) != 0) {
      return null;
    }

    final overrides = <PaletteColorSlot, Color>{};
    var offset = _BinaryFormat.headerLength;
    for (var i = 0; i < slotCount; i++) {
      if ((mask & (1 << i)) != 0) {
        if (offset + _BinaryFormat.bytesPerColor > bytes.length) {
          return null;
        }
        overrides[_BinaryFormat.overrideSlots[i]] = _readRgb(bytes, offset);
        offset += _BinaryFormat.bytesPerColor;
      }
    }
    if (offset != bytes.length) {
      return null;
    }

    return DecodedPaletteLink(
      config: CustomPaletteConfig(
        primary: primary,
        secondary: secondary,
        overrides: overrides,
      ),
      brightness: brightness,
    );
  }

  static void _writeRgb(Uint8List bytes, int offset, Color color) {
    final argb = color.toARGB32();
    bytes[offset] = (argb >> 16) & 0xFF;
    bytes[offset + 1] = (argb >> 8) & 0xFF;
    bytes[offset + 2] = argb & 0xFF;
  }

  static Color _readRgb(List<int> bytes, int offset) => Color(
    0xFF000000 |
        (bytes[offset] << 16) |
        (bytes[offset + 1] << 8) |
        bytes[offset + 2],
  );

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
}
