// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/ui/widgets/link_action.dart';

class LinkifiedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const LinkifiedText({required this.text, this.style, super.key});

  String _html() {
    const escape = HtmlEscape();
    final result = StringBuffer();
    int offset = 0;
    for (final match in RegularExpressions.plainTextUrlRegExp.allMatches(
      text,
    )) {
      String url = match.group(0)!;
      while (url.isNotEmpty && '.,!?;:'.contains(url[url.length - 1])) {
        url = url.substring(0, url.length - 1);
      }
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host.isEmpty) {
        continue;
      }
      result
        ..write(escape.convert(text.substring(offset, match.start)))
        ..write('<a href="${escape.convert(url)}">${escape.convert(url)}</a>');
      offset = match.start + url.length;
    }
    result.write(escape.convert(text.substring(offset)));
    return result.toString().replaceAll('\n', '<br>');
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = (style ?? Theme.of(context).textTheme.bodyMedium)
        ?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: Theme.of(context).colorScheme.primary,
        );
    return SelectionArea(
      child: HtmlWidget(
        _html(),
        textStyle: style,
        customWidgetBuilder: (element) {
          final url = element.attributes['href'];
          if (element.localName != 'a' || url == null) {
            return null;
          }
          return InlineCustomWidget(
            child: LinkAction(
              url: url,
              label: element.text,
              child: Text(element.text, style: linkStyle),
            ),
          );
        },
      ),
    );
  }
}
