// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class SpoilerDisplay extends StatefulWidget {
  final String spoilerText;
  final List<InlineSpan> content;
  final double elevation;
  final bool selectable;

  const SpoilerDisplay({
    super.key,
    required this.spoilerText,
    required this.content,
    this.elevation = 2,
    this.selectable = true,
  });

  @override
  State<SpoilerDisplay> createState() => _SpoilerDisplayState();
}

class _SpoilerDisplayState extends State<SpoilerDisplay> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: theme.highlightColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _open = !_open;
              });
            },
            child: _open
                ? widget.selectable
                    ? SelectableText.rich(
                        TextSpan(children: widget.content),
                        onTap: () {
                          setState(() {
                            _open = false;
                          });
                        },
                      )
                    : RichText(text: TextSpan(children: widget.content))
                : Text(widget.spoilerText),
          ),
        ),
      ),
    );
  }
}
