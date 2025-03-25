import 'package:html/parser.dart' as parser;

class ExtractImagesAndCleanHtmlTextMapKey {
  static const String cleanedText = 'cleanedText';
  static const String imageUrls = 'imageUrls';
}

Map<String, dynamic> extractImagesAndCleanHtmlText(String htmlText) {
  final document = parser.parse(htmlText);
  final imgTags = document.getElementsByTagName('img');
  final imageUrls = imgTags.map((img) => img.attributes['src']!).toList();

  for (final img in imgTags) {
    img.remove();
  }

  final cleanedMessage = document.body?.text ?? '';

  return {
    ExtractImagesAndCleanHtmlTextMapKey.cleanedText: cleanedMessage,
    ExtractImagesAndCleanHtmlTextMapKey.imageUrls:
        imageUrls.isNotEmpty ? imageUrls : null,
  };
}

String restoreHtmlText(
  String cleanedHtmlText,
  List<String>? imageUrls, {
  String additionalAttributes = 'style="max-height:500px;" alt="Image"',
}) {
  imageUrls ??= [];
  String restoredImages = '';

  for (final url in imageUrls) {
    restoredImages += '<img src="$url" $additionalAttributes>\n';
  }

  return '$cleanedHtmlText\n$restoredImages';
}
