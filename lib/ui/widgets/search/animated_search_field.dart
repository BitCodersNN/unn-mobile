// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/search/search_controller.dart';
import 'package:unn_mobile/ui/widgets/search/search_field.dart';

class AnimatedSearchField<T> extends StatelessWidget {
  final AppSearchController<T> controller;
  final bool visible;
  final bool autofocus;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry padding;

  const AnimatedSearchField({
    required this.controller,
    required this.visible,
    this.autofocus = true,
    this.hintText = 'Поиск...',
    this.onSubmitted,
    this.onClear,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !visible,
    child: ExcludeFocus(
      excluding: !visible,
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: visible
            ? Padding(
                key: const ValueKey('search-field'),
                padding: padding,
                child: SearchField<T>(
                  controller: controller,
                  hintText: hintText,
                  onSubmitted: onSubmitted,
                  onClear: onClear,
                  autofocus: autofocus,
                ),
              )
            : const SizedBox(key: ValueKey('hidden-search-field')),
      ),
    ),
  );
}
