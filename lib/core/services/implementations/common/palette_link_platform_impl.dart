// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/services.dart';
import 'package:unn_mobile/core/misc/platform_utils.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/palette_link_platform.dart';

class PaletteLinkPlatformImpl implements PaletteLinkPlatform {
  static const _channel = MethodChannel(
    'ru.bitcodersnn.unnstudenthub/palette_link',
  );
  final LoggerService _logger;

  PaletteLinkPlatformImpl(this._logger);

  @override
  Future<String?> consumeInitialLink() async {
    if (!isMobilePlatform) {
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
  void setOnLink(ValueChanged<String> onLink) {
    if (!isMobilePlatform) {
      return;
    }
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'openPaletteLink') {
        throw MissingPluginException();
      }
      if (call.arguments case final String link) {
        onLink(link);
      }
    });
  }

  @override
  void dispose() {
    if (!isMobilePlatform) {
      return;
    }
    _channel.setMethodCallHandler(null);
  }
}
