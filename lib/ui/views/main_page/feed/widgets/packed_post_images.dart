// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
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
        OverlayEntry createOverlay(int index) => OverlayEntry(
              builder: (context) {
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
                          '${index + 1} из ${attachedImages.length}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );

        var overlay = createOverlay(index);
        await showDialog(
          context: context,
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Overlay.of(context, rootOverlay: true).insert(overlay);
            });

            return ExtendedImageSlidePage(
              slideAxis: SlideAxis.vertical,
              child: ImagesCarousel(
                attachedImages: attachedImages,
                imageModel: index,
                onPageChanged: (index) {
                  overlay.remove();
                  overlay = createOverlay(index);
                  Overlay.of(context).insert(overlay);
                },
              ),
            );
          },
        );
        overlay.remove();
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
