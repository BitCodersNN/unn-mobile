// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';

class SwipePager extends StatefulWidget {
  final int selectedPage;
  final IndexedWidgetBuilder itemBuilder;
  final int? itemCount;
  final bool enabled;
  final ValueChanged<int>? onUserPageChanged;
  final Future<int> Function(int)? onUserPageSettled;

  const SwipePager({
    required this.selectedPage,
    required this.itemBuilder,
    this.itemCount,
    this.enabled = true,
    this.onUserPageChanged,
    this.onUserPageSettled,
    super.key,
  });

  @override
  State<SwipePager> createState() => _SwipePagerState();
}

class _SwipePagerState extends State<SwipePager> {
  late final PageController _pages;
  late int _currentPage;
  int? _programmaticPage;
  int _animationRevision = 0;
  bool _isSelecting = false;
  bool _userScroll = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.selectedPage;
    _pages = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(SwipePager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPage != widget.selectedPage &&
        !_isSelecting &&
        (widget.selectedPage != _currentPage || _programmaticPage != null)) {
      unawaited(_showPage(widget.selectedPage));
    }
  }

  Future<void> _showPage(int page) async {
    if (!_pages.hasClients) {
      return;
    }
    final revision = ++_animationRevision;
    _userScroll = false;
    if (_pages.page == page.toDouble()) {
      if (_programmaticPage != null) {
        _pages.jumpToPage(page);
        setState(() => _programmaticPage = null);
      }
      return;
    }
    setState(() => _programmaticPage = page);
    await _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    if (mounted && revision == _animationRevision) {
      setState(() => _programmaticPage = null);
    }
  }

  void _onPageChanged(int page) {
    _currentPage = page;
    if (_programmaticPage == null && !_isSelecting) {
      widget.onUserPageChanged?.call(page);
    }
  }

  Future<void> _selectPage() async {
    final onSettled = widget.onUserPageSettled;
    if (onSettled == null || _isSelecting || _programmaticPage != null) {
      return;
    }
    if (!widget.enabled) {
      await _showPage(widget.selectedPage);
      return;
    }
    if (_currentPage == widget.selectedPage) {
      return;
    }
    setState(() => _isSelecting = true);
    try {
      await _applySelection(onSettled);
    } finally {
      if (mounted) {
        setState(() => _isSelecting = false);
      }
    }
  }

  Future<void> _applySelection(Future<int> Function(int) onSettled) async {
    final selected = await onSettled(_currentPage);
    if (mounted) {
      await _showPage(selected);
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.horizontal) {
      return false;
    }
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _userScroll = true;
    }
    if (notification is ScrollEndNotification && _userScroll) {
      _userScroll = false;
      if (widget.onUserPageSettled != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              _pages.hasClients &&
              !_pages.position.isScrollingNotifier.value) {
            unawaited(_selectPage());
          }
        });
      }
    }
    return false;
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: PageView.builder(
          controller: _pages,
          itemCount: widget.itemCount,
          physics: widget.enabled && !_isSelecting && _programmaticPage == null
              ? null
              : const NeverScrollableScrollPhysics(),
          onPageChanged: _onPageChanged,
          itemBuilder: widget.itemBuilder,
        ),
      );
}
