// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/feed/feed_image_request.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/image_viewer_screen.dart';

Future<void> showFeedImages(
  BuildContext context, {
  required Iterable<String> images,
  Map<String, String>? headers,
  int initialIndex = 0,
  ValueChanged<int>? onPageChanged,
}) {
  if (images.isEmpty) {
    return Future<void>.value();
  }
  triggerHaptic(HapticIntensity.light);
  return showImageViewer(
    context,
    initialIndex: initialIndex,
    onPageChanged: onPageChanged,
    images: [
      for (final image in images)
        CachedNetworkImageProvider(
          feedImageUrl(image),
          headers: feedImageHeaders(feedImageUrl(image), headers),
        ),
    ],
  );
}
