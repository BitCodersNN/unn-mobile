// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/app_modal_sheet.dart';
import 'package:unn_mobile/ui/widgets/image_page_counter.dart';

Future<void> showImageViewerSheet(
  BuildContext context, {
  required List<ImageProvider> images,
  int initialIndex = 0,
}) async {
  if (images.isEmpty) {
    return;
  }
  await showAppModalSheet<void>(
    context: context,
    builder: (_) => ImageViewerSheet(
      images: List.unmodifiable(images),
      initialIndex: initialIndex,
    ),
  );
}

class ImageViewerSheet extends StatefulWidget {
  final List<ImageProvider> images;
  final int initialIndex;

  const ImageViewerSheet({
    required this.images,
    this.initialIndex = 0,
    super.key,
  }) : assert(images.length > 0);

  @override
  State<ImageViewerSheet> createState() => _ImageViewerSheetState();
}

class _ImageViewerSheetState extends State<ImageViewerSheet> {
  late final ExtendedPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExtendedPageController(
      initialPage: widget.initialIndex.clamp(0, widget.images.length - 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppModalSheet(
        showCloseButton: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ExtendedImageGesturePageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.images.length,
            itemBuilder: (context, index) => ExtendedImage(
              image: widget.images[index],
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (_) => GestureConfig(
                minScale: 0.9,
                animationMinScale: 0.7,
                maxScale: 3.0,
                animationMaxScale: 3.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: widget.images.length > 1,
                initialAlignment: InitialAlignment.center,
              ),
              loadStateChanged: (state) =>
                  switch (state.extendedImageLoadState) {
                LoadState.loading => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                LoadState.failed => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                LoadState.completed => _ImageFrame(
                    imageSize: Size(
                      state.extendedImageInfo!.image.width.toDouble(),
                      state.extendedImageInfo!.image.height.toDouble(),
                    ),
                    currentPage: index + 1,
                    pageCount: widget.images.length,
                    child: state.completedWidget,
                  ),
              },
            ),
          ),
        ),
      );
}

class _ImageFrame extends StatelessWidget {
  final Size imageSize;
  final int currentPage;
  final int pageCount;
  final Widget child;

  const _ImageFrame({
    required this.imageSize,
    required this.currentPage,
    required this.pageCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final size = applyBoxFit(
            BoxFit.contain,
            imageSize,
            constraints.biggest,
          ).destination;
          final colors = Theme.of(context).colorScheme;
          return Center(
            child: SizedBox(
              key: ValueKey('image-frame-$currentPage'),
              width: size.width,
              height: size.height,
              child: Material(
                color: colors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    child,
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ImagePageCounter(
                        currentPage: currentPage,
                        pageCount: pageCount,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
