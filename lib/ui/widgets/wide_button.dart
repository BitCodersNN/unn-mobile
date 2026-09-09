// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';
import 'package:flutter/material.dart';

class WideButton extends StatelessWidget {
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  const WideButton({
    required this.child,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryFixedDim,
              theme.primaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
