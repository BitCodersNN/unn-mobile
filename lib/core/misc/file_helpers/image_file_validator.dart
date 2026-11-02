// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';
import 'dart:ui' as ui;

Future<void> validateImageFile(File file) async {
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  try {
    final frame = await codec.getNextFrame();
    frame.image.dispose();
  } finally {
    codec.dispose();
  }
}
