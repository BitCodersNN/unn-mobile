// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/custom_palette_codec.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/actions/share_utils.dart';

/// Открывает системную отправку кода пользовательской палитры.
Future<void> shareCustomPalette(
  BuildContext context,
  CustomPaletteConfig config, {
  required Brightness brightness,
}) => runGuardedShare(
  context: context,
  errorMessage: 'Не удалось поделиться палитрой',
  action: (_) async {
    final code = CustomPaletteCodec.encode(config);
    final brightnessLabel = brightness == Brightness.dark
        ? 'тёмная'
        : 'светлая';
    final text = 'Моя $brightnessLabel палитра для UNN Mobile:\n$code';
    final origin = resolveSharePositionOrigin(context);
    await shareContent(origin: origin, text: text);
  },
);
