// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class PlatformShareIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const PlatformShareIcon({this.size, this.color, super.key});

  @override
  Widget build(BuildContext context) => Icon(
    switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => Icons.ios_share_rounded,
      _ => Icons.share_outlined,
    },
    size: size,
    color: color,
  );
}
