
import 'package:flutter/src/painting/text_style.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

class PTag extends StyleTag {
  PTag() : super("p");

  @override
  TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle;
  }

}
