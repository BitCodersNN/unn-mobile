// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/misc/hex_color.dart';
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
}

class DonationsViewModel extends BaseViewModel {
  final AppThemeController _themeController;

  Uri? _pageUri;
  bool _pageLoaded = false;
  String _pageTheme = 'light';
  String _pagePalette = '';
  Map<String, String> _pageColors = const {};

  DonationsViewModel(this._themeController);

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
      'background': colors.background.toHexRgb(),
      'surface': colors.surface.toHexRgb(),
      'foreground': colors.foreground.toHexRgb(),
      'muted': colors.muted.toHexRgb(),
      'primary': colors.primary.toHexRgb(),
      'outline': colors.outline.toHexRgb(),
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
}
