// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/core/misc/html_utils/portal_html_link.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/feed_image_viewer.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
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
        final link = href == null ? null : PortalHtmlLink.tryParse(href);
        if (link != null) {
          final url = link.uri.toString();
          return InlineCustomWidget(
            child: LinkContextMenu(
              url: url,
              label: text,
              onOpen: () => htmlWidgetOnTapUrl(url),
              onTap: () => _openLink(context, link),
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
        }
      }
      return null;
    },
  );

  void _openLink(BuildContext context, PortalHtmlLink link) {
    final userId = link.mentionedUserId;
    if (userId == null) {
      unawaited(
        Future<bool>.sync(() => htmlWidgetOnTapUrl(link.uri.toString())),
      );
      return;
    }
    final feedLocation = AppRouter.of(context).locationFor(MainPagePaths.feed);
    final profilePath = feedUserProfileRoute.pagePath.replaceFirst(
      ':userId',
      userId.toString(),
    );
    unawaited(context.push<void>('$feedLocation/$profilePath'));
  }
}
