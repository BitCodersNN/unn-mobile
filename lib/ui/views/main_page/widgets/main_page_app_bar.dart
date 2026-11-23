// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';

class MainPageTabScope extends InheritedNotifier<ValueListenable<bool>> {
  final String title;

  const MainPageTabScope({
    required this.title,
    required ValueListenable<bool>? showDate,
    required super.child,
    super.key,
  }) : super(notifier: showDate);

  static MainPageTabScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainPageTabScope>();

  bool get showDate => notifier?.value ?? false;

  @override
  bool updateShouldNotify(MainPageTabScope oldWidget) =>
      title != oldWidget.title || super.updateShouldNotify(oldWidget);
}

AppBar buildMainPageAppBar(
  BuildContext context, {
  required String title,
  Widget? leading,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
  Color? backgroundColor,
}) {
  final tab = MainPageTabScope.maybeOf(context);
  final showDate = tab?.showDate ?? false;
  final theme = Theme.of(context);
  final headlineStyle = theme.textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.w400,
  );
  final dateStyle = theme.textTheme.labelSmall?.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
  );
  final titleText = Text(
    tab?.title ?? title,
    style: headlineStyle,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
  final textScaler = MediaQuery.textScalerOf(context);
  final titleHeight =
      textScaler.scale(headlineStyle?.fontSize ?? 24) *
      (headlineStyle?.height ?? 1.33);
  final dateHeight = showDate
      ? textScaler.scale(dateStyle?.fontSize ?? 11) *
            (dateStyle?.height ?? 1.45)
      : 0.0;
  return AppBar(
    centerTitle: false,
    automaticallyImplyLeading: tab == null,
    titleSpacing: 16,
    backgroundColor: backgroundColor,
    forceMaterialTransparency: backgroundColor == null,
    scrolledUnderElevation: 0,
    toolbarHeight: math.max(kToolbarHeight, 12 + titleHeight + dateHeight),
    title: showDate
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTimeParser.format(
                  DateTime.now(),
                  DatePattern.eeeedMMMM,
                ).toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: dateStyle,
              ),
              titleText,
            ],
          )
        : titleText,
    leading: leading,
    actions: actions,
    bottom: bottom,
  );
}
