// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';

const double _toolbarVerticalPadding = 12;
const double _titleSpacing = 16;
const double _defaultHeadlineFontSize = 24;
const double _defaultHeadlineLineHeight = 1.33;
const double _defaultDateFontSize = 11;
const double _defaultDateLineHeight = 1.45;

class MainPageTabScope extends InheritedNotifier<ValueListenable<bool>> {
  final String title;

  const MainPageTabScope({
    required this.title,
    required ValueListenable<bool> showDate,
    required super.child,
    super.key,
  }) : super(notifier: showDate);

  static MainPageTabScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainPageTabScope>();

  bool get showDate => notifier!.value;

  @override
  bool updateShouldNotify(MainPageTabScope oldWidget) =>
      title != oldWidget.title || super.updateShouldNotify(oldWidget);
}

class _MainPageAppBarTitle extends StatelessWidget {
  final String title;
  final bool showDate;
  final TextStyle? headlineStyle;
  final TextStyle? dateStyle;

  const _MainPageAppBarTitle({
    required this.title,
    required this.showDate,
    required this.headlineStyle,
    required this.dateStyle,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: headlineStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (!showDate) {
      return titleText;
    }
    return Column(
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
    );
  }
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
  final textScaler = MediaQuery.textScalerOf(context);
  final titleHeight =
      textScaler.scale(headlineStyle?.fontSize ?? _defaultHeadlineFontSize) *
      (headlineStyle?.height ?? _defaultHeadlineLineHeight);
  final dateHeight = showDate
      ? textScaler.scale(dateStyle?.fontSize ?? _defaultDateFontSize) *
            (dateStyle?.height ?? _defaultDateLineHeight)
      : 0.0;
  return AppBar(
    centerTitle: false,
    automaticallyImplyLeading: tab == null,
    titleSpacing: _titleSpacing,
    backgroundColor: backgroundColor,
    forceMaterialTransparency: backgroundColor == null,
    scrolledUnderElevation: 0,
    toolbarHeight: math.max(
      kToolbarHeight,
      _toolbarVerticalPadding + titleHeight + dateHeight,
    ),
    title: _MainPageAppBarTitle(
      title: tab?.title ?? title,
      showDate: showDate,
      headlineStyle: headlineStyle,
      dateStyle: dateStyle,
    ),
    leading: leading,
    actions: actions,
    bottom: bottom,
  );
}
