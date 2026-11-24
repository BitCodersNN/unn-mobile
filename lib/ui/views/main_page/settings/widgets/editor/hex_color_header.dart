// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';

class HexColorHeader extends StatefulWidget {
  final String hex;
  final Color currentColor;
  final bool canReset;
  final FocusNode focusNode;
  final ValueChanged<String> onHexChanged;
  final VoidCallback onReset;

  const HexColorHeader({
    required this.hex,
    required this.currentColor,
    required this.canReset,
    required this.focusNode,
    required this.onHexChanged,
    required this.onReset,
    super.key,
  });

  @override
  State<HexColorHeader> createState() => _HexColorHeaderState();
}

class _HexColorHeaderState extends State<HexColorHeader> {
  static const double _controlSize = 42;
  static const double _hexFieldBorderRadius = _controlSize / 2;

  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(text: widget.hex);
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant HexColorHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
    if (widget.hex != oldWidget.hex &&
        (!widget.focusNode.hasFocus ||
            _normalizeHex(_hexController.text) != widget.hex.toUpperCase())) {
      _syncControllerText(widget.hex);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    _hexController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!widget.focusNode.hasFocus && _hexController.text != widget.hex) {
      _syncControllerText(widget.hex);
    }
  }

  void _syncControllerText(String value) {
    _hexController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _normalizeHex(String input) {
    final cleaned = input.trim().replaceFirst('#', '').toUpperCase();
    return '#$cleaned';
  }

  void _handleHexSubmitted(String value) {
    widget.onHexChanged(value);
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final outerRingColor = colors.onSurface.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.38 : 0.28,
    );

    return Row(
      children: [
        Container(
          width: _controlSize,
          height: _controlSize,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: outerRingColor, width: 1.5),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.currentColor,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: _controlSize,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(_hexFieldBorderRadius),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: _hexController,
              focusNode: widget.focusNode,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(7),
                FilteringTextInputFormatter.allow(
                  RegularExpressions.allowedHexCharsRegExp,
                ),
              ],
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                hintText: '#000000',
              ),
              onChanged: widget.onHexChanged,
              onSubmitted: _handleHexSubmitted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: _controlSize,
          height: _controlSize,
          child: IconButton.filledTonal(
            onPressed: widget.canReset ? widget.onReset : null,
            tooltip: 'Сбросить элемент',
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}
