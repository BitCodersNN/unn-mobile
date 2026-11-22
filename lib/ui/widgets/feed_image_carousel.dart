// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/image_page_counter.dart';
import 'package:unn_mobile/ui/widgets/image_viewer_screen.dart';

typedef FeedCarouselImageTapCallback = void Function(
  BuildContext context,
  int initialIndex,
  ValueChanged<int> onPageChanged,
);

class FeedImageCarousel extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final FeedCarouselImageTapCallback? onImageTap;
  final List<ImageProvider>? viewerImages;

  const FeedImageCarousel({
    required this.itemCount,
    required this.itemBuilder,
    this.onImageTap,
    this.viewerImages,
    super.key,
  });

  FeedImageCarousel.providers({required List<ImageProvider> images, super.key})
    : itemCount = images.length,
      viewerImages = List<ImageProvider>.unmodifiable(images),
      onImageTap = null,
      itemBuilder = ((_, index) =>
          _ProviderCarouselImage(image: images[index]));

  @override
  State<FeedImageCarousel> createState() => _FeedImageCarouselState();
}

class _FeedImageCarouselState extends State<FeedImageCarousel> {
  int _index = 0;
  final PageController _controller = PageController();

  @override
  void didUpdateWidget(FeedImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.itemCount) {
      _index = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncPage(int page) {
    if (mounted && _controller.hasClients) {
      _controller.jumpToPage(page);
    }
  }

  void _handleTap(BuildContext context, int index) {
    if (widget.onImageTap != null) {
      widget.onImageTap!(context, index, _syncPage);
      return;
    }
    final viewerImages = widget.viewerImages;
    if (viewerImages == null || viewerImages.isEmpty) {
      return;
    }
    triggerHaptic(HapticIntensity.light);
    unawaited(
      showImageViewer(
        context,
        images: viewerImages,
        initialIndex: index,
        onPageChanged: _syncPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: widget.itemCount,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _handleTap(context, index),
                    child: widget.itemBuilder(context, index),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: ImagePageCounter(
                    currentPage: _index + 1,
                    pageCount: widget.itemCount,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.itemCount > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              runSpacing: 5,
              children: List.generate(
                widget.itemCount,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 6,
                  width: index == _index ? 18 : 6,
                  decoration: BoxDecoration(
                    color: index == _index
                        ? colors.primary
                        : colors.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProviderCarouselImage extends StatelessWidget {
  final ImageProvider image;

  const _ProviderCarouselImage({required this.image});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Image(
      image: image,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return ColoredBox(
          color: colors.surfaceContainerHigh,
          child: const Center(
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, _, _) => ColoredBox(
        color: colors.surfaceContainerHigh,
        child: Icon(
          Icons.broken_image_outlined,
          color: colors.onSurfaceVariant,
          size: 32,
        ),
      ),
    );
  }
}
