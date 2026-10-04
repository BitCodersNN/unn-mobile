// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/feed_image_viewer.dart';
import 'package:unn_mobile/ui/widgets/context_menu/link_context_menu.dart';

class TextHtmlWidget extends StatelessWidget {
  final Map<String, String>? headers;
  const TextHtmlWidget({required this.text, this.headers, super.key});
  final String text;

  @override
  Widget build(BuildContext context) => HtmlWidget(
        text,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
        onTapUrl: htmlWidgetOnTapUrl,
        onTapImage: (imageMetadata) => showFeedImages(
          context,
          images: [imageMetadata.sources.first.url],
          headers: headers,
        ),
        customWidgetBuilder: (element) {
          if (element.localName == 'a') {
            final href = element.attributes['href'];
            final text = element.text;
            if (href != null) {
              return LinkContextMenu(
                url: href,
                label: text,
                onOpen: () => htmlWidgetOnTapUrl(href),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              );
            }
          }
          return null;
        },
      );
}
