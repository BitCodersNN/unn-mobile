// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_route_data.dart';

class ReorderableMenuList extends StatelessWidget {
  final List<MainPageRouteData> routes;
  final Widget header;
  final Widget Function(BuildContext, MainPageRouteData) itemBuilder;
  final void Function(int from, int to) onReorder;

  const ReorderableMenuList({
    required this.routes,
    required this.header,
    required this.itemBuilder,
    required this.onReorder,
    super.key,
  });

  Widget _item(BuildContext context, int index) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: Column(
        children: [
          itemBuilder(context, routes[index]),
          if (index < routes.length - 1)
            Divider(
              height: 1,
              thickness: 0.5,
              indent: 56,
              endIndent: 16,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          buildDefaultDragHandles: false,
          itemCount: routes.length,
          header: header,
          onReorderStart: (_) => triggerHaptic(HapticIntensity.medium),
          onReorderEnd: (_) => triggerHaptic(HapticIntensity.light),
          onReorderItem: onReorder,
          proxyDecorator: (child, index, animation) => AnimatedBuilder(
            animation: animation,
            builder: (context, _) => Material(
              color: theme.colorScheme.surfaceContainerLow,
              elevation: 6 * Curves.easeOutCubic.transform(animation.value),
              shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
              child: _item(context, index),
            ),
          ),
          itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
            key: ValueKey(routes[index].pagePath),
            index: index,
            child: Semantics(
              hint: 'Удерживайте, чтобы изменить порядок',
              child: Material(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(24) : Radius.zero,
                  bottom: index == routes.length - 1
                      ? const Radius.circular(24)
                      : Radius.zero,
                ),
                clipBehavior: Clip.antiAlias,
                child: _item(context, index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
