// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class ModeTabBar extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<int>? onSelected;
  final bool isScrollable;
  final TabBarIndicatorSize? indicatorSize;
  final TabController? controller;

  const ModeTabBar({
    required this.labels,
    this.onSelected,
    this.isScrollable = true,
    this.indicatorSize,
    this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TabBar(
    controller: controller,
    tabAlignment: isScrollable ? TabAlignment.center : TabAlignment.fill,
    isScrollable: isScrollable,
    indicatorSize: indicatorSize,
    tabs: [for (final label in labels) Tab(text: label)],
    onTap: onSelected,
  );
}
