// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/mini_preview_primitives.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/preview_status_footer.dart';

class PreviewPage {
  final String title;
  final Widget child;

  const PreviewPage({required this.title, required this.child});
}

class PagedCategoryPreview extends StatefulWidget {
  final List<PreviewPage> pages;
  final String slotLabel;
  final Color slotColor;

  const PagedCategoryPreview({
    required this.pages,
    required this.slotLabel,
    required this.slotColor,
    super.key,
  });

  @override
  State<PagedCategoryPreview> createState() => _PagedCategoryPreviewState();
}

class _PagedCategoryPreviewState extends State<PagedCategoryPreview> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant PagedCategoryPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pages.isEmpty) {
      _currentPage = 0;
    } else if (_currentPage >= widget.pages.length) {
      _currentPage = widget.pages.length - 1;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int index) {
    if (widget.pages.isEmpty) {
      return;
    }
    final target = index.clamp(0, widget.pages.length - 1);
    _pageController.animateToPage(
      target,
      duration: MiniPreviewStyle.pageTransitionDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = widget.pages.length;
    final safePage = pageCount > 0 ? _currentPage.clamp(0, pageCount - 1) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (_currentPage != index) {
                setState(() => _currentPage = index);
              }
            },
            children: [for (final page in widget.pages) page.child],
          ),
        ),
        PreviewStatusFooter(
          slotLabel: widget.slotLabel,
          slotColor: widget.slotColor,
          pageTitle: pageCount > 0 ? widget.pages[safePage].title : null,
          pageCount: pageCount,
          currentPage: safePage,
          onPageTap: pageCount > 1 ? _animateToPage : null,
        ),
      ],
    );
  }
}
