// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class AuthErrorText extends StatelessWidget {
  final String? text;
  final String? boldPrefix;
  final double reservedHeight;
  final EdgeInsets contentPadding;

  const AuthErrorText({
    this.text,
    this.boldPrefix,
    this.reservedHeight = 28,
    this.contentPadding = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final errorText = text;
    final style = TextStyle(
      fontFamily: 'Inter',
      fontSize: 15,
      color: Theme.of(context).colorScheme.error,
    );

    return AnimatedSize(
      duration: _duration,
      curve: _curve,
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: reservedHeight),
        child: AnimatedSwitcher(
          duration: _duration,
          switchInCurve: _curve,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: errorText == null || errorText.isEmpty
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : Padding(
                  key: ValueKey('$boldPrefix$errorText'),
                  padding: contentPadding,
                  child: Text.rich(
                    TextSpan(
                      style: style,
                      children: [
                        if (boldPrefix != null)
                          TextSpan(
                            text: boldPrefix,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        TextSpan(text: errorText),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  static const Duration _duration = Duration(milliseconds: 250);
  static const Curve _curve = Curves.easeOutCubic;
}
