// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

({String cleanedText, List<String> imageUrls}) extractImagesAndCleanHtmlText(
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
  _removeScripts(body);

  final allImages = body.querySelectorAll('img');
  final imagesToRemove = <dom.Element>[];
  final imageUrls = <String>[];

  for (final img in allImages) {
    final style = img.attributes['style'];
    final width = _getImageSize(img, 'width', style);
    final height = _getImageSize(img, 'height', style);

    final isSmallWidth = width != null && width < minWidth;
    final isSmallHeight = height != null && height < minHeight;

    if (isSmallWidth && isSmallHeight) {
      continue;
    }

    final imageSource = img.attributes['src']?.trim();
    if (imageSource != null && imageSource.isNotEmpty) {
      imageUrls.add(imageSource);
      imagesToRemove.add(img);
    }
  }

  for (final img in imagesToRemove) {
    img.remove();
  }

  return _buildResult(
    body.innerHtml,
    imageUrls.isNotEmpty ? imageUrls : null,
  );
}

String restoreHtmlText(
  String cleanedHtmlText,
  List<String>? imageUrls, {
  String additionalAttributes = 'style="max-height:500px;" alt="Image"',
}) {
  imageUrls ??= [];
  final buffer = StringBuffer(cleanedHtmlText);

  if (imageUrls.isNotEmpty) {
    buffer.write('\n');
  }

  for (final url in imageUrls) {
    buffer.write('<img src="$url" $additionalAttributes>\n');
  }

  return buffer.toString();
}

void _removeDiskAttachDivs(dom.Element element) {
  final children = List<dom.Element>.from(element.children);

  for (final child in children) {
    if (child.parent != element) {
      continue;
    }

    final id = child.attributes['id'] ?? '';
    if (id.startsWith('disk-attach-')) {
      final prev = child.previousElementSibling;
      if (prev?.localName == 'br') {
        prev!.remove();
      }

      final next = child.nextElementSibling;
      if (next?.localName == 'br') {
        next!.remove();
      }

      child.remove();
    } else {
      _removeDiskAttachDivs(child);
    }
  }
}

void _removeScripts(dom.Element element) {
  final scripts = element.querySelectorAll('script');
  for (final script in scripts) {
    script.remove();
  }
}

int? _getImageSize(dom.Element img, String dimension, String? style) {
  var size = _parseSize(img.attributes[dimension]);

  if (size == null && style != null) {
    final regex = RegExp('$dimension\\s*:\\s*(\\d+)px', caseSensitive: false);
    final match = regex.firstMatch(style);
    if (match != null) {
      size = int.tryParse(match.group(1)!);
    }
  }
  return size;
}

int? _parseSize(String? value) {
  if (value == null) {
    return null;
  }
  final match = RegExp(r'^(\d+)').firstMatch(value.trim());
  return match != null ? int.tryParse(match.group(1)!) : null;
}

dom.Document? _parseHtmlSafely(String htmlText) {
  try {
    return parser.parse(htmlText);
  } catch (e) {
    return null;
  }
}

({String cleanedText, List<String> imageUrls}) _buildResult(
  String cleanedText,
  List<String>? imageUrls,
) =>
    (
      cleanedText: cleanedText,
      imageUrls: imageUrls ?? const [],
    );
