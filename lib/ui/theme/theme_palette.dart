// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class ThemePalette<T extends Enum> {
  final T value;
  final String label;
  final ThemeData theme;

  const ThemePalette({
    required this.value,
    required this.label,
    required this.theme,
  });
}
