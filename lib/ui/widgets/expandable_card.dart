// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';

class ExpandableCard extends StatefulWidget {
  final Widget title;
  final Widget? trailing;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final ShapeBorder? shape;
  final HapticIntensity hapticIntensity;
  final CrossAxisAlignment headerCrossAxisAlignment;
  final double chevronSize;
  final double chevronSpacing;
  final bool showTapHighlight;

  const ExpandableCard({
    required this.title,
    required this.child,
    this.trailing,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.shape,
    this.hapticIntensity = HapticIntensity.selection,
    this.headerCrossAxisAlignment = CrossAxisAlignment.center,
    this.chevronSize = 22,
    this.chevronSpacing = 12,
    this.showTapHighlight = false,
    super.key,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() {
    triggerHaptic(widget.hapticIntensity);
    setState(() => _expanded = !_expanded);
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 250);
    return Material(
      color: colors.surfaceContainerLowest,
      shape:
          widget.shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              onTap: _toggle,
              splashFactory: widget.showTapHighlight
                  ? null
                  : NoSplash.splashFactory,
              highlightColor: widget.showTapHighlight
                  ? null
                  : Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: widget.headerCrossAxisAlignment,
                  children: [
                    Expanded(child: widget.title),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 12),
                      widget.trailing!,
                    ],
                    SizedBox(width: widget.chevronSpacing),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: duration,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.onSurfaceVariant,
                        size: widget.chevronSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            alignment: Alignment.topCenter,
            duration: duration,
            curve: Curves.easeInOutCubic,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
