// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';

abstract interface class PaletteLinkPlatform {
  Future<String?> consumeInitialLink();
  void setOnLink(ValueChanged<String> onLink);
  void dispose();
}
