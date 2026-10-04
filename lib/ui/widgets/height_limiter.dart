// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class HeightLimiter extends StatelessWidget {
  final Widget child;
  final double maxHeight;
  final double fadeEffectHeight;
  final Color baseColor;
  final bool overflowIndicatorOutside;
  final Widget Function(BuildContext context)? overflowIndicatorBuilder;

  const HeightLimiter({
    required this.maxHeight,
    required this.child,
    super.key,
    this.fadeEffectHeight = 72,
    this.overflowIndicatorBuilder,
    this.baseColor = Colors.white,
    this.overflowIndicatorOutside = false,
  });

  @override
  Widget build(BuildContext context) => _HeightLimitedContent(
        maxHeight: maxHeight,
        indicatorOutside: overflowIndicatorOutside,
        content: overflowIndicatorOutside && fadeEffectHeight > 0
            ? ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) {
                  if (bounds.height <= maxHeight) {
                    return const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ).createShader(bounds);
                  }
                  final fadeHeight = math.min(fadeEffectHeight, maxHeight);
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.transparent],
                  ).createShader(
                    Rect.fromLTWH(
                      0,
                      maxHeight - fadeHeight,
                      bounds.width,
                      fadeHeight,
                    ),
                  );
                },
                child: child,
              )
            : child,
        indicator: overflowIndicatorBuilder?.call(context) ??
            Container(
              height: fadeEffectHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [baseColor.withAlpha(200), baseColor.withAlpha(0)],
                  tileMode: TileMode.clamp,
                ),
              ),
            ),
      );
}

class _HeightLimitedContent extends MultiChildRenderObjectWidget {
  final double maxHeight;
  final bool indicatorOutside;

  _HeightLimitedContent({
    required this.maxHeight,
    required this.indicatorOutside,
    required Widget content,
    required Widget indicator,
  }) : super(children: [content, indicator]);

  @override
  _RenderHeightLimitedContent createRenderObject(BuildContext context) =>
      _RenderHeightLimitedContent(
        maxHeight: maxHeight,
        indicatorOutside: indicatorOutside,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeightLimitedContent renderObject,
  ) {
    renderObject
      ..maxHeight = maxHeight
      ..indicatorOutside = indicatorOutside;
  }
}

class _HeightLimitedParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderHeightLimitedContent extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            ContainerBoxParentData<RenderBox>> {
  double _maxHeight;
  bool _indicatorOutside;
  bool _hasOverflow = false;
  double _visibleHeight = 0;

  _RenderHeightLimitedContent({
    required double maxHeight,
    required bool indicatorOutside,
  })  : _maxHeight = maxHeight,
        _indicatorOutside = indicatorOutside;

  double get maxHeight => _maxHeight;
  set maxHeight(double value) {
    if (value == _maxHeight) {
      return;
    }
    _maxHeight = value;
    markNeedsLayout();
  }

  bool get indicatorOutside => _indicatorOutside;
  set indicatorOutside(bool value) {
    if (value == _indicatorOutside) {
      return;
    }
    _indicatorOutside = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>) {
      child.parentData = _HeightLimitedParentData();
    }
  }

  @override
  void performLayout() {
    final content = firstChild!;
    final indicator = lastChild!;
    content.layout(
      constraints.copyWith(minHeight: 0, maxHeight: double.infinity),
      parentUsesSize: true,
    );
    indicator.layout(
      BoxConstraints.tightFor(width: content.size.width),
      parentUsesSize: true,
    );
    final hasOverflow = content.size.height > _maxHeight;
    if (_hasOverflow != hasOverflow) {
      _hasOverflow = hasOverflow;
      markNeedsSemanticsUpdate();
    }
    _visibleHeight = math.min(content.size.height, _maxHeight);
    final indicatorHeight =
        _hasOverflow && _indicatorOutside ? indicator.size.height : 0.0;
    size = constraints
        .constrain(Size(content.size.width, _visibleHeight + indicatorHeight));
    (content.parentData! as ContainerBoxParentData<RenderBox>).offset =
        Offset.zero;
    (indicator.parentData! as ContainerBoxParentData<RenderBox>).offset =
        Offset(
      0,
      _indicatorOutside
          ? _visibleHeight
          : math.max(0, _visibleHeight - indicator.size.height),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(
      needsCompositing,
      offset,
      Rect.fromLTWH(0, 0, size.width, _visibleHeight),
      (context, offset) => context.paintChild(firstChild!, offset),
    );
    if (_hasOverflow) {
      final indicator = lastChild!;
      final parentData =
          indicator.parentData! as ContainerBoxParentData<RenderBox>;
      context.paintChild(indicator, offset + parentData.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_hasOverflow) {
      final indicator = lastChild!;
      final parentData =
          indicator.parentData! as ContainerBoxParentData<RenderBox>;
      if (result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (result, position) =>
            indicator.hitTest(result, position: position),
      )) {
        return true;
      }
    }
    return position.dy < _visibleHeight &&
        firstChild!.hitTest(result, position: position);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitor(firstChild!);
    if (_hasOverflow) {
      visitor(lastChild!);
    }
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) => child == firstChild
      ? Rect.fromLTWH(0, 0, size.width, _visibleHeight)
      : null;
}

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    final Size newSize = child!.size;
    if (oldSize == newSize) {
      return;
    }

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    required this.onChange,
    required Widget super.child,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}
