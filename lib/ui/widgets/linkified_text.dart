// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/ui/widgets/context_menu/link_context_menu.dart';

class LinkifiedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool selectable;

  const LinkifiedText({
    required this.text,
    this.style,
    this.selectable = true,
    super.key,
  });

  String _html() {
    const escape = HtmlEscape();
    final result = StringBuffer();
    int offset = 0;
    for (final match in RegularExpressions.plainTextUrlRegExp.allMatches(
      text,
    )) {
      final label = _trimUrl(match.group(0)!);
      final uri = Uri.tryParse(label);
      if (uri == null) {
        continue;
      }
      final url = uri.hasScheme
          ? uri
          : Uri.tryParse('${ProtocolType.https.name}://$label');
      if (url == null || url.host.isEmpty) {
        continue;
      }
      result
        ..write(escape.convert(text.substring(offset, match.start)))
        ..write(
          '<a href="${escape.convert(url.toString())}">${escape.convert(label)}</a>',
        );
      offset = match.start + label.length;
    }
    result.write(escape.convert(text.substring(offset)));
    return result.toString().replaceAll('\n', '<br>');
  }

  static String _trimUrl(String url) {
    String result = url;
    const brackets = {')': '(', ']': '[', '}': '{'};
    while (result.isNotEmpty) {
      final last = result[result.length - 1];
      final opening = brackets[last];
      if ('.,!?;:'.contains(last) ||
          (opening != null &&
              result.split(last).length > result.split(opening).length)) {
        result = result.substring(0, result.length - 1);
      } else {
        break;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final linkStyle = (style ?? Theme.of(context).textTheme.bodyMedium)
        ?.copyWith(
          color: color,
          decoration: TextDecoration.underline,
          decorationColor: color,
        );
    final content = HtmlWidget(
      _html(),
      textStyle: style,
      customWidgetBuilder: (element) {
        final url = element.attributes['href'];
        if (element.localName != 'a' || url == null) {
          return null;
        }
        return InlineCustomWidget(
          child: LinkContextMenu(
            url: url,
            label: element.text,
            onOpen: () => htmlWidgetOnTapUrl(url),
            child: Text(element.text, style: linkStyle),
          ),
        );
      },
    );
    return selectable ? SelectionArea(child: content) : content;
  }
}
