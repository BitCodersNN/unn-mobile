// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
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
        // OverlayEntry createOverlay(int index) => OverlayEntry(
        //       builder: (context) {
        //         return SafeArea(
        //           child: Align(
        //             alignment: Alignment.topCenter,
        //             child: Material(
        //               color: Colors.transparent,
        //               child: Container(
        //                 padding: const EdgeInsets.all(12),
        //                 decoration: const BoxDecoration(
        //                   color: Colors.transparent,
        //                 ),
        //                 child: Text(
        //                   '${index + 1} из ${attachedImages.length}',
        //                   style: const TextStyle(
        //                     color: Colors.black,
        //                     fontSize: 24,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         );
        //       },
        //     );

        // var overlay = createOverlay(index);
        // await showDialog(
        //   context: context,
        //   builder: (context) {
        //     WidgetsBinding.instance.addPostFrameCallback((_) {
        //       Overlay.of(context, rootOverlay: true).insert(overlay);
        //     });

        //     return ExtendedImageSlidePage(
        //       slideAxis: SlideAxis.vertical,
        //       child: ImagesCarousel(
        //         attachedImages: attachedImages,
        //         imageModel: index,
        //         onPageChanged: (index) {
        //           overlay.remove();
        //           overlay = createOverlay(index);
        //           Overlay.of(context).insert(overlay);
        //         },
        //       ),
        //     );
        //   },
        // );
        // overlay.remove();
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
  const _ImagesCarouselDialog(this.attachedImages, this.initialIndex);

  final Iterable<String> attachedImages;
  final int initialIndex;

  @override
  State<_ImagesCarouselDialog> createState() => _ImagesCarouselDialogState();
}

class _ImagesCarouselDialogState extends State<_ImagesCarouselDialog> {
  OverlayEntry? _overlay;
  GlobalKey<_ImagesCarouselDialogOverlayState>? _overlayKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateOverlay(widget.initialIndex);
    });
  }

  void updateOverlay(int index) {
    _overlay?.remove();
    _overlayKey = GlobalKey();

    _overlay = OverlayEntry(
      builder: (context) {
        return _ImagesCarouselDialogOverlay(
          key: _overlayKey,
          length: widget.attachedImages.length,
          initialIndex: widget.initialIndex,
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      slideAxis: SlideAxis.vertical,
      child: ImagesCarousel(
        attachedImages: widget.attachedImages,
        imageModel: widget.initialIndex,
        onPageChanged: (index) {
          _overlayKey?.currentState?.updateIndex(index);
        },
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }
}

class _ImagesCarouselDialogOverlay extends StatefulWidget {
  const _ImagesCarouselDialogOverlay({
    super.key,
    required this.length,
    required this.initialIndex,
  });

  final int length;
  final int initialIndex;

  @override
  State<_ImagesCarouselDialogOverlay> createState() =>
      _ImagesCarouselDialogOverlayState();
}

class _ImagesCarouselDialogOverlayState
    extends State<_ImagesCarouselDialogOverlay> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  void updateIndex(int newIndex) {
    if (index < widget.length) {
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
              '${index + 1} из ${widget.length}',
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
          ExtendedImage(
            enableLoadState: true,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (state) {
              return GestureConfig(
                minScale: 0.9,
                animationMinScale: 0.7,
                maxScale: 3.0,
                animationMaxScale: 3.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: false,
                initialAlignment: InitialAlignment.center,
              );
            },
            image: CachedNetworkImageProvider(
              image,
            ),
            enableSlideOutPage: true,
          ),
      ],
    );
  }
}
