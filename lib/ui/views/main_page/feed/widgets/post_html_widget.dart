// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';

class PostHtmlWidget extends StatelessWidget {
  const PostHtmlWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      text,
      onTapUrl: htmlWidgetOnTapUrl,
      onTapImage: (imageMetadata) async {
        await showDialog(
          context: context,
          builder: (context) {
            return ExtendedImageSlidePage(
              slideAxis: SlideAxis.vertical,
              child: ExtendedImage(
                enableLoadState: true,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    minScale: 0.9,
                    animationMinScale: 0.7,
                    maxScale: 3.0,
                    animationMaxScale: 3.5,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: false,
                    initialAlignment: InitialAlignment.center,
                  );
                },
                image: CachedNetworkImageProvider(
                  imageMetadata.sources.first.url,
                ),
                enableSlideOutPage: true,
              ),
            );
          },
        );
      },
    );
  }
}
