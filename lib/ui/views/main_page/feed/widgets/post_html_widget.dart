// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/ui/widgets/dismissable_image.dart';

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
              child: DismissibleImage(image: imageMetadata.sources.first.url),
            );
          },
        );
      },
    );
  }
}
