// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/preview_menu_route.dart';

export 'package:unn_mobile/ui/widgets/context_menu/preview_menu_route.dart'
    show PreviewContextMenuAccessoryBuilder;

class PreviewContextMenu extends StatefulWidget {
  final List<ContextMenuAction> Function(BuildContext) actionsBuilder;
  final PreviewContextMenuAccessoryBuilder? topAccessoryBuilder;
  final BorderRadius borderRadius;
  final double minActionsWidth;
  final GlobalKey? previewKey;
  final Widget child;

  const PreviewContextMenu({
    required this.actionsBuilder,
    required this.child,
    this.topAccessoryBuilder,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.minActionsWidth = 220,
    this.previewKey,
    super.key,
  });

  @override
  State<PreviewContextMenu> createState() => _PreviewContextMenuState();
}

class _PreviewContextMenuState extends State<PreviewContextMenu> {
  final _previewKey = GlobalKey();
  bool _openingMenu = false;
  bool _menuOpen = false;

  void _setMenuOpen(bool value) {
    if (mounted && _menuOpen != value) {
      setState(() => _menuOpen = value);
    }
  }

  Future<void> _showMenu() async {
    if (_openingMenu) {
      return;
    }
    final source = (widget.previewKey ?? _previewKey).currentContext
        ?.findRenderObject();
    if (source is! RenderRepaintBoundary) {
      return;
    }
    _openingMenu = true;
    try {
      await _showPreviewContextMenu(
        context: context,
        source: source,
        actions: widget.actionsBuilder(context),
        topAccessoryBuilder: widget.topAccessoryBuilder,
        borderRadius: widget.borderRadius,
        minActionsWidth: widget.minActionsWidth,
        onOpen: () => _setMenuOpen(true),
        onClose: () => _setMenuOpen(false),
      );
    } finally {
      _openingMenu = false;
      _setMenuOpen(false);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onLongPress: _showMenu,
    child: Opacity(
      opacity: _menuOpen ? 0 : 1,
      child: RepaintBoundary(
        key: widget.previewKey ?? _previewKey,
        child: widget.child,
      ),
    ),
  );
}

Future<void> _showPreviewContextMenu({
  required BuildContext context,
  required RenderRepaintBoundary source,
  required List<ContextMenuAction> actions,
  required BorderRadius borderRadius,
  required double minActionsWidth,
  required VoidCallback onOpen,
  required VoidCallback onClose,
  PreviewContextMenuAccessoryBuilder? topAccessoryBuilder,
}) async {
  if (source.size.isEmpty) {
    return;
  }
  final navigator = Navigator.of(context, rootNavigator: true);
  final overlay = navigator.overlay?.context.findRenderObject();
  if (overlay is! RenderBox) {
    return;
  }
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final dismissLabel = MaterialLocalizations.of(context)
      .modalBarrierDismissLabel;
  final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
  triggerHaptic(HapticIntensity.medium);
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) {
    return;
  }
  if (!source.attached || !overlay.attached || source.size.isEmpty) {
    return;
  }
  final rect =
      overlay.globalToLocal(source.localToGlobal(Offset.zero)) & source.size;
  final pixelRatio = math.min(
    devicePixelRatio.clamp(1.0, 2.0),
    math.sqrt(4000000 / (source.size.width * source.size.height)),
  );
  final image = await source.toImage(pixelRatio: pixelRatio);
  final VoidCallback? action;
  try {
    action = context.mounted
        ? await _pushPreviewMenuRoute(
            navigator: navigator,
            image: image,
            sourceRect: rect,
            borderRadius: borderRadius,
            minActionsWidth: minActionsWidth,
            actions: actions,
            topAccessoryBuilder: topAccessoryBuilder,
            themes: themes,
            dismissLabel: dismissLabel,
            onOpen: onOpen,
            onClose: onClose,
          )
        : null;
  } finally {
    image.dispose();
  }
  if (context.mounted) {
    action?.call();
  }
}

Future<VoidCallback?> _pushPreviewMenuRoute({
  required NavigatorState navigator,
  required ui.Image image,
  required Rect sourceRect,
  required BorderRadius borderRadius,
  required double minActionsWidth,
  required List<ContextMenuAction> actions,
  required PreviewContextMenuAccessoryBuilder? topAccessoryBuilder,
  required CapturedThemes themes,
  required String dismissLabel,
  required VoidCallback onOpen,
  required VoidCallback onClose,
}) async {
  final route = PreviewMenuRoute(
    image: image,
    sourceRect: sourceRect,
    borderRadius: borderRadius,
    minActionsWidth: minActionsWidth,
    actions: actions,
    topAccessoryBuilder: topAccessoryBuilder,
    themes: themes,
    dismissLabel: dismissLabel,
    onClose: onClose,
  );
  onOpen();
  final action = await navigator.push(route);
  await route.completed;
  return action;
}
