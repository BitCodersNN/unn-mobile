// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/services/interfaces/common/app_theme_controller.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

@immutable
class DonationsThemeColors {
  final Color background;
  final Color surface;
  final Color foreground;
  final Color muted;
  final Color primary;
  final Color outline;

  const DonationsThemeColors({
    required this.background,
    required this.surface,
    required this.foreground,
    required this.muted,
    required this.primary,
    required this.outline,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationsThemeColors &&
          background == other.background &&
          surface == other.surface &&
          foreground == other.foreground &&
          muted == other.muted &&
          primary == other.primary &&
          outline == other.outline;

  @override
  int get hashCode =>
      Object.hash(background, surface, foreground, muted, primary, outline);
}

class DonationsViewModel extends BaseViewModel {
  final AppThemeController _themeController;

  Uri? _pageUri;
  bool _pageLoaded = false;
  String _pageTheme = 'light';
  String _pagePalette;
  Map<String, String> _pageColors = const {};

  DonationsViewModel(this._themeController)
    : _pagePalette = _themeController.lightTheme.name;

  Uri? get pageUri => _pageUri;
  bool get pageLoaded => _pageLoaded;
  String get pageTheme => _pageTheme;
  String get pagePalette => _pagePalette;
  Map<String, String> get pageColors => Map.unmodifiable(_pageColors);

  String get themeUpdateScript =>
      'window.setSupportTheme?.(${jsonEncode(_pageTheme)}, '
      '${jsonEncode(_pageColors)}, ${jsonEncode(_pagePalette)});';

  ({Uri? initialUri, String? script}) updateTheme({
    required Brightness brightness,
    required DonationsThemeColors colors,
  }) {
    _pageTheme = brightness == Brightness.dark ? 'dark' : 'light';
    _pagePalette = brightness == Brightness.dark
        ? _themeController.darkTheme.name
        : _themeController.lightTheme.name;
    _pageColors = {
      'background': _toHex(colors.background),
      'surface': _toHex(colors.surface),
      'foreground': _toHex(colors.foreground),
      'muted': _toHex(colors.muted),
      'primary': _toHex(colors.primary),
      'outline': _toHex(colors.outline),
    };

    if (_pageUri == null) {
      final baseUri = Uri.parse(
        '${ProtocolType.https.name}://${ApiPath.donation}',
      );
      _pageUri = baseUri.replace(
        queryParameters: {
          ...baseUri.queryParameters,
          'embedded': '1',
          'theme': _pageTheme,
          'palette': _pagePalette,
          ..._pageColors,
        },
      );
      return (initialUri: _pageUri, script: null);
    }

    if (_pageLoaded) {
      return (initialUri: null, script: themeUpdateScript);
    }

    return (initialUri: null, script: null);
  }

  void onPageStarted() => _pageLoaded = false;

  void onPageFinished() => _pageLoaded = true;

  static String _toHex(Color color) =>
      (color.toARGB32() & 0x00ffffff).toRadixString(16).padLeft(6, '0');
}
