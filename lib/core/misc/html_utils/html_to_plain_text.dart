// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';

void _processNodes(dom.Node node) {
  if (node is dom.Element) {
    if (node.localName == 'a') {
      final href = node.attributes['href'];
      if (href != null && href.isNotEmpty) {
        node.innerHtml = href;
      }
    }
    for (final child in node.children.toList()) {
      _processNodes(child);
    }
  }
}

String htmlToPlainText(String htmlText) {
  final unescaped = HtmlUnescape().convert(htmlText);
  final document = parse(unescaped);
  final body = document.body;
  if (body != null) {
    _processNodes(body);
  }
  return document.body?.text.trim() ?? '';
}
