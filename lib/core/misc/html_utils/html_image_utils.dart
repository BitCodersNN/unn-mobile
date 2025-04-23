// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

class ExtractImagesAndCleanHtmlTextMapKey {
  static const String cleanedText = 'cleanedText';
  static const String imageUrls = 'imageUrls';
}

Map<String, dynamic> extractImagesAndCleanHtmlText(String htmlText) {
  final document = _parseHtmlSafely(htmlText);
  final body = document?.body;

  if (body == null) {
    return _buildResult(htmlText, null);
  }

  final nodes = body.nodes.toList();
  final trailingImages = <dom.Element>[];
  final imageUrls = <String>[];

  for (final node in nodes.reversed) {
    if (node is! dom.Element || node.localName != 'img') {
      if (node is dom.Text && node.text.trim().isEmpty) continue;
      break;
    }

    final imageSource = node.attributes['src']?.trim();
    if (imageSource == null || imageSource.isEmpty) continue;

    trailingImages.add(node);
    imageUrls.add(imageSource);
  }

  for (final img in trailingImages) {
    img.remove();
  }

  return _buildResult(
    body.innerHtml,
    imageUrls.isNotEmpty ? imageUrls.reversed.toList() : null,
  );
}

String restoreHtmlText(
  String cleanedHtmlText,
  List<String>? imageUrls, {
  String additionalAttributes = 'style="max-height:500px;" alt="Image"',
}) {
  imageUrls ??= [];
  final buffer = StringBuffer();

  if (imageUrls.isNotEmpty) {
    buffer.write('\n');
  }

  for (final url in imageUrls) {
    buffer.write('<img src="$url" $additionalAttributes>\n');
  }

  return '$cleanedHtmlText${buffer.toString()}';
}

dom.Document? _parseHtmlSafely(String htmlText) {
  try {
    return parser.parse(htmlText);
  } catch (e) {
    return null;
  }
}

Map<String, dynamic> _buildResult(String cleanedText, List<String>? imageUrls) {
  return {
    ExtractImagesAndCleanHtmlTextMapKey.cleanedText: cleanedText,
    ExtractImagesAndCleanHtmlTextMapKey.imageUrls: imageUrls,
  };
}
