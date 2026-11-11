// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/constants/api/user_agents.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/image_viewer_screen.dart';

String feedImageUrl(String image) => image.startsWith('/')
    ? '${ProtocolType.https.name}://${Host.unn}$image'
    : image;

Map<String, String> feedImageHeaders(
  String url,
  Map<String, String>? authorizationHeaders,
) {
  final uri = Uri.parse(url);
  if (uri.host == Host.unn) {
    return authorizationHeaders ?? {};
  }
  return {
    'User-Agent': UserAgents.browser,
    'Referer': uri.origin,
    'Accept':
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
  };
}

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
