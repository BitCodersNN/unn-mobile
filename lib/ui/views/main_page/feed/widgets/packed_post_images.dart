// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/bounded_int.dart';
import 'package:unn_mobile/ui/widgets/dismissable_image.dart';
import 'package:unn_mobile/ui/widgets/packed_images_view.dart';

class PackedPostImages extends StatelessWidget {
  const PackedPostImages({
    super.key,
    required this.attachedImages,
  });

  final Iterable<String> attachedImages;

  @override
  Widget build(BuildContext context) {
    return PackedImagesView(
      onChildTap: (index) async {
        await showDialog(
          context: context,
          builder: (context) => _ImagesCarouselDialog(attachedImages, index),
        );
      },
      children: attachedImages
          .map(
            (e) => CachedNetworkImage(
              imageUrl: e.startsWith('/') ? 'https://portal.unn.ru$e' : e,
            ),
          )
          .toList(),
    );
  }
}

class _ImagesCarouselDialog extends StatefulWidget {
  _ImagesCarouselDialog(this.attachedImages, int initialIndex)
      : initialIndex = BoundedInt(
          value: initialIndex,
          min: 0,
          max: attachedImages.length,
        );

  final Iterable<String> attachedImages;
  final BoundedInt initialIndex;

  @override
  State<_ImagesCarouselDialog> createState() => _ImagesCarouselDialogState();
}

class _ImagesCarouselDialogState extends State<_ImagesCarouselDialog> {
  late final OverlayEntry _overlay;
  final GlobalKey<_ImagesCarouselDialogOverlayState> _overlayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlay = OverlayEntry(
        builder: (context) {
          return _ImagesCarouselDialogOverlay(
            key: _overlayKey,
            length: widget.attachedImages.length,
            initialIndex: widget.initialIndex.value,
          );
        },
      );
      Overlay.of(context, rootOverlay: true).insert(_overlay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      slideAxis: SlideAxis.vertical,
      child: ImagesCarousel(
        attachedImages: widget.attachedImages,
        imageModel: widget.initialIndex.value,
        onPageChanged: (index) {
          _overlayKey.currentState?.updateIndex(index);
        },
      ),
    );
  }

  @override
  void dispose() {
    _overlay.remove();
    super.dispose();
  }
}

class _ImagesCarouselDialogOverlay extends StatefulWidget {
  _ImagesCarouselDialogOverlay({
    super.key,
    required int length,
    required int initialIndex,
  }) : initialIndex = BoundedInt(value: initialIndex, min: 0, max: length - 1);

  final BoundedInt initialIndex;

  @override
  State<_ImagesCarouselDialogOverlay> createState() =>
      _ImagesCarouselDialogOverlayState();
}

class _ImagesCarouselDialogOverlayState
    extends State<_ImagesCarouselDialogOverlay> {
  var index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex.value;
  }

  void updateIndex(int newIndex) {
    if (newIndex > 0 && newIndex <= widget.initialIndex.max) {
      setState(() {
        index = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Text(
              '${index + 1} из ${widget.initialIndex.max + 1}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImagesCarousel extends StatefulWidget {
  final Iterable<String> attachedImages;
  final int imageModel;
  final void Function(int index)? onPageChanged;

  const ImagesCarousel({
    super.key,
    required this.attachedImages,
    this.imageModel = 0,
    this.onPageChanged,
  });

  @override
  State<ImagesCarousel> createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<ImagesCarousel> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        scrollPhysics: const BouncingScrollPhysics(),
        enableInfiniteScroll: false,
        disableCenter: true,
        padEnds: true,
        viewportFraction: 1.0,
        initialPage: widget.imageModel,
        onPageChanged: (index, reason) => widget.onPageChanged?.call(index),
      ),
      items: [
        for (final image in widget.attachedImages)
          DismissibleImage(image: image),
      ],
    );
  }
}
