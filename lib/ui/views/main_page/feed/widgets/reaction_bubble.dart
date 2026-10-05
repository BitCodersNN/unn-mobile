// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class ReactionBubble extends StatelessWidget {
  final Function() onPressed;
  final bool isSelected;
  final String text;
  final Widget? icon;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderSide? borderSide;

  const ReactionBubble({
    required this.onPressed,
    required this.isSelected,
    required this.text,
    super.key,
    this.icon,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.backgroundColor,
    this.foregroundColor,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.fromBorderSide(
              borderSide ??
                  BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
            ),
            color: backgroundColor ??
                (isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surface),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 4.0, 8.0, 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    height: MediaQuery.of(context)
                        .textScaler
                        .clamp(maxScaleFactor: 1.3)
                        .scale(16),
                    child: icon,
                  ),
                ),
                Text(
                  text,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foregroundColor ??
                        (isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
