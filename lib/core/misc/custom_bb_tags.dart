import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:unn_mobile/core/misc/hex_color.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:bbob_dart/bbob_dart.dart' as bbob;

class PTag extends StyleTag {
  PTag() : super("p");

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle;
  }
}

class SizeTag extends StyleTag {
  SizeTag() : super("size");

  @override
  TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes) {
    if (attributes?.entries.isEmpty ?? true) {
      return oldStyle;
    }
    String? size = attributes?.entries.first.key;
    if(size == null) {
      return oldStyle;
    }
    return oldStyle.copyWith(fontSize: double.tryParse(size.substring(0, size.length - 2)));
  }

}

class NewColorTag extends StyleTag {
  NewColorTag() : super("color");
  
  @override
  TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes) {
    if (attributes?.entries.isEmpty ?? true) {
      return oldStyle;
    }

    String? hexColor = attributes?.entries.first.key;
    if (hexColor == null) return oldStyle;
    return oldStyle.copyWith(color: ColorParser.fromHex(hexColor));
  }
}

class JustifyAlignTag extends WrappedStyleTag {
  JustifyAlignTag() : super("justify");

  @override
  List<InlineSpan> wrap(
      FlutterRenderer renderer, bbob.Element element, List<InlineSpan> spans) {
    return [
      WidgetSpan(
          child: SizedBox(
            width: double.infinity,
              child: RichText(
                  text: TextSpan(children: spans), textAlign: TextAlign.justify)))
    ];
  }
}

class VideoTag extends StyleTag {
  final Function(String)? onTap;

  VideoTag({this.onTap}) : super("video");

  @override
  void onTagStart(FlutterRenderer renderer) {
    late String url;
    if (renderer.currentTag?.children.isNotEmpty ?? false) {
      url = renderer.currentTag!.children.first.textContent;
    } else {
      url = "URL is missing!";
    }
    if(url.startsWith("//")) {
      url = "https:$url";
    }
    renderer.pushTapAction(() {
      if (onTap == null) {
        return;
      }
      onTap!(url);
    });
    super.onTagStart(renderer);
  }

  @override
  void onTagEnd(FlutterRenderer renderer) {
    renderer.popTapAction();
    super.onTagEnd(renderer);
  }

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(
        decoration: TextDecoration.underline, color: Colors.blue);
  }
}

class FontTag extends StyleTag {
  FontTag() : super("font");

  @override
  TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes) {
    if (attributes?.entries.isEmpty ?? true) {
      return oldStyle;
    }
    String? font = attributes?.entries.first.key;
    return oldStyle.copyWith(fontFamily: font);
  }

}

class CodeTag extends WrappedStyleTag {
  CodeTag() : super("code");

  @override
  List<InlineSpan> wrap(
      FlutterRenderer renderer, bbob.Element element, List<InlineSpan> spans) {
    return [
      WidgetSpan(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black12,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                  child: RichText(
                      text: TextSpan(children: spans), textAlign: TextAlign.left,)),
            ),
          ))
    ];
  }
}

class DiskTag extends StyleTag {
  DiskTag() : super("disk");
  
  @override
  TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle;
  }
  
}
