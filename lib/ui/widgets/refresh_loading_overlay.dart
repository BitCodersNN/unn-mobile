// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RefreshLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isRefreshing;
  final String semanticsLabel;

  const RefreshLoadingOverlay({
    required this.child,
    required this.isRefreshing,
    super.key,
    this.semanticsLabel = 'Обновление данных',
  });

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      child,
      if (isRefreshing)
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: switch (Theme.of(context).platform) {
                TargetPlatform.iOS || TargetPlatform.macOS => Semantics(
                  label: semanticsLabel,
                  child: const CupertinoActivityIndicator(),
                ),
                _ => RefreshProgressIndicator(semanticsLabel: semanticsLabel),
              },
            ),
          ),
        ),
    ],
  );
}
