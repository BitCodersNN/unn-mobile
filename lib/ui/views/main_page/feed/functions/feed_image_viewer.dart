import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/ui/widgets/image_viewer_sheet.dart';

String feedImageUrl(String image) => image.startsWith('/')
    ? '${ProtocolType.https.name}://${Host.unn}$image'
    : image;

Map<String, String> feedImageHeaders(
  String url,
  Map<String, String>? authorizationHeaders,
) {
  if (Uri.parse(url).host == Host.unn) {
    return authorizationHeaders ?? {};
  }
  return {
    'User-Agent': 'Mozilla/5.0',
    'Referer': Uri.parse(url).origin,
    'Accept':
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
  };
}

Future<void> showFeedImages(
  BuildContext context, {
  required Iterable<String> images,
  Map<String, String>? headers,
  int initialIndex = 0,
}) =>
    showImageViewerSheet(
      context,
      initialIndex: initialIndex,
      images: [
        for (final image in images)
          CachedNetworkImageProvider(
            feedImageUrl(image),
            headers: feedImageHeaders(feedImageUrl(image), headers),
          ),
      ],
    );
