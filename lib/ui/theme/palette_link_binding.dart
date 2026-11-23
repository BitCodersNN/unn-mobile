// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/app_theme_controller.dart';
import 'package:unn_mobile/core/models/common/custom_palette_codec.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/palette_link_platform.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/custom_palette_import_dialog.dart';

class PaletteLinkBinding with WidgetsBindingObserver {
  final PaletteLinkPlatform _platform;
  final AppThemeController _themeController;
  final AppRouter _router;
  final LoggerService _logger;
  DecodedPaletteLink? _pendingDecoded;
  bool _handling = false;
  bool _presentationScheduled = false;
  bool _disposed = false;

  PaletteLinkBinding(
    this._platform,
    this._themeController,
    this._router,
    this._logger,
  );

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _router.router.routerDelegate.addListener(_trySchedulePresentation);
    _platform.setOnLink(_enqueueLink);
    unawaited(_consumeInitialLink());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_consumeInitialLink());
    }
  }

  Future<void> _consumeInitialLink() async {
    final initialUrl = await _platform.consumeInitialLink();
    if (_disposed || initialUrl == null) {
      return;
    }
    _enqueueLink(initialUrl);
  }

  void _enqueueLink(String rawUrl) {
    if (_disposed) {
      return;
    }
    final decoded = CustomPaletteCodec.tryDecodeLink(rawUrl);
    if (decoded == null) {
      return;
    }
    _pendingDecoded = decoded;
    _trySchedulePresentation();
  }

  bool get _isRouteReady {
    final config = _router.router.routerDelegate.currentConfiguration;
    if (config.isEmpty) {
      return false;
    }
    return config.uri.path != loadingPageRoute;
  }

  void _trySchedulePresentation() {
    if (_disposed ||
        _handling ||
        _presentationScheduled ||
        _pendingDecoded == null ||
        !_isRouteReady) {
      return;
    }
    _presentationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _presentationScheduled = false;
      unawaited(_presentPending());
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _presentPending() async {
    if (_disposed || _handling || _pendingDecoded == null || !_isRouteReady) {
      return;
    }
    final navContext =
        _router.router.routerDelegate.navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) {
      return;
    }
    final decoded = _pendingDecoded!;
    _pendingDecoded = null;
    _handling = true;
    try {
      await _presentAndApply(navContext, decoded);
    } finally {
      _handling = false;
    }
    _trySchedulePresentation();
  }

  Future<void> _presentAndApply(
    BuildContext navContext,
    DecodedPaletteLink decoded,
  ) async {
    final brightness =
        decoded.brightness ?? MediaQuery.platformBrightnessOf(navContext);
    final confirmed = await showCustomPaletteConfirmImportDialog(
      navContext,
      config: decoded.config,
      brightness: brightness,
    );
    if (!confirmed || _disposed) {
      return;
    }
    var applied = true;
    try {
      await _themeController.applyCustomPalette(
        decoded.config,
        brightness: brightness,
      );
    } catch (error, stack) {
      _logger.logError(error, stack);
      applied = false;
    }
    if (_disposed || !navContext.mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(navContext)?.showSnackBar(
      SnackBar(
        content: Text(
          applied ? 'Палитра применена' : 'Не удалось применить палитру',
        ),
      ),
    );
  }

  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _router.router.routerDelegate.removeListener(_trySchedulePresentation);
    _platform.dispose();
  }
}
