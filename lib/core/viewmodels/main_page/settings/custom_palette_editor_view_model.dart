// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

typedef PaletteThemeBuilder = ThemeData Function(
  CustomPaletteConfig config,
  Brightness brightness,
);
typedef PaletteSlotColorResolver = Color Function(
  ThemeData theme,
  PaletteColorSlot slot,
);

class CustomPaletteEditorViewModel extends BaseViewModel {
  final CustomPaletteConfig _initialConfig;
  final Brightness brightness;
  final PaletteThemeBuilder _themeBuilder;
  final PaletteSlotColorResolver _slotColorResolver;

  CustomPaletteConfig _config;
  PaletteCategory _selectedCategory = PaletteCategory.base;
  PaletteColorSlot _selectedSlot = PaletteColorSlot.surface;
  ThemeData? _cachedPreviewTheme;
  late HSVColor _currentHsv;

  CustomPaletteEditorViewModel({
    required CustomPaletteConfig initialConfig,
    required this.brightness,
    required this._themeBuilder,
    required this._slotColorResolver,
  }) : _initialConfig = initialConfig,
       _config = initialConfig {
    _currentHsv = HSVColor.fromColor(currentColor);
  }

  CustomPaletteConfig get config => _config;

  PaletteCategory get selectedCategory => _selectedCategory;

  PaletteColorSlot get selectedSlot => _selectedSlot;

  List<PaletteColorSlot> get slotsForSelectedCategory => PaletteColorSlot.values
      .where((slot) => slot.category == _selectedCategory)
      .toList(growable: false);

  ThemeData get previewTheme =>
      _cachedPreviewTheme ??= _themeBuilder(_config, brightness);

  Color colorForSlot(PaletteColorSlot slot) =>
      _slotColorResolver(previewTheme, slot);

  Color get currentColor => colorForSlot(_selectedSlot);

  HSVColor get currentHsv => _currentHsv;

  String get currentHex {
    final hex = (currentColor.toARGB32() & 0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
    return '#$hex';
  }

  bool get isCurrentSlotCustomized => _config.isCustomized(_selectedSlot);

  bool isSlotCustomized(PaletteColorSlot slot) => _config.isCustomized(slot);

  bool get hasChanges => _config != _initialConfig;

  void selectCategory(PaletteCategory category) {
    _selectedCategory = category;
    _selectedSlot = PaletteColorSlot.values.firstWhere(
      (slot) => slot.category == category,
    );
    _syncHsvFromCurrentColor();
    notifyListeners();
  }

  void selectSlot(PaletteColorSlot slot) {
    _selectedSlot = slot;
    _selectedCategory = slot.category;
    _syncHsvFromCurrentColor();
    notifyListeners();
  }

  void selectSlotInCurrentCategory(PaletteColorSlot slot) {
    if (slot.category == _selectedCategory) {
      selectSlot(slot);
    }
  }

  void updateHueSaturation(double hue, double saturation) {
    _currentHsv = _currentHsv
        .withHue(hue.clamp(0.0, 360.0))
        .withSaturation(saturation.clamp(0.0, 1.0));
    _applyCurrentHsvColor();
  }

  void updateValue(double value) {
    _currentHsv = _currentHsv.withValue(value.clamp(0.0, 1.0));
    _applyCurrentHsvColor();
  }

  bool updateHex(String input) {
    final match = RegularExpressions.hexColor6RegExp.firstMatch(input.trim());
    if (match == null) {
      return false;
    }
    final rgb = int.parse(match.group(1)!, radix: 16);
    _config = _config.withSlotColor(_selectedSlot, Color(0xFF000000 | rgb));
    _cachedPreviewTheme = null;
    _syncHsvFromCurrentColor();
    notifyListeners();
    return true;
  }

  void resetCurrentSlot() {
    if (_selectedSlot.isBaseAccent) {
      final defaults = _defaultConfig();
      final defaultColor = _selectedSlot == PaletteColorSlot.primary
          ? defaults.primary
          : defaults.secondary;
      _config = _config.withSlotColor(_selectedSlot, defaultColor);
    } else {
      _config = _config.clearSlot(_selectedSlot);
    }
    _cachedPreviewTheme = null;
    _syncHsvFromCurrentColor();
    notifyListeners();
  }

  void applyPreset(CustomPaletteConfig presetConfig) {
    _config = presetConfig;
    _cachedPreviewTheme = null;
    _syncHsvFromCurrentColor();
    notifyListeners();
  }

  void resetAll() {
    _config = _defaultConfig();
    _cachedPreviewTheme = null;
    _syncHsvFromCurrentColor();
    notifyListeners();
  }

  void _applyCurrentHsvColor() {
    _config = _config.withSlotColor(_selectedSlot, _currentHsv.toColor());
    _cachedPreviewTheme = null;
    notifyListeners();
  }

  void _syncHsvFromCurrentColor() {
    _currentHsv = HSVColor.fromColor(currentColor);
  }

  CustomPaletteConfig _defaultConfig() => brightness == Brightness.dark
      ? CustomPaletteConfig.defaultDark()
      : CustomPaletteConfig.defaultLight();
}
