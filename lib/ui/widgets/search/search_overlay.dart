// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/search/search_controller.dart';

typedef SuggestionBuilder<T> = Widget Function(
  BuildContext context,
  T suggestion,
  String query,
  VoidCallback onTap,
);

class SearchOverlay<T> extends StatelessWidget {
  final AppSearchController<T> controller;

  final Widget Function(BuildContext, Object?, String, VoidCallback) _builder;

  final Widget? emptyState;
  final Widget? loadingState;

  SearchOverlay({
    required this.controller,
    required SuggestionBuilder<T> suggestionBuilder,
    this.emptyState,
    this.loadingState,
    super.key,
  }) : _builder = _wrapBuilder(suggestionBuilder);

  static Widget Function(BuildContext, Object?, String, VoidCallback)
      _wrapBuilder<S>(SuggestionBuilder<S> builder) => (
            BuildContext ctx,
            Object? s,
            String q,
            VoidCallback tap,
          ) =>
              builder(ctx, s as S, q, tap);

  @override
  Widget build(BuildContext context) {
    if (!controller.isOpen) {
      return const SizedBox.shrink();
    }

    final hasSuggestions = controller.suggestions.isNotEmpty;
    final isQueryEmpty = controller.query.isEmpty;

    if (!hasSuggestions && controller.isLoading) {
      return const SizedBox.shrink();
    }

    if (!hasSuggestions && isQueryEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      bottom: 8,
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: Material(
              color: theme.colorScheme.surface,
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: controller.isLoading
                  ? (loadingState ??
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ))
                  : hasSuggestions
                      ? ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: controller.suggestions.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 1,
                            color: theme.dividerColor.withAlpha(51),
                          ),
                          itemBuilder: (context, index) {
                            final suggestion = controller.suggestions[index];
                            return _builder(
                              context,
                              suggestion,
                              controller.query,
                              () => controller.applySuggestion(suggestion),
                            );
                          },
                        )
                      : (emptyState ??
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Ничего не найдено',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )),
            ),
          ),
        ),
      ),
    );
  }
}
