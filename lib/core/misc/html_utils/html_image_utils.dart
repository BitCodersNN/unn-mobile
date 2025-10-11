// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

class ExtractImagesAndCleanHtmlTextMapKey {
  static const String cleanedText = 'cleanedText';
  static const String imageUrls = 'imageUrls';
}

Map<String, dynamic> extractImagesAndCleanHtmlText(
  String htmlText, {
  int minWidth = 32,
  int minHeight = 32,
}) {
  final document = _parseHtmlSafely(htmlText);
  final body = document?.body;

  if (body == null) {
    return _buildResult(htmlText, null);
  }

  _removeDiskAttachDivs(body);

  final nodes = body.nodes.toList();
  final trailingImages = <dom.Element>[];
  final imageUrls = <String>[];

  for (final node in nodes.reversed) {
    if (node is dom.Text && node.text.trim().isEmpty) {
      continue;
    }

    if (node is! dom.Element || node.localName != 'img') {
      break;
    }

    final widthStr = node.attributes['width'];
    final heightStr = node.attributes['height'];

    final width = widthStr == null ? null : int.tryParse(widthStr);
    final height = heightStr == null ? null : int.tryParse(heightStr);

    if (width != null && width < minWidth) continue;
    if (height != null && height < minHeight) continue;

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

void _removeDiskAttachDivs(dom.Element element) {
  final children = List<dom.Element>.from(element.children);

  for (final child in children) {
    if (child.parent != element) continue;

    final id = child.attributes['id'] ?? '';
    if (id.startsWith('disk-attach-')) {
      final prev = child.previousElementSibling;
      if (prev != null && prev.localName == 'br') {
        prev.remove();
      }

      final next = child.nextElementSibling;
      if (next != null && next.localName == 'br') {
        next.remove();
      }

      child.remove();
    } else {
      _removeDiskAttachDivs(child);
    }
  }
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
