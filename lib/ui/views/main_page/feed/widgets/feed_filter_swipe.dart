// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/feed/feed_filter.dart';
import 'package:unn_mobile/ui/widgets/swipe_pager.dart';

class FeedFilterSwipe extends StatefulWidget {
  final FeedFilter selected;
  final Future<FeedFilter> Function(FeedFilter) onSelected;
  final ValueChanged<FeedFilter>? onPreviewChanged;
  final Widget child;
  final Object? cacheKey;
  final bool enabled;
  final bool isChangingFilter;

  const FeedFilterSwipe({
    required this.selected,
    required this.onSelected,
    required this.child,
    this.onPreviewChanged,
    this.cacheKey,
    super.key,
    this.enabled = true,
    this.isChangingFilter = false,
  });

  @override
  State<FeedFilterSwipe> createState() => _FeedFilterSwipeState();
}

class _FeedFilterSwipeState extends State<FeedFilterSwipe> {
  final Map<FeedFilter, Widget> _contents = {};
  late FeedFilter _visibleFilter;

  @override
  void initState() {
    super.initState();
    _visibleFilter = widget.selected;
  }

  @override
  void didUpdateWidget(FeedFilterSwipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _visibleFilter = widget.selected;
    }
    if (oldWidget.cacheKey != widget.cacheKey) {
      _contents.clear();
    }
  }

  Future<int> _selectPage(int page) async {
    final selected = await widget.onSelected(FeedFilter.values[page]);
    if (mounted) {
      setState(() => _visibleFilter = selected);
      widget.onPreviewChanged?.call(selected);
    }
    return FeedFilter.values.indexOf(selected);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isChangingFilter || !_contents.containsKey(widget.selected)) {
      _contents[widget.selected] = widget.child;
    }
    return SwipePager(
      selectedPage: FeedFilter.values.indexOf(widget.selected),
      itemCount: FeedFilter.values.length,
      enabled: widget.enabled,
      onUserPageChanged: (page) {
        final filter = FeedFilter.values[page];
        setState(() => _visibleFilter = filter);
        widget.onPreviewChanged?.call(filter);
      },
      onUserPageSettled: _selectPage,
      itemBuilder: (context, page) {
        final filter = FeedFilter.values[page];
        return _FeedFilterPage(
          key: ValueKey(filter),
          child: TickerMode(
            enabled: filter == _visibleFilter,
            child: ExcludeFocus(
              excluding: filter != widget.selected,
              child: _contents[filter] ??
                  const Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
        );
      },
    );
  }
}

class _FeedFilterPage extends StatefulWidget {
  final Widget child;

  const _FeedFilterPage({required this.child, super.key});

  @override
  State<_FeedFilterPage> createState() => _FeedFilterPageState();
}

class _FeedFilterPageState extends State<_FeedFilterPage>
    with AutomaticKeepAliveClientMixin<_FeedFilterPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
