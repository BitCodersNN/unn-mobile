// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/feed_image_viewer.dart';
import 'package:unn_mobile/ui/widgets/image_page_counter.dart';

class PackedPostImages extends StatefulWidget {
  const PackedPostImages({
    required this.attachedImages,
    required this.authorizationHeaders,
    super.key,
  });

  final Iterable<String> attachedImages;
  final Map<String, String> authorizationHeaders;

  @override
  State<PackedPostImages> createState() => _PackedPostImagesState();
}

class _PackedPostImagesState extends State<PackedPostImages> {
  int _index = 0;
  final PageController _controller = PageController();

  @override
  void didUpdateWidget(PackedPostImages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.attachedImages.length) {
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

  @override
  Widget build(BuildContext context) {
    final images = widget.attachedImages.toList();
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).colorScheme;
    return Column(
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
                  itemCount: images.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) {
                    final imageUrl = feedImageUrl(images[index]);
                    return GestureDetector(
                      onTap: () => showFeedImages(
                        context,
                        images: images,
                        initialIndex: index,
                        headers: widget.authorizationHeaders,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        httpHeaders: feedImageHeaders(
                          imageUrl,
                          widget.authorizationHeaders,
                        ),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => ColoredBox(
                          color: colors.surfaceContainerHigh,
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => ColoredBox(
                          color: colors.surfaceContainerHigh,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: colors.onSurfaceVariant,
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: ImagePageCounter(
                    currentPage: _index + 1,
                    pageCount: images.length,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              runSpacing: 5,
              children: List.generate(
                images.length,
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
