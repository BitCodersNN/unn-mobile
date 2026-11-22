// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/feed/feed_image_request.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/feed_image_viewer.dart';
import 'package:unn_mobile/ui/widgets/feed_image_carousel.dart';

class PackedPostImages extends StatelessWidget {
  final Iterable<String> attachedImages;
  final Map<String, String> authorizationHeaders;

  const PackedPostImages({
    required this.attachedImages,
    required this.authorizationHeaders,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final images = attachedImages.toList();
    final colors = Theme.of(context).colorScheme;
    return FeedImageCarousel(
      itemCount: images.length,
      onImageTap: (context, index, onPageChanged) => unawaited(
        showFeedImages(
          context,
          images: images,
          initialIndex: index,
          onPageChanged: onPageChanged,
          headers: authorizationHeaders,
        ),
      ),
      itemBuilder: (context, index) {
        final imageUrl = feedImageUrl(images[index]);
        return CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: feedImageHeaders(imageUrl, authorizationHeaders),
          fit: BoxFit.cover,
          placeholder: (_, _) => ColoredBox(
            color: colors.surfaceContainerHigh,
            child: const Center(
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
          ),
          errorWidget: (_, _, _) => ColoredBox(
            color: colors.surfaceContainerHigh,
            child: Icon(
              Icons.broken_image_outlined,
              color: colors.onSurfaceVariant,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}
