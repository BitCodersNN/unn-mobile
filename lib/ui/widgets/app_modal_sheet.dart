// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) =>
    showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.94,
        child: builder(context),
      ),
    );

class AppModalSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? leading;
  final Widget? footer;
  final bool showCloseButton;

  const AppModalSheet({
    required this.child,
    this.title,
    this.leading,
    this.footer,
    this.showCloseButton = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          if (title != null || leading != null || showCloseButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title!,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    if (leading != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: leading,
                      ),
                    if (showCloseButton)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: 'Закрыть',
                          color: theme.colorScheme.onSurfaceVariant,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(child: child),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
