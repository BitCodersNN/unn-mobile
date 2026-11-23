// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/palette_link_platform.dart';

class PaletteLinkPlatformImpl implements PaletteLinkPlatform {
  static const _channel = MethodChannel(
    'ru.bitcodersnn.unnstudenthub/palette_link',
  );
  final LoggerService _logger;

  PaletteLinkPlatformImpl(this._logger);

  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<String?> consumeInitialLink() async {
    if (!_isSupported) {
      return null;
    }
    try {
      return await _channel.invokeMethod<String>('consumeInitialLink');
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }

  @override
  void setOnLink(ValueChanged<String>? onLink) {
    if (!_isSupported) {
      return;
    }
    _channel.setMethodCallHandler(
      onLink == null
          ? null
          : (call) async {
              if (call.method == 'openPaletteLink') {
                final link = call.arguments as String?;
                if (link != null) {
                  onLink(link);
                }
              }
            },
    );
  }

  @override
  void dispose() {
    if (!_isSupported) {
      return;
    }
    _channel.setMethodCallHandler(null);
  }
}
