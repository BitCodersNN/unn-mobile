// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class SearchBackdrop extends StatelessWidget {
  final bool visible;
  final VoidCallback? onDismiss;

  const SearchBackdrop({required this.visible, this.onDismiss, super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !visible || onDismiss == null,
    child: AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: ColoredBox(color: Colors.black.withAlpha(80)),
      ),
    ),
  );
}
