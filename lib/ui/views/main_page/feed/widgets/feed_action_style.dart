// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

const feedActionBorderRadius = BorderRadius.all(Radius.circular(10));

Color feedReactionBackgroundColor(
  ColorScheme colors, {
  required bool isSelected,
}) =>
    isSelected
        ? colors.error.withValues(alpha: 0.08)
        : colors.surfaceContainerLow;
