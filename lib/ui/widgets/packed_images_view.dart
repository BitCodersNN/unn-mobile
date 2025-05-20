import 'dart:async';

import 'package:flutter/material.dart';

class PackedImagesView extends StatelessWidget {
  final List<Widget> children;
  final FutureOr<void> Function(int index)? onChildTap;

  const PackedImagesView({
    super.key,
    required this.children,
    this.onChildTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (children.length) {
      0 => Container(),
      1 => GestureDetector(
          onTap: () async => await onChildTap?.call(0),
          child: children[0],
        ),
      2 => Row(
          children: children.indexed
              .map(
                (e) => Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: GestureDetector(
                      onTap: () async => await onChildTap?.call(e.$1),
                      child: FittedBox(fit: BoxFit.cover, child: e.$2),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      3 || 4 => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: GestureDetector(
                onTap: () async => await onChildTap?.call(0),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: children.first,
                ),
              ),
            ),
            ClipRect(
              child: SizedBox(
                height: 110.0,
                child: Row(
                  children: children.indexed
                      .skip(1)
                      .map(
                        (e) => Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: GestureDetector(
                              onTap: () async => await onChildTap?.call(e.$1),
                              child: FittedBox(fit: BoxFit.cover, child: e.$2),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: GestureDetector(
                onTap: () async => await onChildTap?.call(0),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: children.first,
                ),
              ),
            ),
            ClipRect(
              child: SizedBox(
                height: 110.0,
                child: Row(
                  children: [
                    ...children.indexed.skip(1).take(2).map(
                          (e) => Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: GestureDetector(
                                onTap: () async => await onChildTap?.call(e.$1),
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: e.$2,
                                ),
                              ),
                            ),
                          ),
                        ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: GestureDetector(
                          onTap: () async => await onChildTap?.call(3),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withAlpha(127),
                                    BlendMode.srcATop,
                                  ),
                                  child: ClipRect(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: children[3],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '+${children.length - 3}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    };
  }
}
