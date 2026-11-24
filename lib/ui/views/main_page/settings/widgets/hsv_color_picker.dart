// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/editor/hex_color_header.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/editor/hsv_spectrum_panel.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/editor/hsv_value_slider.dart';

class HsvColorPicker extends StatefulWidget {
  final HSVColor hsv;
  final String hex;
  final Color currentColor;
  final bool canReset;
  final void Function(double hue, double saturation) onHueSaturationChanged;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<String> onHexChanged;
  final VoidCallback onReset;

  const HsvColorPicker({
    required this.hsv,
    required this.hex,
    required this.currentColor,
    required this.canReset,
    required this.onHueSaturationChanged,
    required this.onValueChanged,
    required this.onHexChanged,
    required this.onReset,
    super.key,
  });

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  late final FocusNode _hexFocusNode;

  @override
  void initState() {
    super.initState();
    _hexFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _hexFocusNode.dispose();
    super.dispose();
  }

  void _unfocusIfNeeded() {
    if (_hexFocusNode.hasFocus) {
      _hexFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      HexColorHeader(
        hex: widget.hex,
        currentColor: widget.currentColor,
        canReset: widget.canReset,
        focusNode: _hexFocusNode,
        onHexChanged: widget.onHexChanged,
        onReset: () {
          _unfocusIfNeeded();
          widget.onReset();
        },
      ),
      const SizedBox(height: 14),
      HsvSpectrumPanel(
        hsv: widget.hsv,
        onInteractionStart: _unfocusIfNeeded,
        onChanged: widget.onHueSaturationChanged,
      ),
      const SizedBox(height: 14),
      HsvValueSlider(
        hsv: widget.hsv,
        onInteractionStart: _unfocusIfNeeded,
        onChanged: widget.onValueChanged,
      ),
    ],
  );
}
