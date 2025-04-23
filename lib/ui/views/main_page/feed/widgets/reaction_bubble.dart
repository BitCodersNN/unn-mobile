// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class ReactionBubble extends StatelessWidget {
  final Function() onPressed;
  final bool isSelected;
  final String text;
  final Widget? icon;

  const ReactionBubble({
    super.key,
    required this.onPressed,
    required this.isSelected,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
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
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
