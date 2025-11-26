// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:html_unescape/html_unescape.dart';

void _processNode(
  dom.Node node,
  StringBuffer buffer,
  Set<String> blockTags,
) {
  if (node is dom.Text) {
    final text = node.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isNotEmpty) {
      buffer.write('$text ');
    }
  } else if (node is dom.Element) {
    final tagName = node.localName?.toLowerCase();

    if (tagName == 'a') {
      final href = node.attributes['href'];
      if (href != null && href.trim().isNotEmpty) {
        buffer.write(href);
      } else {
        for (final child in node.nodes) {
          _processNode(child, buffer, blockTags);
        }
      }
    } else {
      for (final child in node.nodes) {
        _processNode(child, buffer, blockTags);
      }
    }

    if (blockTags.contains(tagName)) {
      buffer.write('\n');
    }
  }
}

String _getElementTextWithFormatting(dom.Element element) {
  final buffer = StringBuffer();
  final blockTags = {
    'br',
    'p',
    'div',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'li',
    'tr',
    'pre',
    'blockquote',
    'hr',
    'ul',
    'ol',
    'dl',
    'section',
    'article',
    'aside',
    'header',
    'footer',
    'main',
  };

  _processNode(element, buffer, blockTags);

  return buffer
      .toString()
      .replaceAll(RegExp(r'[ \t]*\n[ \t]*'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

String htmlToPlainText(String htmlText) {
  final unescaped = HtmlUnescape().convert(htmlText);
  final document = parser.parse(unescaped);
  final body = document.body;
  if (body != null) {
    return _getElementTextWithFormatting(body);
  }
  return '';
}
