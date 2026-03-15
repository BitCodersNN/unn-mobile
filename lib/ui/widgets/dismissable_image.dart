// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class DismissibleImage extends StatelessWidget {
  final Map<String, String>? headers;
  const DismissibleImage({
    required this.image,
    this.headers,
    super.key,
  });

  final String image;

  @override
  Widget build(BuildContext context) => ExtendedImage(
        enableLoadState: true,
        mode: ExtendedImageMode.gesture,
        enableSlideOutPage: true,
        image: CachedNetworkImageProvider(
          image.startsWith('/') ? 'https://portal.unn.ru$image' : image,
          headers: headers,
        ),
        initGestureConfigHandler: (state) => GestureConfig(
          minScale: 0.9,
          animationMinScale: 0.7,
          maxScale: 3.0,
          animationMaxScale: 3.5,
          speed: 1.0,
          inertialSpeed: 100.0,
          initialScale: 1.0,
          inPageView: false,
          initialAlignment: InitialAlignment.center,
        ),
      );
}
