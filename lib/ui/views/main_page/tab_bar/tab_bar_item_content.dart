// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:unn_mobile/ui/views/main_page/tab_bar/tab_bar_label_layout.dart';

class TabBarItemContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final TextStyle? labelStyle;

  const TabBarItemContent({
    required this.icon,
    required this.label,
    this.color,
    this.labelStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final layout = TabBarLabelLayout.maybeOf(context);
    final style = (layout?.style ??
            CupertinoTheme.of(context).textTheme.tabLabelTextStyle)
        .merge(labelStyle)
        .copyWith(
          fontSize: layout?.style.fontSize,
          color: labelStyle?.color ??
              color ??
              DefaultTextStyle.of(context).style.color,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        SizedBox(
          height: TabBarLabelLayout.labelHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TabBarLabelLayout.horizontalLabelPadding,
            ),
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              textScaler: layout?.scaler,
              style: style,
            ),
          ),
        ),
      ],
    );
  }
}
