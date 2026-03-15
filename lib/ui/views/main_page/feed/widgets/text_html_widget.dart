// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_factory.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_helper.dart';
import 'package:unn_mobile/ui/widgets/dismissable_image.dart';

class TextHtmlWidget extends StatelessWidget {
  final Map<String, String>? headers;
  const TextHtmlWidget({required this.text, this.headers, super.key});
  final String text;

  @override
  Widget build(BuildContext context) => HtmlWidget(
        text,
        onTapUrl: htmlWidgetOnTapUrl,
        onTapImage: (imageMetadata) async {
          await showDialog(
            context: context,
            builder: (context) => ExtendedImageSlidePage(
              slideAxis: SlideAxis.vertical,
              child: DismissibleImage(
                image: imageMetadata.sources.first.url,
                headers: headers,
              ),
            ),
          );
        },
        customWidgetBuilder: (element) {
          if (element.localName == 'a') {
            final href = element.attributes['href'];
            final text = element.text;
            if (href != null) {
              return Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => htmlWidgetOnTapUrl(href),
                  onLongPress: () => ContextMenuHelper.showContextMenu(
                    context: ctx,
                    model: href,
                    actionsBuilder: () => createLinkActions(
                      context: ctx,
                      url: href,
                      onOpen: () => htmlWidgetOnTapUrl(href),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.primary,
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
}
