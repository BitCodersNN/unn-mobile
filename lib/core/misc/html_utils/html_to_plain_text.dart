import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';

String htmlToPlainText(String htmlText) {
  final unescaped = HtmlUnescape().convert(htmlText);
  final document = parse(unescaped);
  return document.body?.text ?? '';
}
