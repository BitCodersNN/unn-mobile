// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/ui/widgets/image_page_counter.dart';

Future<void> showImageViewer(
  BuildContext context, {
  required List<ImageProvider> images,
  int initialIndex = 0,
  ValueChanged<int>? onPageChanged,
}) async {
  if (images.isEmpty) {
    return;
  }
  await Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) => ImageViewerScreen(
        images: List.unmodifiable(images),
        initialIndex: initialIndex,
        onPageChanged: onPageChanged,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = animation.drive(
          CurveTween(curve: Curves.easeInOutCubic),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: curved,
              child: const ColoredBox(color: Colors.black),
            ),
            FadeTransition(opacity: curved, child: child),
          ],
        );
      },
    ),
  );
}

class ImageViewerScreen extends StatefulWidget {
  final List<ImageProvider> images;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;

  const ImageViewerScreen({
    required this.images,
    this.initialIndex = 0,
    this.onPageChanged,
    super.key,
  }) : assert(images.length > 0);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final ExtendedPageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _controller = ExtendedPageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ScaleTransition(
              scale:
                  (ModalRoute.of(context)?.animation ??
                          const AlwaysStoppedAnimation<double>(1))
                      .drive(CurveTween(curve: Curves.easeInOutCubic))
                      .drive(Tween<double>(begin: 0.96, end: 1)),
              child: ExtendedImageGesturePageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() => _index = index);
                  widget.onPageChanged?.call(index);
                },
                itemBuilder: (context, index) => _buildImage(index),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                tooltip: 'Закрыть',
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            Positioned(
              top: 20,
              right: 16,
              child: ImagePageCounter(
                currentPage: _index + 1,
                pageCount: widget.images.length,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildImage(int index) => ExtendedImage(
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
    loadStateChanged: (state) => switch (state.extendedImageLoadState) {
      LoadState.loading => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      LoadState.failed => const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: Colors.white70,
        ),
      ),
      LoadState.completed => state.completedWidget,
    },
  );
}
