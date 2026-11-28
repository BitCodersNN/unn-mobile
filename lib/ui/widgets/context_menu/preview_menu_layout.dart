// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/rendering.dart';

enum PreviewMenuSlot { preview, accessory, actions }

class PreviewMenuLayout extends MultiChildLayoutDelegate {
  final Rect sourceRect;
  final double progress;
  final double minActionsWidth;
  final EdgeInsets padding;

  PreviewMenuLayout({
    required this.sourceRect,
    required this.progress,
    required this.minActionsWidth,
    required this.padding,
  });

  @override
  void performLayout(Size size) {
    final available = padding.deflateRect(Offset.zero & size);
    final width = math.min(sourceRect.width, available.width);
    final gap = math.min(12.0, available.height * 0.05);
    final accessory = hasChild(PreviewMenuSlot.accessory)
        ? layoutChild(
            PreviewMenuSlot.accessory,
            BoxConstraints(
              minWidth: width,
              maxWidth: width,
              maxHeight: math.max(0.0, available.height * 0.2),
            ),
          )
        : Size.zero;
    final actionsWidth = math.min(
      math.max(width, minActionsWidth),
      math.min(280.0, available.width),
    );
    final actions = layoutChild(
      PreviewMenuSlot.actions,
      BoxConstraints(
        minWidth: actionsWidth,
        maxWidth: actionsWidth,
        maxHeight: math.max(0.0, available.height * 0.45),
      ),
    );
    final accessorySpace = accessory.height > 0 ? accessory.height + gap : 0.0;
    final targetAspectHeight = sourceRect.width > 0
        ? sourceRect.height * width / sourceRect.width
        : 0.0;
    final height = math.min(
      targetAspectHeight,
      math.max(0.0, available.height - accessorySpace - actions.height - gap),
    );
    final top = sourceRect.top
        .clamp(
          available.top,
          math.max(
            available.top,
            available.bottom - height - accessorySpace - actions.height - gap,
          ),
        )
        .toDouble();
    final left = sourceRect.left
        .clamp(
          available.left,
          math.max(available.left, available.right - width),
        )
        .toDouble();
    final preview =
        Rect.lerp(
          sourceRect,
          Rect.fromLTWH(left, top, width, height),
          progress,
        ) ??
        sourceRect;
    layoutChild(PreviewMenuSlot.preview, BoxConstraints.tight(preview.size));
    positionChild(PreviewMenuSlot.preview, preview.topLeft);
    final actionsLeft = preview.left
        .clamp(
          available.left,
          math.max(available.left, available.right - actions.width),
        )
        .toDouble();
    positionChild(
      PreviewMenuSlot.actions,
      Offset(actionsLeft, preview.bottom + gap + accessorySpace),
    );
    if (hasChild(PreviewMenuSlot.accessory)) {
      positionChild(
        PreviewMenuSlot.accessory,
        Offset(preview.left, preview.bottom + gap),
      );
    }
  }

  @override
  bool shouldRelayout(PreviewMenuLayout oldDelegate) =>
      sourceRect != oldDelegate.sourceRect ||
      progress != oldDelegate.progress ||
      minActionsWidth != oldDelegate.minActionsWidth ||
      padding != oldDelegate.padding;
}
