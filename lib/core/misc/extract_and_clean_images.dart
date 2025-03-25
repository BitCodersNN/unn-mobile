import 'package:html/parser.dart' as parser;

class ExtractAndCleanImagesMapKey {
  static const String cleanedText = 'cleanedText';
  static const String imageUrls = 'imageUrls';
}

Map<String, dynamic> extractAndCleanImages(String message) {
  final document = parser.parse(message);
  final imgTags = document.getElementsByTagName('img');
  final imageUrls = imgTags.map((img) => img.attributes['src']!).toList();

  for (final img in imgTags) {
    img.remove();
  }

  final cleanedMessage = document.body?.text ?? '';

  return {
    ExtractAndCleanImagesMapKey.cleanedText: cleanedMessage,
    ExtractAndCleanImagesMapKey.imageUrls:
        imageUrls.isNotEmpty ? imageUrls : null,
  };
}

String restoreMessage(
  String cleanedText,
  List<String>? imageUrls, {
  String additionalAttributes = 'style="max-height:500px;" alt="Image"',
}) {
  imageUrls ??= [];
  String restoredImages = '';

  for (final url in imageUrls) {
    restoredImages += '<img src="$url" $additionalAttributes>\n';
  }

  return '$cleanedText\n$restoredImages';
}
