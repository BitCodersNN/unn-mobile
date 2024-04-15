import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/hex_color.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:unn_mobile/ui/widgets/spoiler_display.dart';

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
  TextStyle transformStyle(
    TextStyle oldStyle,
    Map<String, String>? attributes,
  ) {
    if (attributes?.entries.isEmpty ?? true) {
      return oldStyle;
    }
    String? size = attributes?.entries.first.key;
    if (size == null) {
      return oldStyle;
    }
    return oldStyle.copyWith(
      fontSize: double.tryParse(
        size.substring(0, size.length - 2),
      ),
    );
  }
}

class ColorTag extends StyleTag {
  ColorTag() : super("color");

  @override
  TextStyle transformStyle(
    TextStyle oldStyle,
    Map<String, String>? attributes,
  ) {
    if (attributes?.entries.isEmpty ?? true) {
      return oldStyle;
    }

    String? hexColor = attributes?.entries.first.key;
    if (hexColor == null) {
      return oldStyle;
    }
    return oldStyle.copyWith(color: ColorParser.fromHex(hexColor));
  }
}

class JustifyAlignTag extends WrappedStyleTag {
  JustifyAlignTag() : super("justify");

  @override
  List<InlineSpan> wrap(
    FlutterRenderer renderer,
    bbob.Element element,
    List<InlineSpan> spans,
  ) {
    return [
      WidgetSpan(
        child: SizedBox(
          width: double.infinity,
          child: RichText(
            text: TextSpan(children: spans),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
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
    if (url.startsWith("//")) {
      url = "https:$url";
    }
    renderer.pushTapAction(() {
      onTap?.call(url);
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
    TextStyle oldStyle,
    Map<String, String>? attributes,
  ) {
    return oldStyle.copyWith(
      decoration: TextDecoration.underline,
      color: Colors.blue,
    );
  }
}

class FontTag extends StyleTag {
  FontTag() : super("font");

  @override
  TextStyle transformStyle(
    TextStyle oldStyle,
    Map<String, String>? attributes,
  ) {
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
    FlutterRenderer renderer,
    bbob.Element element,
    List<InlineSpan> spans,
  ) {
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
                text: TextSpan(children: spans),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),
      )
    ];
  }
}

class DiskTag extends StyleTag {
  DiskTag() : super("disk");

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle;
  }
}

class TableTag extends WrappedStyleTag {
  TableTag() : super("table");

  @override
  List<InlineSpan> wrap(
    FlutterRenderer renderer,
    bbob.Element element,
    List<InlineSpan> spans,
  ) {
    if (spans.first.toPlainText() == "\n") {
      spans.removeAt(0);
    }
    if (spans.last.toPlainText() == "\n") {
      spans.removeLast();
    }

    return [
      WidgetSpan(
        child: Center(
          child: Column(
            children: [
              RichText(
                textWidthBasis: TextWidthBasis.longestLine,
                text: TextSpan(children: spans),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

class TRTag extends WrappedStyleTag {
  TRTag() : super("tr");

  @override
  List<InlineSpan> wrap(
    FlutterRenderer renderer,
    bbob.Element element,
    List<InlineSpan> spans,
  ) {
    return spans.map(
      (e) {
        return WidgetSpan(
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: e,
                textWidthBasis: TextWidthBasis.longestLine,
              ),
            ),
          ),
        );
      },
    ).toList();
  }
}

class TDTag extends StyleTag {
  TDTag() : super("td");

  @override
  TextStyle transformStyle(
    TextStyle oldStyle,
    Map<String, String>? attributes,
  ) {
    return oldStyle;
  }
}

class ImgTag extends AdvancedTag {
  ImgTag() : super("img");

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) {
      return [TextSpan(text: "[$tag]")];
    }

    final String imageUrl = element.children.first.textContent;
    double? width;
    double? height;
    const widthKey = "WIDTH";
    const heightKey = "HEIGHT";
    if (element.attributes.containsKey(widthKey)) {
      width = double.tryParse(element.attributes[widthKey]!);
    }
    if (element.attributes.containsKey(heightKey)) {
      height = double.tryParse(element.attributes[heightKey]!);
    }
    final image = Image.network(
      imageUrl,
      width: width,
      height: height,
      errorBuilder: (context, error, stack) => Text("[$tag]"),
    );

    if (renderer.peekTapAction() != null) {
      return [
        WidgetSpan(
          child: GestureDetector(
            onTap: renderer.peekTapAction(),
            child: image,
          ),
        ),
      ];
    }

    return [
      WidgetSpan(
        child: image,
      ),
    ];
  }
}

class SpoilerTag extends WrappedStyleTag {
  SpoilerTag() : super("spoiler");

  @override
  List<InlineSpan> wrap(
    FlutterRenderer renderer,
    bbob.Element element,
    List<InlineSpan> spans,
  ) {
    late String text;
    if (element.attributes.isNotEmpty) {
      text = "Spoiler: ${element.attributes.values.join(' ')}";
    } else {
      text = "Spoiler";
    }

    return [
      WidgetSpan(
        child: SpoilerDisplay(
          spoilerText: text,
          content: spans,
          selectable: renderer.stylesheet.selectableText,
        ),
      ),
    ];
  }
}

class UserTag extends StyleTag {
  UserTag() : super("user");

  @override
  TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle;
  }
}
